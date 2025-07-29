import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'task_hive_model.g.dart';

@HiveType(typeId: 3)
class TaskHiveModel extends HiveObject {
  @HiveField(0)
  late final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  late final String createdAt;
  @HiveField(3)
  late final String categoryId;

  TaskHiveModel({
    required this.name,
    required this.categoryId,
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
        'categoryId': categoryId,
      };
}
