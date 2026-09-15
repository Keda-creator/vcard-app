import 'package:bizkonec/features/pcards/domain/pcard_repository.dart';
import 'package:bizkonec/features/pcards/domain/physical_card.dart';

class LocalPCardRepository implements PCardRepository {
  // In a real local implementation, this would use Hive
  final List<PhysicalCard> _cards = [
    PhysicalCard(
      id: '1',
      name: 'John Smith - ABC',
      frontImagePath: 'https://images.unsplash.com/photo-1540317580384-e5d43616b9aa?w=400',
      backImagePath: 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?w=400',
      notes: 'Met at conference',
      createdAt: DateTime.now(),
    ),
  ];

  @override
  Future<List<PhysicalCard>> getPCards() async {
    return List.unmodifiable(_cards);
  }

  @override
  Future<void> savePCard(PhysicalCard card) async {
    _cards.insert(0, card);
  }

  @override
  Future<void> deletePCard(String id) async {
    _cards.removeWhere((c) => c.id == id);
  }
}
