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
  Stream<List<Task>>? _taskStream;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    // Inisialisasi Future database menggunakan $FloorAppDatabase (yang akan digenerate)
    _dbFuture = $FloorAppDatabase.databaseBuilder('app_floor.db').build();
    // create a stream by waiting for the DB then using the DAO stream
    _taskStream = Stream.fromFuture(_dbFuture)
        .asyncExpand((db) => db.taskDao.findAllStream());
  }



  Future<void> _add() async {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) return;
    setState(() => _isProcessing = true);
    final db = await _dbFuture;
    await db.taskDao.insertTask(
      Task(title: title, description: _descCtrl.text),
    );
    _titleCtrl.clear();
    _descCtrl.clear();
    if (mounted) setState(() => _isProcessing = false);
  }

  Future<void> _toggle(Task t) async {
    setState(() => _isProcessing = true);
    final db = await _dbFuture;
    await db.taskDao.updateTask(
      Task(
        id: t.id,
        title: t.title,
        description: t.description,
        isCompleted: !t.isCompleted,
      ),
    );
    if (mounted) setState(() => _isProcessing = false);
  }

  Future<void> _delete(Task t) async {
    setState(() => _isProcessing = true);
    final db = await _dbFuture;
    await db.taskDao.deleteTask(t);
    if (mounted) setState(() => _isProcessing = false);
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
                ElevatedButton(onPressed: _isProcessing ? null : _add, child: const Text('Tambah')),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: _taskStream == null
                ? const Center(child: CircularProgressIndicator())
                : StreamBuilder<List<Task>>(
                    stream: _taskStream,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final list = snapshot.data ?? <Task>[];
                      if (list.isEmpty) {
                        return const Center(child: Text('Tidak ada task'));
                      }
                      return ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (_, i) {
                          final t = list[i];
                          return ListTile(
                            title: Text(t.title),
                            subtitle: Text(t.description ?? ''),
                            leading: IconButton(
                              icon: Icon(
                                t.isCompleted ? Icons.check_box : Icons.check_box_outline_blank,
                              ),
                              onPressed: _isProcessing ? null : () => _toggle(t),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: _isProcessing ? null : () => _delete(t),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}