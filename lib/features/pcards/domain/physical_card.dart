import 'package:hive/hive.dart';

part 'physical_card.g.dart';

@HiveType(typeId: 0)
class PhysicalCard {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String frontImagePath;
  
  @HiveField(3)
  final String? backImagePath;
  
  @HiveField(4)
  final String? notes;
  
  @HiveField(5)
  final DateTime createdAt;

  PhysicalCard({
    required this.id,
    required this.name,
    required this.frontImagePath,
    this.backImagePath,
    this.notes,
    required this.createdAt,
  });
}
