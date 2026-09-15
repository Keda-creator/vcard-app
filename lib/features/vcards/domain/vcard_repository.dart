import 'package:bizkonec/features/vcards/domain/vcard.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class VCardRepository {
  Future<List<VCard>> getVCards();
  Future<void> saveVCard(VCard vcard);
  Future<void> deleteVCard(String id);
}

final vCardRepositoryProvider = Provider<VCardRepository>((ref) {
  throw UnimplementedError();
});
