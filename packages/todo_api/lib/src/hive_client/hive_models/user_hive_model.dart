import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'user_hive_model.g.dart';

@HiveType(typeId: 1)
class UserHiveModel extends HiveObject {
  @HiveField(0)
  late final String id;
  @HiveField(1)
  final String login;
  @HiveField(2)
  final String password;
  @HiveField(3)
  late final String createdAt;

  UserHiveModel({
    required this.login,
    required this.password,
    id,
    createdAt,
  }) {
    this.id = id ?? UniqueKey().toString();
    this.createdAt = createdAt ?? DateTime.now().toIso8601String();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'login': login,
        'createdAt': createdAt,
      };
}
