// INTEGRASI

import 'package:flutter/material.dart';
import 'prefs_demo.dart';
import 'file_demo.dart';
import 'task_sqflite_page.dart';
import 'task_floor_page.dart';
import 'task_api_page.dart';

void main() => runApp(const DataPlaygroundApp());

class DataPlaygroundApp extends StatelessWidget {
  const DataPlaygroundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Data Playground',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const HomeTabs(),
    );
  }
}

class HomeTabs extends StatefulWidget {
  const HomeTabs({super.key});

  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> with TickerProviderStateMixin {
  late final TabController _tab = TabController(length: 5, vsync: this);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Playground'),
        bottom: TabBar(
          controller: _tab,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Prefs'),
            Tab(text: 'File'),
            Tab(text: 'sqflite'),
            Tab(text: 'Floor'),
            Tab(text: 'API'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [
          PrefsDemoPage(),
          FileDemoPage(),
          TaskSqflitePage(),
          TaskFloorPage(),
          TaskApiPage(),
        ],
      ),
    );
  }
}