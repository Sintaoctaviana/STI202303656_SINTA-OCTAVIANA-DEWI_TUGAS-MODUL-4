// BAB 5 JSON Model

import 'package:json_annotation/json_annotation.dart';
// Penting: File ini akan memiliki file pendamping task_api_model.g.dart
part 'task_api_model.g.dart';

@JsonSerializable()
class TaskDto {
  final int? id;
  final String title;
  final String? description;
  final bool isCompleted;

  TaskDto({
    this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
  });

  factory TaskDto.fromJson(Map<String, dynamic> json) =>
      _$TaskDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TaskDtoToJson(this);
}