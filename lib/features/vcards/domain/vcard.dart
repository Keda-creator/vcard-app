class VCard {
  final String id;
  final String url;
  final String title;
  final String? description;
  final String? imageUrl;
  final String domain;
  final String source; // qr, nfc, manual
  final DateTime createdAt;

  VCard({
    required this.id,
    required this.url,
    required this.title,
    this.description,
    this.imageUrl,
    required this.domain,
    required this.source,
    required this.createdAt,
  });
}
