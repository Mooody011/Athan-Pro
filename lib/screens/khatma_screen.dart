import 'package:flutter/material.dart';
import '../data/quran_surahs_data.dart';
import '../services/storage_service.dart';

class KhatmaScreen extends StatefulWidget {
  const KhatmaScreen({super.key});

  @override
  State<KhatmaScreen> createState() => _KhatmaScreenState();
}

class _KhatmaScreenState extends State<KhatmaScreen> {
  int _currentPage = 1;
  int _targetDays = 30;
  int _bookmarkedSurah = 1;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final p = await StorageService.instance.getInt('khatma_page', fallback: 1);
    final d = await StorageService.instance.getInt('khatma_days', fallback: 30);
    final s = await StorageService.instance.getInt('bookmark_surah', fallback: 1);
    if (mounted) {
      setState(() {
        _currentPage = p.clamp(1, 604);
        _targetDays = d.clamp(7, 120);
        _bookmarkedSurah = s.clamp(1, 114);
      });
    }
  }

  Future<void> _savePage(int p) async {
    final clamped = p.clamp(1, 604);
    setState(() => _currentPage = clamped);
    await StorageService.instance.setInt('khatma_page', clamped);
  }

  @override
  Widget build(BuildContext context) {
    final remainingPages = (604 - _currentPage).clamp(0, 604);
    final pagesPerDay = (remainingPages / _targetDays).ceil();
    final pagesPerPrayer = (pagesPerDay / 5).ceil();
    final currentJuz = ((_currentPage - 1) ~/ 20 + 1).clamp(1, 30);
    final progress = _currentPage / 604.0;
    final filtered = kQuranSurahs.where((s) => s.name.contains(_search)).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('ختمة القرآن وفهرس السور')),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'الصفحة $_currentPage من 604',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'الجزء $currentJuz',
                      style: const TextStyle(
                        color: Color(0xFFFDE68A),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: Colors.white24,
                  color: const Color(0xFFD4AF37),
                ),
                const SizedBox(height: 14),
                Text(
                  'لإنهاء الختمة في $_targetDays يوم: اقرأ $pagesPerDay صفحة يومياً (حوالي $pagesPerPrayer صفحات بعد كل صلاة).',
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    FilledButton.tonal(
                      onPressed: () => _savePage(_currentPage + 1),
                      child: const Text('+1 صفحة'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.tonal(
                      onPressed: () => _savePage(_currentPage + 4),
                      child: const Text('+4 صفحات'),
                    ),
                    const Spacer(),
                    IconButton(
                      color: Colors.white,
                      onPressed: () => _savePage(_currentPage - 1),
                      icon: const Icon(Icons.remove_circle_outline),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Text('مدة الختمة المستهدفة (أيام):'),
              Expanded(
                child: Slider(
                  value: _targetDays.toDouble(),
                  min: 7,
                  max: 90,
                  divisions: 83,
                  label: '$_targetDays يوم',
                  onChanged: (v) async {
                    setState(() => _targetDays = v.round());
                    await StorageService.instance.setInt('khatma_days', _targetDays);
                  },
                ),
              ),
              Text('$_targetDays'),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            decoration: InputDecoration(
              hintText: 'ابحث في سور القرآن الـ 114...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
            onChanged: (v) => setState(() => _search = v.trim()),
          ),
          const SizedBox(height: 10),
          ...filtered.map((s) {
            final isMarked = s.number == _bookmarkedSurah;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: isMarked
                      ? const Color(0xFFD4AF37)
                      : const Color(0xFF065F46),
                  foregroundColor: Colors.white,
                  child: Text('${s.number}'),
                ),
                title: Text('سورة ${s.name}',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${s.type} • ${s.verses} آية • الجزء ${s.juz}'),
                trailing: IconButton(
                  tooltip: 'حفظ علامة التوقف',
                  icon: Icon(
                    isMarked ? Icons.bookmark : Icons.bookmark_border,
                    color: isMarked ? const Color(0xFFD4AF37) : null,
                  ),
                  onPressed: () async {
                    setState(() => _bookmarkedSurah = s.number);
                    await StorageService.instance.setInt('bookmark_surah', s.number);
                  },
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
