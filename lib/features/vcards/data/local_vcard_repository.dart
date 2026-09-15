import 'package:bizkonec/features/vcards/domain/vcard.dart';
import 'package:bizkonec/features/vcards/domain/vcard_repository.dart';

class LocalVCardRepository implements VCardRepository {
  final List<VCard> _vcards = [
    VCard(
      id: '1',
      url: 'https://example.com/vcard/john',
      title: 'John Smith | ABC Company',
      description: 'Business consultant and technology specialist.',
      imageUrl: 'https://images.unsplash.com/photo-1599566150163-29194dcaad36?w=400',
      domain: 'example.com',
      source: 'qr',
      createdAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<VCard>> getVCards() async {
    return List.unmodifiable(_vcards);
  }

  @override
  Future<void> saveVCard(VCard vcard) async {
    _vcards.insert(0, vcard);
  }

  @override
  Future<void> deleteVCard(String id) async {
    _vcards.removeWhere((v) => v.id == id);
  }
}
