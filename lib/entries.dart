import 'package:hive/hive.dart';

part 'entries.g.dart';

@HiveType(typeId: 1)
class Entries {
  Entries({
    required this.loadName,
    required this.powerNeed,
    required this.quantity,
    required this.totalEnergy,
});
  @HiveField(0)
  String loadName;

  @HiveField(1)
  int powerNeed;

  @HiveField(2)
  int quantity;

  @HiveField(3)
  int totalEnergy;
}

