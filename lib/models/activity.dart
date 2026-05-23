import 'package:hive/hive.dart';

part 'activity.g.dart';   

@HiveType(typeId: 0)
class Activity extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String category;

  @HiveField(3)
  bool isDone;

  @HiveField(4)
  final DateTime createdAt;

  Activity({
    required this.id,
    required this.title,
    required this.category,
    this.isDone = false,
    required this.createdAt,
  });
}