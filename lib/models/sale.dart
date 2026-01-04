class Sale {
  final int id;
  final int copyId;
  final int? contactId;
  final int libraryId;
  final DateTime saleDate;
  final double salePrice;
  final String status; // 'completed', 'cancelled'
  final String? notes;

  // Enriched data from backend
  final String? contactName;
  final String? bookTitle;

  Sale({
    required this.id,
    required this.copyId,
    this.contactId,
    required this.libraryId,
    required this.saleDate,
    required this.salePrice,
    required this.status,
    this.notes,
    this.contactName,
    this.bookTitle,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'],
      copyId: json['copy_id'],
      contactId: json['contact_id'],
      libraryId: json['library_id'],
      saleDate: DateTime.parse(json['sale_date']),
      salePrice: (json['sale_price'] as num).toDouble(),
      status: json['status'] ?? 'completed',
      notes: json['notes'],
      contactName: json['contact_name'],
      bookTitle: json['book_title'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'copy_id': copyId,
      'contact_id': contactId,
      'library_id': libraryId,
      'sale_date': saleDate.toIso8601String(),
      'sale_price': salePrice,
      'status': status,
      'notes': notes,
    };
  }
}
