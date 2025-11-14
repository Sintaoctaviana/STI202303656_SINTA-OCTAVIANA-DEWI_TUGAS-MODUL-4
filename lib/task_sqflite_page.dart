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

  // search + paging state
  final _searchCtrl = TextEditingController();
  int _pageSize = 10;
  int _currentPage = 0; // zero-based
  int _totalItems = 0;

  Future<void> _load({int page = 0}) async {
    final offset = page * _pageSize;
    final res = await DbHelper.queryTasks(
      query: _searchCtrl.text,
      limit: _pageSize,
      offset: offset,
    );
    final items = (res['items'] as List).cast<Map<String, dynamic>>();
    final total = res['total'] as int;
    if (mounted) {
      setState(() {
        _tasks = items;
        _totalItems = total;
        _currentPage = page;
      });
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
    await _load(page: 0); // reload first page to show new item
  }

  Future<void> _toggleComplete(Map<String, dynamic> t) async {
    final id = t['id'] as int;
    final newVal = (t['isCompleted'] as int) == 1 ? 0 : 1;
    await DbHelper.update(id, {'isCompleted': newVal});
    await _load(page: _currentPage);
  }

  Future<void> _delete(int id) async {
    await DbHelper.delete(id);
    // If deleting last item on last page, move one page back
    final remainingOnPage = _tasks.length - 1;
    final isLastPage = (_currentPage + 1) * _pageSize >= (_totalItems);
    final nextPage = (isLastPage && remainingOnPage == 0 && _currentPage > 0) ? _currentPage - 1 : _currentPage;
    await _load(page: nextPage);
  }

  @override
  void initState() {
    super.initState();
    _load(page: 0);
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _descCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchSubmitted(String _) => _load(page: 0);

  void _changePageSize(int size) {
    setState(() => _pageSize = size);
    _load(page: 0);
  }

  void _prevPage() {
    if (_currentPage > 0) _load(page: _currentPage - 1);
  }

  void _nextPage() {
    final totalPages = (_totalItems / _pageSize).ceil();
    if (_currentPage + 1 < totalPages) _load(page: _currentPage + 1);
  }

  @override
  Widget build(BuildContext context) {
    final totalPages = (_totalItems / _pageSize).ceil().clamp(1, 1 << 31);
    return Scaffold(
      appBar: AppBar(title: const Text('Task (sqflite)')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Search + page size
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Cari judul atau deskripsi',
                          prefixIcon: Icon(Icons.search),
                        ),
                        textInputAction: TextInputAction.search,
                        onSubmitted: _onSearchSubmitted,
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<int>(
                      value: _pageSize,
                      items: const [
                        DropdownMenuItem(value: 5, child: Text('5')),
                        DropdownMenuItem(value: 10, child: Text('10')),
                        DropdownMenuItem(value: 20, child: Text('20')),
                        DropdownMenuItem(value: 50, child: Text('50')),
                      ],
                      onChanged: (v) {
                        if (v != null) _changePageSize(v);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 8),

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
          // Paging info & controls
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                Text('Total: $_totalItems'),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _currentPage > 0 ? _prevPage : null,
                ),
                Text('Halaman ${_currentPage + 1} / ${totalPages == 0 ? 1 : totalPages}'),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: (_currentPage + 1) < totalPages ? _nextPage : null,
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