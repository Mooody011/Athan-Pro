import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class TrackerScreen extends StatefulWidget {
  const TrackerScreen({super.key});

  @override
  State<TrackerScreen> createState() => _TrackerScreenState();
}

class _TrackerScreenState extends State<TrackerScreen> {
  static const Map<String, String> _items = {
    'fajr': 'صلاة الفجر',
    'dhuhr': 'صلاة الظهر',
    'asr': 'صلاة العصر',
    'maghrib': 'صلاة المغرب',
    'isha': 'صلاة العشاء',
    'duha': 'صلاة الضحى',
    'witr': 'صلاة الوتر / قيام الليل',
    'morning_adhkar': 'أذكار الصباح',
    'evening_adhkar': 'أذكار المساء',
    'quran_wird': 'الورد اليومي من القرآن',
  };

  Map<String, bool> _todayMap = {};
  late String _todayKey;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _todayKey = 'tracker_${now.year}_${now.month}_${now.day}';
    _load();
  }

  Future<void> _load() async {
    final data = await StorageService.instance.loadBoolMap(_todayKey);
    if (mounted) setState(() => _todayMap = data);
  }

  Future<void> _toggle(String key, bool val) async {
    setState(() => _todayMap[key] = val);
    await StorageService.instance.saveBoolMap(_todayKey, _todayMap);
  }

  @override
  Widget build(BuildContext context) {
    final completed = _items.keys.where((k) => _todayMap[k] == true).length;
    final percent = ((completed / _items.length) * 100).round();

    return Scaffold(
      appBar: AppBar(title: const Text('متابع العبادات اليومية')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [Color(0xFF065F46), Color(0xFF042F2E)],
              ),
            ),
            child: Column(
              children: [
                Text(
                  '$percent%',
                  style: const TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFDE68A),
                  ),
                ),
                Text(
                  'أنجزت $completed من ${_items.length} عبادات اليوم',
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: completed / _items.length,
                  minHeight: 8,
                  backgroundColor: Colors.white24,
                  color: const Color(0xFFD4AF37),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          ..._items.entries.map((e) {
            final checked = _todayMap[e.key] == true;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: CheckboxListTile(
                title: Text(
                  e.value,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    decoration: checked ? TextDecoration.lineThrough : null,
                  ),
                ),
                value: checked,
                onChanged: (v) => _toggle(e.key, v ?? false),
              ),
            );
          }),
        ],
      ),
    );
  }
}
