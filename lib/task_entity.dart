// BAB 4 Floor Entity

import 'package:floor/floor.dart';

@entity
class Task {
  @primaryKey
  final int? id;
  final String title;
  final String? description;
  final bool isCompleted;

  Task({
    this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
  });
}