import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'category_hive_model.g.dart';

@HiveType(typeId: 2)
class CategoryHiveModel extends HiveObject {
  @HiveField(0)
  late final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  late final String createdAt;
  @HiveField(3)
  late final String userId;

  CategoryHiveModel({
    required this.name,
    required this.userId,
    id,
    createdAt,
  }) {
    this.id = id ?? UniqueKey().toString();
    this.createdAt = createdAt ?? DateTime.now().toIso8601String();
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt,
        'userId': userId,
      };
}
