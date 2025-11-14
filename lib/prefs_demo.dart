import 'dart:convert';
import 'package:flutter/services.dart';
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
  bool _notifications = false;
  String _language = 'id';

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  // Memuat data 'greeting', 'darkMode', 'notifications' dan 'language'
  Future<void> _loadPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final greeting = prefs.getString('greeting') ?? '';
    final dark = prefs.getBool('darkMode') ?? false;
    final notifications = prefs.getBool('notificationsEnabled') ?? false;
    final language = prefs.getString('language') ?? 'id';
    if (mounted) {
      setState(() {
        _storedText = greeting;
        _controller.text = greeting; // isi TextField dengan nilai yang tersimpan
        _darkMode = dark;
        _notifications = notifications;
        _language = language;
      });
    }
  }

  // Menyimpan teks salam
  Future<void> _saveText() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('greeting', text);
    if (mounted) {
      setState(() {
        _storedText = text;
        _controller.clear();
      });
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tersimpan')),
      );
    }
  }

  // Mengubah status mode gelap dan menyimpan
  Future<void> _toggleDarkMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', value);
    if (mounted) {
      setState(() => _darkMode = value);
    }
  }

  // Toggle notifikasi
  Future<void> _toggleNotifications(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
    if (mounted) setState(() => _notifications = value);
  }

  // Simpan bahasa yang dipilih
  Future<void> _saveLanguage(String? code) async {
    if (code == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', code);
    if (mounted) setState(() => _language = code);
  }

  // Ekspor preferensi ke JSON dan salin ke clipboard
  Future<void> _exportPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final map = <String, dynamic>{
      'greeting': prefs.getString('greeting'),
      'darkMode': prefs.getBool('darkMode'),
      'notificationsEnabled': prefs.getBool('notificationsEnabled'),
      'language': prefs.getString('language'),
    };
    final jsonText = const JsonEncoder.withIndent('  ').convert(map);
    await Clipboard.setData(ClipboardData(text: jsonText));
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preferensi disalin ke clipboard (JSON)')),
      );
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

              // Notifikasi
              SwitchListTile(
                title: const Text('Notifikasi'),
                subtitle: const Text('Aktifkan notifikasi aplikasi'),
                value: _notifications,
                onChanged: _toggleNotifications,
              ),

              const SizedBox(height: 8),

              // Pilihan bahasa
              DropdownButtonFormField<String>(
                initialValue: _language,
                decoration: const InputDecoration(
                  labelText: 'Bahasa',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'id', child: Text('Bahasa Indonesia')),
                  DropdownMenuItem(value: 'en', child: Text('English')),
                ],
                onChanged: (v) => _saveLanguage(v),
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

              // Tombol ekspor JSON
              ElevatedButton(
                onPressed: _exportPrefs,
                child: const Text('Ekspor preferensi (JSON)'),
              ),

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