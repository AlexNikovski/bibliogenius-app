/// Native mDNS Service using Bonsoir
///
/// This service handles Bonjour/mDNS discovery on iOS, macOS, and other platforms
/// using native platform APIs for reliable local network discovery.
library;

import 'dart:async';
import 'dart:io';
import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/foundation.dart';
import 'package:network_info_plus/network_info_plus.dart';

/// Service type for BiblioGenius mDNS announcements
const String kServiceType = '_bibliogenius._tcp';

/// Discovered peer on the local network
class DiscoveredPeer {
  final String name;
  final String host;
  final int port;
  final List<String> addresses;
  final String? libraryId;
  final DateTime discoveredAt;

  DiscoveredPeer({
    required this.name,
    required this.host,
    required this.port,
    required this.addresses,
    this.libraryId,
    required this.discoveredAt,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'host': host,
        'port': port,
        'addresses': addresses,
        'library_id': libraryId,
        'discovered_at': discoveredAt.toIso8601String(),
      };
}

/// Native mDNS service for local network discovery
class MdnsService {
  static BonsoirBroadcast? _broadcast;
  static BonsoirDiscovery? _discovery;
  static final Map<String, DiscoveredPeer> _peers = {};
  static StreamSubscription? _discoverySubscription;
  static bool _isRunning = false;
  static String? _ownServiceName;

  /// Check if mDNS service is active
  static bool get isActive => _isRunning;

  /// Get discovered peers (excluding own service)
  static List<DiscoveredPeer> get peers => _peers.values.toList();

  /// Check if an IP address is a link-local address (169.254.x.x)
  /// These addresses are auto-assigned when DHCP fails and are not routable
  static bool _isLinkLocalAddress(String ip) {
    return ip.startsWith('169.254.');
  }

  /// Try to get a valid LAN IP from network interfaces
  /// Returns the first non-link-local, non-loopback IPv4 address found
  static Future<String?> _getValidLanIp() async {
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );
      for (final interface in interfaces) {
        for (final address in interface.addresses) {
          final ip = address.address;
          // Skip loopback and link-local
          if (!address.isLoopback && !_isLinkLocalAddress(ip)) {
            debugPrint('🔍 mDNS: Found valid IP $ip on ${interface.name}');
            return ip;
          }
        }
      }
    } catch (e) {
      debugPrint('⚠️ mDNS: Error listing network interfaces - $e');
    }
    return null;
  }

  /// Start announcing this library on the network
  static Future<bool> startAnnouncing(String libraryName, int port,
      {String? libraryId}) async {
    try {
      // Clean name for mDNS - keep Unicode letters, numbers, spaces, hyphens
      // Note: mDNS/Bonjour supports UTF-8 names, so we preserve accented chars
      final safeName = libraryName.replaceAll(RegExp(r'[^\p{L}\p{N}\s-]', unicode: true), '');
      _ownServiceName = safeName;

      // Get local IP to include in attributes for reliable peer discovery
      // Filter out link-local addresses (169.254.x.x) as they're not routable
      String? localIp;
      try {
        final info = NetworkInfo();
        // Try WiFi IP first
        String? wifiIp = await info.getWifiIP();
        if (wifiIp != null && !_isLinkLocalAddress(wifiIp)) {
          localIp = wifiIp;
        }
        // If WiFi IP is link-local or null, try getting wired IP (on macOS/desktop)
        if (localIp == null) {
          // Fallback: get IP from network interfaces
          localIp = await _getValidLanIp();
        }
        if (localIp == null) {
          debugPrint('⚠️ mDNS: No valid LAN IP found (only link-local available)');
        }
      } catch (e) {
        debugPrint('⚠️ mDNS: Could not get local IP - $e');
      }

      final attributes = <String, String>{};
      if (libraryId != null) attributes['library_id'] = libraryId;
      if (localIp != null) attributes['ip'] = localIp;

      final service = BonsoirService(
        name: safeName,
        type: kServiceType,
        port: port,
        attributes: attributes,
      );

      _broadcast = BonsoirBroadcast(service: service);
      await _broadcast!.initialize();
      await _broadcast!.start();
      _isRunning = true;

      debugPrint('📡 mDNS: Broadcasting "$safeName" on port $port (IP: $localIp)');
      return true;
    } catch (e) {
      debugPrint('❌ mDNS: Failed to start broadcasting - $e');
      return false;
    }
  }

  /// Start discovering other libraries on the network
  static Future<bool> startDiscovery() async {
    try {
      _discovery = BonsoirDiscovery(type: kServiceType);
      await _discovery!.initialize();

      _discoverySubscription = _discovery!.eventStream?.listen((event) {
        // Handle service found - add immediately as workaround for macOS sandbox
        // (ServiceResolvedEvent doesn't fire reliably in Flutter sandbox)
        if (event is BonsoirDiscoveryServiceFoundEvent) {
          final service = event.service;
          
          // Skip our own service
          if (service.name == _ownServiceName) return;
          
          // Prefer IP from attributes (reliable), fallback to hostname guess
          final ipFromAttrs = service.attributes['ip'];
          String host;
          if (ipFromAttrs != null && ipFromAttrs.isNotEmpty && !_isLinkLocalAddress(ipFromAttrs)) {
            host = ipFromAttrs;
            debugPrint('📚 mDNS: Using IP from attributes: $host');
          } else {
            if (ipFromAttrs != null && _isLinkLocalAddress(ipFromAttrs)) {
              debugPrint('⚠️ mDNS: Peer advertised link-local IP ($ipFromAttrs), trying hostname fallback');
            }
            // Fallback: Generate hostname from service name (less reliable)
            final hostGuess = service.name
                .toLowerCase()
                .replaceAll(RegExp(r'[^a-z0-9]'), '-')
                .replaceAll(RegExp(r'-+'), '-')
                .replaceAll(RegExp(r'-$'), ''); // Remove trailing dash
            host = '$hostGuess.local';
            debugPrint('⚠️ mDNS: No valid IP in attributes, guessing hostname: $host');
          }
          
          // Use actual port from service (default to 8000 if not available)
          final actualPort = service.port > 0 ? service.port : 8000;
          
          final peer = DiscoveredPeer(
            name: service.name,
            host: host,
            port: actualPort,
            addresses: [host],
            libraryId: service.attributes['library_id'],
            discoveredAt: DateTime.now(),
          );

          _peers[service.name] = peer;
          debugPrint('📚 mDNS: Discovered "${peer.name}" at ${peer.host}:${peer.port}');
        }
        // Handle service resolved (preferred if it fires)
        else if (event is BonsoirDiscoveryServiceResolvedEvent) {
          final service = event.service;
          
          // Skip our own service
          if (service.name == _ownServiceName) return;

          // Update/add with resolved info (more accurate)
          final peer = DiscoveredPeer(
            name: service.name,
            host: service.host ?? 'unknown',
            port: service.port,
            addresses: service.host != null ? [service.host!] : [],
            libraryId: service.attributes['library_id'],
            discoveredAt: DateTime.now(),
          );

          _peers[service.name] = peer;
          debugPrint('📚 mDNS: Resolved "${peer.name}" at ${peer.host}:${peer.port}');
        } 
        // Handle service lost
        else if (event is BonsoirDiscoveryServiceLostEvent) {
          final service = event.service;
          if (_peers.remove(service.name) != null) {
            debugPrint('👋 mDNS: Lost "${service.name}"');
          }
        }
      });

      await _discovery!.start();
      debugPrint('🔍 mDNS: Discovery started');
      return true;
    } catch (e) {
      debugPrint('❌ mDNS: Failed to start discovery - $e');
      return false;
    }
  }

  /// Get peers as JSON-compatible maps (for API compatibility)
  static List<Map<String, dynamic>> getPeersJson() {
    return _peers.values.map((p) => p.toJson()).toList();
  }

  /// Stop mDNS service
  static Future<void> stop() async {
    try {
      await _discoverySubscription?.cancel();
      await _discovery?.stop();
      await _broadcast?.stop();
      _peers.clear();
      _isRunning = false;
      debugPrint('📡 mDNS: Service stopped');
    } catch (e) {
      debugPrint('⚠️ mDNS: Error stopping - $e');
    }
  }
}
