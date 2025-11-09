// BAB 3 UI Sqflite

import 'package:flutter/material.dart';
import 'db_helper.dart';

class TaskSqflitePage extends StatefulWidget {
  const TaskSqflitePage({super.key});

  @override
  State<TaskSqflitePage> createState() => _TaskSqflitePageState();
}

class _TaskSqflitePageState extends State<TaskSqflitePage> {
  List<Map<String, dynamic>> _tasks = [];
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  Future<void> _load() async {
    final data = await DbHelper.getAll();
    if (mounted) {
      setState(() => _tasks = data);
    }
  }

  Future<void> _addTask() async {
    if (_titleCtrl.text.trim().isEmpty) return;
    await DbHelper.insert({
      'title': _titleCtrl.text,
      'description': _descCtrl.text,
      'isCompleted': 0,
    });
    _titleCtrl.clear();
    _descCtrl.clear();
    await _load();
  }

  Future<void> _toggleComplete(Map<String, dynamic> t) async {
    final id = t['id'] as int;
    final newVal = (t['isCompleted'] as int) == 1 ? 0 : 1;
    await DbHelper.update(id, {'isCompleted': newVal});
    await _load();
  }

  Future<void> _delete(int id) async {
    await DbHelper.delete(id);
    await _load();
  }

  @override
  void initState() {
    super.initState();
    _load();
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
      appBar: AppBar(title: const Text('Task (sqflite)')),
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
                ElevatedButton(
                  onPressed: _addTask,
                  child: const Text('Tambah'),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (_, i) {
                final t = _tasks[i];
                final done = (t['isCompleted'] as int) == 1;
                return ListTile(
                  title: Text(t['title']),
                  subtitle: Text(t['description'] ?? ''),
                  leading: IconButton(
                    icon: Icon(
                      done ? Icons.check_box : Icons.check_box_outline_blank,
                    ),
                    onPressed: () => _toggleComplete(t),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _delete(t['id'] as int),
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