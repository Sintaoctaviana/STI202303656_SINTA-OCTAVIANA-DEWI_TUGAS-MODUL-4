import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrefsDemoPage extends StatefulWidget {
  const PrefsDemoPage({super.key});

  @override
  State<PrefsDemoPage> createState() => _PrefsDemoPageState();
}

class _PrefsDemoPageState extends State<PrefsDemoPage> {
  final TextEditingController _controller = TextEditingController();
  String _storedText = '';
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  // Memuat data 'greeting' dan 'darkMode'
  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _storedText = prefs.getString('greeting') ?? '';
        _darkMode = prefs.getBool('darkMode') ?? false;
      });
    }
  }

  // Menyimpan teks salam
  Future<void> _saveText() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('greeting', _controller.text);
    _controller.clear();
    _loadPrefs();
  }

  // Mengubah status mode gelap dan menyimpan
  Future<void> _toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    if (mounted) {
      setState(() => _darkMode = value);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Tema lokal untuk demo mode gelap
    final theme = ThemeData(
      brightness: _darkMode ? Brightness.dark : Brightness.light,
      useMaterial3: true,
      colorSchemeSeed: Colors.indigo,
    );

    return Theme(
      data: theme,
      child: Scaffold(
        appBar: AppBar(title: const Text('Prefs Demo')),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SwitchListTile(
                title: const Text('Mode Gelap'),
                value: _darkMode,
                onChanged: _toggleDarkMode,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _controller,
                decoration: const InputDecoration(
                  labelText: 'Tulis salam',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _saveText, child: const Text('Simpan')),
              const SizedBox(height: 12),
              Text(
                'Tersimpan: ${_storedText.isEmpty ? "(kosong)" : _storedText}',
              ),
            ],
          ),
        ),
      ),
    );
  }
}