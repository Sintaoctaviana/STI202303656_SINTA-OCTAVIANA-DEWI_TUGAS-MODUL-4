// BAB 2 File Storage

import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class FileDemoPage extends StatefulWidget {
  const FileDemoPage({super.key});

  @override
  State<FileDemoPage> createState() => _FileDemoPageState();
}

class _FileDemoPageState extends State<FileDemoPage> {
  int _counter = 0;

  // Profile controllers/state
  final TextEditingController _nameCtrl = TextEditingController();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _ageCtrl = TextEditingController();
  Map<String, dynamic>? _profile;

  // Mendapatkan path file counter.txt
  Future<File> get _localFile async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/counter.txt');
  }

  // Profile file
  Future<File> get _profileFile async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/profile.json');
  }

  // Membaca counter dari file
  Future<void> _readCounter() async {
    try {
      final file = await _localFile;
      final content = await file.readAsString();
      if (mounted) {
        setState(() => _counter = int.tryParse(content) ?? 0);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _counter = 0);
      }
    }
  }

  // Menulis counter ke file
  Future<void> _writeCounter(int value) async {
    final file = await _localFile;
    await file.writeAsString('$value');
  }

  // Load profile from profile.json
  Future<void> _loadProfile() async {
    try {
      final file = await _profileFile;
      if (!await file.exists()) {
        if (mounted) setState(() => _profile = null);
        return;
      }
      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;
      if (mounted) {
        setState(() {
          _profile = data;
          _nameCtrl.text = data['name'] ?? '';
          _emailCtrl.text = data['email'] ?? '';
          _ageCtrl.text = (data['age']?.toString() ?? '');
        });
      }
    } catch (_) {
      if (mounted) setState(() => _profile = null);
    }
  }

  // Save profile to profile.json
  Future<void> _saveProfile() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final age = int.tryParse(_ageCtrl.text.trim());
    if (name.isEmpty && email.isEmpty && age == null) return;
    final map = <String, dynamic>{
      'name': name,
      'email': email,
      'age': age,
      'savedAt': DateTime.now().toIso8601String(),
    };
    final file = await _profileFile;
    await file.writeAsString(const JsonEncoder.withIndent('  ').convert(map));
    if (mounted) {
      setState(() {
        _profile = map;
        _nameCtrl.clear();
        _emailCtrl.clear();
        _ageCtrl.clear();
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile disimpan ke profile.json')),
      );
    }
  }

  // Delete profile file
  Future<void> _deleteProfile() async {
    try {
      final file = await _profileFile;
      if (await file.exists()) {
        await file.delete();
      }
      if (mounted) {
        setState(() => _profile = null);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('profile.json dihapus')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menghapus: $e')),
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _readCounter();
    _loadProfile();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _ageCtrl.dispose();
    super.dispose();
  }

  Widget _buildProfileView() {
    if (_profile == null) {
      return const Text('(Tidak ada profile tersimpan)');
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Nama: ${_profile!['name'] ?? ''}'),
        Text('Email: ${_profile!['email'] ?? ''}'),
        Text('Umur: ${_profile!['age'] ?? ''}'),
        Text('Tersimpan: ${_profile!['savedAt'] ?? ''}'),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('File Demo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Center(
              child:
                  Text('Counter: $_counter', style: const TextStyle(fontSize: 24)),
            ),
            const SizedBox(height: 16),

            // Profile section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Profile (profile.json)', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildProfileView(),
                    const Divider(),
                    TextField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(labelText: 'Nama'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailCtrl,
                      decoration: const InputDecoration(labelText: 'Email'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _ageCtrl,
                      decoration: const InputDecoration(labelText: 'Umur'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saveProfile,
                            child: const Text('Simpan profile'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: _deleteProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                          ),
                          child: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Controls for counter
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  onPressed: () async {
                    setState(() => _counter += 1);
                    await _writeCounter(_counter);
                  },
                  child: const Icon(Icons.add),
                ),
                const SizedBox(width: 16),
                FloatingActionButton(
                  onPressed: () async {
                    setState(() => _counter = 0);
                    await _writeCounter(_counter);
                  },
                  mini: true,
                  child: const Icon(Icons.refresh),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}