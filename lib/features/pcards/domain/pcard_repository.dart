import 'package:bizkonec/features/pcards/domain/physical_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

abstract class PCardRepository {
  Future<List<PhysicalCard>> getPCards();
  Future<void> savePCard(PhysicalCard card);
  Future<void> deletePCard(String id);
}

final pCardRepositoryProvider = Provider<PCardRepository>((ref) {
  throw UnimplementedError();
});
