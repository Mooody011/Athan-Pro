import 'package:flutter/material.dart';
import '../models/app_models.dart';
import 'khatma_screen.dart';
import 'names_screen.dart';
import 'settings_screen.dart';
import 'tracker_screen.dart';
import 'zakat_screen.dart';

class MoreScreen extends StatelessWidget {
  final PrayerSettings settings;
  final ValueChanged<PrayerSettings> onUpdateSettings;

  const MoreScreen({
    super.key,
    required this.settings,
    required this.onUpdateSettings,
  });

  @override
  Widget build(BuildContext context) {
    final features = [
      (
        'ختمة القرآن الكريم',
        'متابعة الـ 30 جزءاً والـ 114 سورة',
        Icons.menu_book_rounded,
        const Color(0xFF0D9488),
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const KhatmaScreen())),
      ),
      (
        'أسماء الله الحسنى',
        'الـ 99 اسماً مع المعاني والبحث',
        Icons.auto_awesome_rounded,
        const Color(0xFFD4AF37),
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NamesOfAllahScreen())),
      ),
      (
        'متابع العبادات',
        'سجل الفروض والسنن والورد اليومي',
        Icons.check_circle_outline_rounded,
        const Color(0xFF10B981),
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TrackerScreen())),
      ),
      (
        'حاسبة الزكاة',
        'حساب زكاة المال والذهب والنصاب',
        Icons.calculate_rounded,
        const Color(0xFF6366F1),
        () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ZakatScreen())),
      ),
      (
        'الإعدادات والمؤذن',
        'طريقة الحساب، المذهب، الصوت، والمظهر',
        Icons.settings_rounded,
        const Color(0xFFF59E0B),
        () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SettingsScreen(
                  settings: settings,
                  onUpdateSettings: onUpdateSettings,
                ),
              ),
            ),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('إضافات آذان برو')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: features.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (_, i) {
          final item = features[i];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              leading: CircleAvatar(
                radius: 24,
                backgroundColor: item.$4.withAlpha(35),
                child: Icon(item.$3, color: item.$4, size: 26),
              ),
              title: Text(item.$1, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              subtitle: Text(item.$2, style: const TextStyle(fontSize: 12.5)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: item.$5,
            ),
          );
        },
      ),
    );
  }
}
