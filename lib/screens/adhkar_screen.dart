import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/adhkar_data.dart';
import '../models/app_models.dart';

class AdhkarScreen extends StatefulWidget {
  final bool vibrateEnabled;
  const AdhkarScreen({super.key, required this.vibrateEnabled});

  @override
  State<AdhkarScreen> createState() => _AdhkarScreenState();
}

class _AdhkarScreenState extends State<AdhkarScreen> {
  String _selectedCategory = kAdhkarCategories.first;
  final Map<String, int> _progress = {};

  List<DhikrItem> get _currentItems =>
      kAdhkarData.where((d) => d.category == _selectedCategory).toList();

  void _tapDhikr(DhikrItem item) {
    final done = _progress[item.id] ?? 0;
    if (done >= item.count) return;
    if (widget.vibrateEnabled) {
      HapticFeedback.lightImpact();
    }
    setState(() {
      _progress[item.id] = done + 1;
    });
    if (done + 1 == item.count && widget.vibrateEnabled) {
      HapticFeedback.mediumImpact();
    }
  }

  void _resetCategory() {
    setState(() {
      for (final item in _currentItems) {
        _progress.remove(item.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = _currentItems;
    final completedCount = items.where((i) => (_progress[i.id] ?? 0) >= i.count).length;
    final ratio = items.isEmpty ? 0.0 : completedCount / items.length;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF132226) : Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text('حصن المسلم والأذكار'),
        actions: [
          IconButton(
            onPressed: _resetCategory,
            tooltip: 'تصفير عداد القسم',
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          // Category Chips
          SizedBox(
            height: 50,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              scrollDirection: Axis.horizontal,
              itemCount: kAdhkarCategories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, idx) {
                final cat = kAdhkarCategories[idx];
                final active = cat == _selectedCategory;
                return ChoiceChip(
                  label: Text(cat),
                  selected: active,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                );
              },
            ),
          ),

          // Progress Banner
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
            child: Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: ratio,
                      minHeight: 8,
                      color: const Color(0xFFD4AF37),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '$completedCount / ${items.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Adhkar Cards
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: items.length,
              itemBuilder: (_, idx) {
                final item = items[idx];
                final done = _progress[item.id] ?? 0;
                final isFinished = done >= item.count;
                final remaining = item.count - done;

                return GestureDetector(
                  onTap: () => _tapDhikr(item),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isFinished
                          ? const Color(0xFF065F46).withAlpha(isDark ? 90 : 30)
                          : cardBg,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: isFinished
                            ? const Color(0xFF10B981)
                            : Colors.grey.withAlpha(50),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          item.text,
                          style: const TextStyle(
                            fontSize: 17,
                            height: 1.8,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item.virtue,
                          style: TextStyle(
                            fontSize: 12.5,
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: isFinished
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFF0D9488),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                isFinished ? 'تم بحمد الله ✓' : 'المتبقي: $remaining',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              tooltip: 'نسخ الذكر',
                              onPressed: () {
                                Clipboard.setData(ClipboardData(text: item.text));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('تم نسخ الذكر'),
                                    duration: Duration(seconds: 1),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.copy_rounded, size: 20),
                            ),
                          ],
                        ),
                      ],
                    ),
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
