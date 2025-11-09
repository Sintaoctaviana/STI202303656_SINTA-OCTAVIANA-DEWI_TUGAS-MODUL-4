// BAB 4 Floor Database

import 'dart:async';
import 'package:floor/floor.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'task_entity.dart';
import 'task_dao.dart';

// Penting: File ini akan memiliki file pendamping app_database.g.dart
// yang dibuat oleh build_runner.
part 'app_database.g.dart';

@Database(version: 1, entities: [Task])
abstract class AppDatabase extends FloorDatabase {
  TaskDao get taskDao;
}