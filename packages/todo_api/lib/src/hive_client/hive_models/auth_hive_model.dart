import 'package:hive/hive.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: 0)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String userId;

  @HiveField(2)
  final DateTime createdAt;

  @HiveField(3)
  final int refreshMs;

  @HiveField(4)
  final int accessMs;

  AuthHiveModel({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.refreshMs,
    required this.accessMs,
  });
}
