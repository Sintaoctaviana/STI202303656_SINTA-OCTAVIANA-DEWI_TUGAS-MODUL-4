import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'task_api_model.dart';
import 'task_api_service.dart';

// Analisis: Gunakan instance Dio dan ApiService sebagai variabel global/singleton
// agar mudah diakses.
final Dio _dio = Dio();
final TaskApiService _apiService = TaskApiService(_dio);

class TaskApiPage extends StatefulWidget {
  const TaskApiPage({super.key});

  @override
  State<TaskApiPage> createState() => _TaskApiPageState();
}

class _TaskApiPageState extends State<TaskApiPage> {
  List<TaskDto> _tasks = [];
  bool _isLoading = false;
  final _titleCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // --- Operasi CRUD ke API ---

  // READ: Mengambil semua tugas dari API
  Future<void> _loadTasks() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Hanya mengambil 5 tugas pertama untuk demo
      final allTasks = await _apiService.getTasks();
      if (mounted) {
        // Mengambil 5 task dan membalikkannya agar yang terbaru di atas
        setState(() {
          _tasks = allTasks.take(5).toList().reversed.toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      _showErrorSnackBar('Gagal memuat tugas: $e');
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // CREATE: Menambahkan tugas baru
  Future<void> _addTask() async {
    if (_titleCtrl.text.trim().isEmpty) return;

    // Model tugas baru yang akan dikirim (isCompleted default ke false)
    final newTask = TaskDto(
      title: _titleCtrl.text,
      description: 'Task baru dari Flutter',
    );

    try {
      // Mengirim POST request
      final createdTask = await _apiService.createTask(newTask);

      // Setelah berhasil, tambahkan ke daftar lokal dan muat ulang UI
      if (mounted) {
        setState(() {
          // Menambahkan tugas yang dibuat ke bagian atas daftar (ID 201+ jika pakai JSONPlaceholder)
          _tasks.insert(0, createdTask);
        });
        _titleCtrl.clear();
      }
      _showSuccessSnackBar('Tugas berhasil dibuat! ID: ${createdTask.id}');
    } catch (e) {
      _showErrorSnackBar('Gagal menambah tugas: $e');
    }
  }

  // UPDATE: Mengubah status isCompleted
  Future<void> _toggleComplete(TaskDto task) async {
    // Membuat objek TaskDto baru untuk update
    final updatedTask = TaskDto(
      id: task.id,
      title: task.title,
      description: task.description,
      isCompleted: !task.isCompleted, // Toggle status
    );

    try {
      // Mengirim PUT request ke API
      await _apiService.updateTask(task.id!, updatedTask);

      // Jika berhasil di API, update state lokal
      if (mounted) {
        setState(() {
          final index = _tasks.indexWhere((t) => t.id == task.id);
          if (index != -1) {
            _tasks[index] = updatedTask;
          }
        });
      }
      _showSuccessSnackBar('Tugas ID ${task.id} diupdate!');
    } catch (e) {
      _showErrorSnackBar('Gagal update tugas: $e');
    }
  }

  // DELETE: Menghapus tugas
  Future<void> _delete(TaskDto task) async {
    try {
      // Mengirim DELETE request
      await _apiService.deleteTask(task.id!);

      // Jika berhasil di API, hapus dari daftar lokal
      if (mounted) {
        setState(() {
          _tasks.removeWhere((t) => t.id == task.id);
        });
      }
      _showSuccessSnackBar('Tugas ID ${task.id} dihapus!');
    } catch (e) {
      // Catatan: JSONPlaceholder seringkali mengembalikan status 404/500 setelah DELETE,
      // tetapi kita tetap menghapusnya secara lokal untuk demonstrasi.
      _showErrorSnackBar('Gagal hapus tugas: $e');
    }
  }

  // --- Utilitas UI ---

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    }
  }

  void _showSuccessSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.green),
      );
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                TextField(
                  controller: _titleCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Judul Tugas (API)',
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.http),
                  ),
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: _addTask,
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah ke API'),
                ),
              ],
            ),
          ),
          const Divider(),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: LinearProgressIndicator(),
            ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadTasks,
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (_, i) {
                  final t = _tasks[i];
                  return ListTile(
                    title: Text(t.title),
                    subtitle: Text('ID: ${t.id}'),
                    leading: IconButton(
                      icon: Icon(
                        t.isCompleted
                            ? Icons.check_box
                            : Icons.check_box_outline_blank,
                      ),
                      onPressed: t.id != null ? () => _toggleComplete(t) : null,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: t.id != null ? () => _delete(t) : null,
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}