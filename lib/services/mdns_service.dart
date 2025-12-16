/// Native mDNS Service using Bonsoir
///
/// This service handles Bonjour/mDNS discovery on iOS, macOS, and other platforms
/// using native platform APIs for reliable local network discovery.
library;

import 'dart:async';
import 'package:bonsoir/bonsoir.dart';
import 'package:flutter/foundation.dart';

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

  /// Start announcing this library on the network
  static Future<bool> startAnnouncing(String libraryName, int port,
      {String? libraryId}) async {
    try {
      // Clean name for mDNS (alphanumeric, spaces, hyphens only)
      final safeName = libraryName.replaceAll(RegExp(r'[^\w\s-]'), '');
      _ownServiceName = safeName;

      final service = BonsoirService(
        name: safeName,
        type: kServiceType,
        port: port,
        attributes: libraryId != null ? {'library_id': libraryId} : {},
      );

      _broadcast = BonsoirBroadcast(service: service);
      await _broadcast!.initialize();
      await _broadcast!.start();
      _isRunning = true;

      debugPrint('📡 mDNS: Broadcasting "$safeName" on port $port');
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
          
          // Generate hostname from service name
          final hostGuess = service.name
              .toLowerCase()
              .replaceAll(RegExp(r'[^a-z0-9]'), '-')
              .replaceAll(RegExp(r'-+'), '-');
          
          final peer = DiscoveredPeer(
            name: service.name,
            host: '$hostGuess.local',
            port: 8000,
            addresses: [],
            libraryId: service.attributes['library_id'],
            discoveredAt: DateTime.now(),
          );

          _peers[service.name] = peer;
          debugPrint('📚 mDNS: Discovered "${peer.name}"');
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
