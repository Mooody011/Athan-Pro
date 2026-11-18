import 'package:flutter/material.dart';
import '../models/app_models.dart';
import '../services/audio_service.dart';
import '../services/prayer_calculator.dart';

class SettingsScreen extends StatefulWidget {
  final PrayerSettings settings;
  final ValueChanged<PrayerSettings> onUpdateSettings;

  const SettingsScreen({
    super.key,
    required this.settings,
    required this.onUpdateSettings,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  void _showCustomCoordsDialog() {
    final nameCtrl = TextEditingController(text: widget.settings.customCityName);
    final latCtrl = TextEditingController(text: widget.settings.latitude.toString());
    final lngCtrl = TextEditingController(text: widget.settings.longitude.toString());
    final tzCtrl = TextEditingController(text: widget.settings.timezone.toString());

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إدخال إحداثيات موقع مخصص'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'اسم المدينة'),
              ),
              TextField(
                controller: latCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: const InputDecoration(labelText: 'خط العرض (Latitude)'),
              ),
              TextField(
                controller: lngCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: const InputDecoration(labelText: 'خط الطول (Longitude)'),
              ),
              TextField(
                controller: tzCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: const InputDecoration(labelText: 'فرق التوقيت (UTC مثل 2 أو 3)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          FilledButton(
            onPressed: () {
              final lat = double.tryParse(latCtrl.text.trim());
              final lng = double.tryParse(lngCtrl.text.trim());
              final tz = double.tryParse(tzCtrl.text.trim());
              if (lat != null && lng != null && tz != null) {
                widget.onUpdateSettings(
                  widget.settings.copyWith(
                    customCityName: nameCtrl.text.trim().isEmpty ? 'موقعي' : nameCtrl.text.trim(),
                    latitude: lat,
                    longitude: lng,
                    timezone: tz,
                    useCustomCoords: true,
                  ),
                );
              }
              Navigator.pop(ctx);
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.settings;

    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('حساب المواقيت', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: PrayerCalculator.methods.containsKey(s.calculationMethod)
                ? s.calculationMethod
                : 'egypt',
            decoration: InputDecoration(
              labelText: 'طريقة الحساب الفلكية',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
            ),
            items: PrayerCalculator.methods.values
                .map((m) => DropdownMenuItem(value: m.id, child: Text(m.nameAr)))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                widget.onUpdateSettings(s.copyWith(calculationMethod: v));
              }
            },
          ),
          const SizedBox(height: 10),
          SwitchListTile(
            title: const Text('المذهب الحنفي (تأخير وقت العصر)'),
            subtitle: const Text('افتراضياً: المذهب الشافعي / الجمهور'),
            value: s.isHanafi,
            onChanged: (v) => widget.onUpdateSettings(s.copyWith(isHanafi: v)),
          ),
          ListTile(
            title: const Text('تعديل التاريخ الهجري'),
            subtitle: Text('الإزاحة الحالية: ${s.hijriOffset >= 0 ? '+${s.hijriOffset}' : s.hijriOffset} يوم'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: s.hijriOffset > -2
                      ? () => widget.onUpdateSettings(s.copyWith(hijriOffset: s.hijriOffset - 1))
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                IconButton(
                  onPressed: s.hijriOffset < 2
                      ? () => widget.onUpdateSettings(s.copyWith(hijriOffset: s.hijriOffset + 1))
                      : null,
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.my_location_rounded),
            title: const Text('إدخال إحداثيات يدوية (Lat / Lng / UTC)'),
            subtitle: Text('${s.latitude.toStringAsFixed(3)}, ${s.longitude.toStringAsFixed(3)} (UTC ${s.timezone})'),
            onTap: _showCustomCoordsDialog,
          ),

          const Divider(height: 28),
          const Text('صوت الآذان والمظهر', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),

          ...AudioService.muezzins.map((m) {
            final selected = s.muezzinId == m.id;
            return RadioListTile<String>(
              title: Text(m.nameAr),
              subtitle: Text(m.subtitle, style: const TextStyle(fontSize: 12)),
              value: m.id,
              groupValue: s.muezzinId,
              secondary: IconButton(
                icon: const Icon(Icons.play_circle_outline),
                onPressed: () async {
                  final msg = await AudioService.instance.playMuezzin(m.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
                    );
                  }
                },
              ),
              onChanged: (v) {
                if (v != null) widget.onUpdateSettings(s.copyWith(muezzinId: v));
              },
              selected: selected,
            );
          }),

          SwitchListTile(
            title: const Text('الوضع الليلي الداكن'),
            value: s.isDarkMode,
            onChanged: (v) => widget.onUpdateSettings(s.copyWith(isDarkMode: v)),
          ),
          SwitchListTile(
            title: const Text('نظام 24 ساعة'),
            value: s.use24Hour,
            onChanged: (v) => widget.onUpdateSettings(s.copyWith(use24Hour: v)),
          ),
          SwitchListTile(
            title: const Text('الاهتزاز عند التسبيح والأذكار'),
            value: s.vibrateEnabled,
            onChanged: (v) => widget.onUpdateSettings(s.copyWith(vibrateEnabled: v)),
          ),

          const Divider(height: 28),
          const Text('تعديل الدقائق يدوياً لكل صلاة', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          ...const {
            'fajr': 'الفجر',
            'sunrise': 'الشروق',
            'dhuhr': 'الظهر',
            'asr': 'العصر',
            'maghrib': 'المغرب',
            'isha': 'العشاء',
          }.entries.map((e) {
            final val = s.minuteAdjustments[e.key] ?? 0;
            return ListTile(
              title: Text(e.value),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: val > -15
                        ? () {
                            final m = Map<String, int>.from(s.minuteAdjustments);
                            m[e.key] = val - 1;
                            widget.onUpdateSettings(s.copyWith(minuteAdjustments: m));
                          }
                        : null,
                  ),
                  Text('${val >= 0 ? '+$val' : val} د'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: val < 15
                        ? () {
                            final m = Map<String, int>.from(s.minuteAdjustments);
                            m[e.key] = val + 1;
                            widget.onUpdateSettings(s.copyWith(minuteAdjustments: m));
                          }
                        : null,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
