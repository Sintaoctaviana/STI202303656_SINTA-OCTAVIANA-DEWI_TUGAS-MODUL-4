// BAB 4 UI Floor

import 'package:flutter/material.dart';
import 'app_database.dart';
import 'task_entity.dart';

class TaskFloorPage extends StatefulWidget {
  const TaskFloorPage({super.key});

  @override
  State<TaskFloorPage> createState() => _TaskFloorPageState();
}

class _TaskFloorPageState extends State<TaskFloorPage> {
  late final Future<AppDatabase> _dbFuture;
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    // Inisialisasi Future database menggunakan $FloorAppDatabase (yang akan digenerate)
    _dbFuture = $FloorAppDatabase.databaseBuilder('app_floor.db').build();
    _load();
  }

  Future<void> _load() async {
    final db = await _dbFuture;
    final list = await db.taskDao.findAll();
    if (mounted) {
      setState(() => _tasks = list);
    }
  }

  Future<void> _add() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    final db = await _dbFuture;
    await db.taskDao.insertTask(
      Task(title: _titleCtrl.text, description: _descCtrl.text),
    );
    _titleCtrl.clear();
    _descCtrl.clear();
    await _load();
  }

  Future<void> _toggle(Task t) async {
    final db = await _dbFuture;
    // Membuat objek Task baru untuk update dengan status isCompleted yang di-toggle
    await db.taskDao.updateTask(
      Task(
        id: t.id,
        title: t.title,
        description: t.description,
        isCompleted: !t.isCompleted,
      ),
    );
    await _load();
  }

  Future<void> _delete(Task t) async {
    final db = await _dbFuture;
    await db.taskDao.deleteTask(t);
    await _load();
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Task (Floor)')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(labelText: 'Judul'),
                ),
                TextField(
                  controller: _descCtrl,
                  decoration: const InputDecoration(labelText: 'Deskripsi'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(onPressed: _add, child: const Text('Tambah')),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (_, i) {
                final t = _tasks[i];
                return ListTile(
                  title: Text(t.title),
                  subtitle: Text(t.description ?? ''),
                  leading: IconButton(
                    icon: Icon(
                      t.isCompleted
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                    ),
                    onPressed: () => _toggle(t),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _delete(t),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}