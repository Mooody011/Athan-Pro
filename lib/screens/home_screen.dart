import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/cities_data.dart';
import '../models/app_models.dart';
import '../services/audio_service.dart';
import '../services/prayer_calculator.dart';

class HomeScreen extends StatefulWidget {
  final PrayerSettings settings;
  final ValueChanged<PrayerSettings> onUpdateSettings;

  const HomeScreen({
    super.key,
    required this.settings,
    required this.onUpdateSettings,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Timer _timer;
  DateTime _now = DateTime.now();
  String? _lastTriggeredKey;
  bool _isPlayingAudio = false;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      final current = DateTime.now();
      setState(() => _now = current);
      _checkPrayerAlert(current);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _checkPrayerAlert(DateTime current) {
    final schedule = PrayerCalculator.calculateForDate(current, widget.settings);
    for (final entry in schedule.entries) {
      final enabled = widget.settings.prayerAlerts[entry.key] ?? false;
      if (!enabled) continue;
      final diff = current.difference(entry.time).inSeconds;
      final triggerId = '${current.year}-${current.month}-${current.day}-${entry.key}';
      if (diff >= 0 && diff <= 2 && _lastTriggeredKey != triggerId) {
        _lastTriggeredKey = triggerId;
        if (widget.settings.vibrateEnabled) {
          HapticFeedback.heavyImpact();
        }
        AudioService.instance.playMuezzin(widget.settings.muezzinId);
        if (mounted) {
          setState(() => _isPlayingAudio = true);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('حان الآن موعد أذان ${entry.nameAr}'),
              duration: const Duration(seconds: 8),
              action: SnackBarAction(
                label: 'إيقاف الصوت',
                onPressed: _stopAudio,
              ),
            ),
          );
        }
      }
    }
  }

  Future<void> _toggleAudioTest() async {
    if (_isPlayingAudio || AudioService.instance.isPlaying) {
      await _stopAudio();
    } else {
      setState(() => _isPlayingAudio = true);
      final msg = await AudioService.instance.playMuezzin(widget.settings.muezzinId);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(msg), duration: const Duration(seconds: 3)),
        );
      }
    }
  }

  Future<void> _stopAudio() async {
    await AudioService.instance.stop();
    if (mounted) {
      setState(() => _isPlayingAudio = false);
    }
  }

  String _currentCityTitle() {
    if (widget.settings.useCustomCoords) {
      return widget.settings.customCityName;
    }
    final city = kCitiesData.firstWhere(
      (c) => c.id == widget.settings.cityId,
      orElse: () => kCitiesData.first,
    );
    return '${city.nameAr}، ${city.countryAr}';
  }

  void _showCityPicker() {
    String query = '';
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final filtered = kCitiesData.where((c) {
              return c.nameAr.contains(query) || c.countryAr.contains(query);
            }).toList();

            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.72,
              maxChildSize: 0.92,
              builder: (_, scrollCtrl) {
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Container(
                        width: 42,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey.withAlpha(120),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'اختر مدينتك',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        decoration: InputDecoration(
                          hintText: 'ابحث باسم المدينة أو الدولة...',
                          prefixIcon: const Icon(Icons.search),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onChanged: (v) => setModalState(() => query = v.trim()),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          controller: scrollCtrl,
                          itemCount: filtered.length,
                          itemBuilder: (_, i) {
                            final c = filtered[i];
                            final selected = !widget.settings.useCustomCoords &&
                                widget.settings.cityId == c.id;
                            return ListTile(
                              leading: Icon(
                                Icons.location_on_outlined,
                                color: selected ? const Color(0xFFD4AF37) : null,
                              ),
                              title: Text(c.nameAr,
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                              subtitle: Text(c.countryAr),
                              trailing: selected
                                  ? const Icon(Icons.check_circle, color: Color(0xFFD4AF37))
                                  : null,
                              onTap: () {
                                widget.onUpdateSettings(
                                  widget.settings.copyWith(
                                    cityId: c.id,
                                    customCityName: c.nameAr,
                                    latitude: c.latitude,
                                    longitude: c.longitude,
                                    timezone: c.timezone,
                                    calculationMethod: c.defaultMethod,
                                    useCustomCoords: false,
                                  ),
                                );
                                Navigator.pop(ctx);
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final schedule = PrayerCalculator.calculateForDate(_now, widget.settings);
    final tomorrowSchedule = PrayerCalculator.calculateForDate(
      _now.add(const Duration(days: 1)),
      widget.settings,
    );

    PrayerTimeEntry nextPrayer = tomorrowSchedule.entries.first;
    DateTime prevTime = schedule.entries.last.time;

    for (int i = 0; i < schedule.entries.length; i++) {
      if (schedule.entries[i].time.isAfter(_now)) {
        nextPrayer = schedule.entries[i];
        prevTime = i == 0
            ? schedule.entries.last.time.subtract(const Duration(days: 1))
            : schedule.entries[i - 1].time;
        break;
      }
    }

    final remaining = nextPrayer.time.difference(_now);
    final totalSpan = nextPrayer.time.difference(prevTime).inSeconds;
    final elapsed = _now.difference(prevTime).inSeconds;
    final progress = totalSpan > 0 ? (elapsed / totalSpan).clamp(0.0, 1.0) : 0.0;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF132226) : Colors.white;
    final gold = const Color(0xFFD4AF37);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          children: [
            // Top Header
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _showCityPicker,
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                      child: Row(
                        children: [
                          Icon(Icons.location_on, color: gold, size: 22),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              _currentCityTitle(),
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.keyboard_arrow_down, size: 20),
                        ],
                      ),
                    ),
                  ),
                ),
                IconButton.filledTonal(
                  onPressed: _toggleAudioTest,
                  tooltip: _isPlayingAudio ? 'إيقاف الآذان' : 'تجربة صوت الآذان',
                  icon: Icon(_isPlayingAudio ? Icons.stop_rounded : Icons.volume_up_rounded),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Hero Countdown Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0xFF065F46),
                    Color(0xFF064E3B),
                    Color(0xFF042F2E),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF064E3B).withAlpha(90),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(28),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          PrayerCalculator.formatHijriDate(
                            _now,
                            offsetDays: widget.settings.hijriOffset,
                          ),
                          style: const TextStyle(
                            color: Color(0xFFFDE68A),
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Text(
                        PrayerCalculator.formatGregorianDateAr(_now),
                        style: TextStyle(
                          color: Colors.white.withAlpha(210),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'الصلاة القادمة: ${nextPrayer.nameAr}',
                          style: TextStyle(
                            color: Colors.white.withAlpha(220),
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          PrayerCalculator.formatCountdown(remaining),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 42,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'موعدها ${PrayerCalculator.formatTime(nextPrayer.time, use24Hour: widget.settings.use24Hour)}',
                          style: const TextStyle(
                            color: Color(0xFFFDE68A),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 7,
                      backgroundColor: Colors.white.withAlpha(35),
                      valueColor: AlwaysStoppedAnimation<Color>(gold),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),
            const Text(
              'مواقيت الصلاة اليوم',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // Prayer Times List
            ...schedule.entries.map((entry) {
              final isNext = entry.key == nextPrayer.key &&
                  nextPrayer.time.day == _now.day;
              final alertOn = widget.settings.prayerAlerts[entry.key] ?? false;

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isNext ? gold : Colors.grey.withAlpha(45),
                    width: isNext ? 1.8 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _iconForPrayer(entry.key),
                      color: isNext ? gold : const Color(0xFF0D9488),
                      size: 24,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.nameAr,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isNext ? gold : null,
                            ),
                          ),
                          if (isNext)
                            Text(
                              'الصلاة القادمة',
                              style: TextStyle(
                                fontSize: 11,
                                color: gold.withAlpha(220),
                              ),
                            ),
                        ],
                      ),
                    ),
                    Text(
                      PrayerCalculator.formatTime(
                        entry.time,
                        use24Hour: widget.settings.use24Hour,
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isNext ? gold : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: () {
                        final updated = Map<String, bool>.from(
                          widget.settings.prayerAlerts,
                        );
                        updated[entry.key] = !alertOn;
                        widget.onUpdateSettings(
                          widget.settings.copyWith(prayerAlerts: updated),
                        );
                      },
                      icon: Icon(
                        alertOn
                            ? Icons.notifications_active_rounded
                            : Icons.notifications_off_outlined,
                        color: alertOn ? const Color(0xFF10B981) : Colors.grey,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              );
            }),

            const SizedBox(height: 8),

            // Qiyam & Midnight Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: Colors.grey.withAlpha(45)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        const Icon(Icons.nightlight_round, color: Color(0xFF818CF8)),
                        const SizedBox(height: 6),
                        const Text('منتصف الليل', style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 2),
                        Text(
                          PrayerCalculator.formatTime(
                            schedule.midnight,
                            use24Hour: widget.settings.use24Hour,
                          ),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 48, color: Colors.grey.withAlpha(60)),
                  Expanded(
                    child: Column(
                      children: [
                        Icon(Icons.auto_awesome, color: gold),
                        const SizedBox(height: 6),
                        const Text('الثلث الأخير (القيام)', style: TextStyle(fontSize: 12)),
                        const SizedBox(height: 2),
                        Text(
                          PrayerCalculator.formatTime(
                            schedule.lastThird,
                            use24Hour: widget.settings.use24Hour,
                          ),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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

  IconData _iconForPrayer(String key) {
    switch (key) {
      case 'fajr':
        return Icons.wb_twilight_rounded;
      case 'sunrise':
        return Icons.wb_sunny_outlined;
      case 'dhuhr':
        return Icons.wb_sunny_rounded;
      case 'asr':
        return Icons.sunny_snowing;
      case 'maghrib':
        return Icons.nights_stay_outlined;
      default:
        return Icons.bedtime_rounded;
    }
  }
}
