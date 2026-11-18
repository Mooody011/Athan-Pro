import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/storage_service.dart';

class TasbihScreen extends StatefulWidget {
  final bool vibrateEnabled;
  const TasbihScreen({super.key, required this.vibrateEnabled});

  @override
  State<TasbihScreen> createState() => _TasbihScreenState();
}

class _TasbihScreenState extends State<TasbihScreen> {
  List<String> _phrases = [
    'سبحان الله',
    'الحمد لله',
    'الله أكبر',
    'لا إله إلا الله',
    'أستغفر الله العظيم',
    'اللهم صلِّ وسلم على نبينا محمد',
    'لا حول ولا قوة إلا بالله',
  ];

  String _selectedPhrase = 'سبحان الله';
  int _count = 0;
  int _target = 33; // 0 means unlimited
  int _totalAllTime = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final total = await StorageService.instance.getInt('tasbih_total');
    final custom = await StorageService.instance.getStringList('tasbih_custom');
    if (mounted) {
      setState(() {
        _totalAllTime = total;
        for (final c in custom) {
          if (!_phrases.contains(c)) _phrases.add(c);
        }
      });
    }
  }

  Future<void> _increment() async {
    if (widget.vibrateEnabled) {
      HapticFeedback.lightImpact();
    }
    setState(() {
      _count++;
      _totalAllTime++;
      if (_target > 0 && _count == _target && widget.vibrateEnabled) {
        HapticFeedback.heavyImpact();
      }
    });
    await StorageService.instance.setInt('tasbih_total', _totalAllTime);
  }

  void _addCustomDhikr() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إضافة ذكر مخصص'),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(hintText: 'اكتب الذكر هنا...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () async {
              final text = ctrl.text.trim();
              if (text.isNotEmpty) {
                setState(() {
                  if (!_phrases.contains(text)) _phrases.add(text);
                  _selectedPhrase = text;
                  _count = 0;
                });
                final custom = await StorageService.instance.getStringList('tasbih_custom');
                if (!custom.contains(text)) {
                  custom.add(text);
                  await StorageService.instance.setStringList('tasbih_custom', custom);
                }
              }
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gold = const Color(0xFFD4AF37);
    final progress = _target > 0 ? (_count % _target == 0 && _count > 0 ? 1.0 : (_count % _target) / _target) : 1.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('السبحة الإلكترونية'),
        actions: [
          IconButton(
            tooltip: 'إضافة ذكر مخصص',
            onPressed: _addCustomDhikr,
            icon: const Icon(Icons.add_circle_outline),
          ),
          IconButton(
            tooltip: 'تصفير العداد',
            onPressed: () => setState(() => _count = 0),
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Phrases selector
            SizedBox(
              height: 44,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _phrases.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final p = _phrases[i];
                  return ChoiceChip(
                    label: Text(p),
                    selected: p == _selectedPhrase,
                    onSelected: (_) => setState(() {
                      _selectedPhrase = p;
                      _count = 0;
                    }),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),

            // Target selector
            Wrap(
              spacing: 8,
              children: [33, 99, 100, 1000, 0].map((t) {
                return ChoiceChip(
                  label: Text(t == 0 ? 'مفتوح' : '$t'),
                  selected: _target == t,
                  onSelected: (_) => setState(() => _target = t),
                );
              }).toList(),
            ),

            const Spacer(),
            Text(
              _selectedPhrase,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),

            // Main Tap Circle
            GestureDetector(
              onTap: _increment,
              child: SizedBox(
                width: 230,
                height: 230,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 230,
                      height: 230,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 10,
                        backgroundColor: Colors.grey.withAlpha(50),
                        valueColor: AlwaysStoppedAnimation<Color>(gold),
                      ),
                    ),
                    Container(
                      width: 196,
                      height: 196,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF065F46), Color(0xFF042F2E)],
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF065F46).withAlpha(110),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$_count',
                            style: const TextStyle(
                              fontSize: 54,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          if (_target > 0)
                            Text(
                              'الهدف: $_target',
                              style: TextStyle(color: gold, fontSize: 13),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),

            // Total stats bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(100),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('إجمالي تسبيحاتك الكلي:', style: TextStyle(fontSize: 15)),
                  Text(
                    '$_totalAllTime',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: gold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
