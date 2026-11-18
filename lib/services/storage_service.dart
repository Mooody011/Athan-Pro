import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/app_models.dart';

class StorageService {
  StorageService._();
  static final StorageService instance = StorageService._();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  Future<PrayerSettings> loadSettings() async {
    await init();
    final p = _prefs!;
    final alertsRaw = p.getString('prayer_alerts');
    final adjRaw = p.getString('minute_adjustments');

    Map<String, bool> alerts = const {
      'fajr': true,
      'sunrise': false,
      'dhuhr': true,
      'asr': true,
      'maghrib': true,
      'isha': true,
    };
    if (alertsRaw != null) {
      final decoded = jsonDecode(alertsRaw) as Map<String, dynamic>;
      alerts = decoded.map((k, v) => MapEntry(k, v == true));
    }

    Map<String, int> adj = const {
      'fajr': 0,
      'sunrise': 0,
      'dhuhr': 0,
      'asr': 0,
      'maghrib': 0,
      'isha': 0,
    };
    if (adjRaw != null) {
      final decoded = jsonDecode(adjRaw) as Map<String, dynamic>;
      adj = decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
    }

    return PrayerSettings(
      cityId: p.getString('city_id') ?? 'cairo',
      customCityName: p.getString('custom_city_name') ?? 'القاهرة',
      latitude: p.getDouble('latitude') ?? 30.0444,
      longitude: p.getDouble('longitude') ?? 31.2357,
      timezone: p.getDouble('timezone') ?? 2.0,
      useCustomCoords: p.getBool('use_custom_coords') ?? false,
      calculationMethod: p.getString('calc_method') ?? 'egypt',
      isHanafi: p.getBool('is_hanafi') ?? false,
      hijriOffset: p.getInt('hijri_offset') ?? 0,
      isDarkMode: p.getBool('is_dark_mode') ?? true,
      use24Hour: p.getBool('use_24_hour') ?? false,
      muezzinId: p.getString('muezzin_id') ?? 'offline_chime',
      vibrateEnabled: p.getBool('vibrate_enabled') ?? true,
      prayerAlerts: alerts,
      minuteAdjustments: adj,
    );
  }

  Future<void> saveSettings(PrayerSettings s) async {
    await init();
    final p = _prefs!;
    await p.setString('city_id', s.cityId);
    await p.setString('custom_city_name', s.customCityName);
    await p.setDouble('latitude', s.latitude);
    await p.setDouble('longitude', s.longitude);
    await p.setDouble('timezone', s.timezone);
    await p.setBool('use_custom_coords', s.useCustomCoords);
    await p.setString('calc_method', s.calculationMethod);
    await p.setBool('is_hanafi', s.isHanafi);
    await p.setInt('hijri_offset', s.hijriOffset);
    await p.setBool('is_dark_mode', s.isDarkMode);
    await p.setBool('use_24_hour', s.use24Hour);
    await p.setString('muezzin_id', s.muezzinId);
    await p.setBool('vibrate_enabled', s.vibrateEnabled);
    await p.setString('prayer_alerts', jsonEncode(s.prayerAlerts));
    await p.setString('minute_adjustments', jsonEncode(s.minuteAdjustments));
  }

  // Tasbih persistence
  Future<int> getInt(String key, {int fallback = 0}) async {
    await init();
    return _prefs!.getInt(key) ?? fallback;
  }

  Future<void> setInt(String key, int value) async {
    await init();
    await _prefs!.setInt(key, value);
  }

  Future<List<String>> getStringList(String key) async {
    await init();
    return _prefs!.getStringList(key) ?? [];
  }

  Future<void> setStringList(String key, List<String> value) async {
    await init();
    await _prefs!.setStringList(key, value);
  }

  Future<Map<String, bool>> loadBoolMap(String key) async {
    await init();
    final raw = _prefs!.getString(key);
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((k, v) => MapEntry(k, v == true));
  }

  Future<void> saveBoolMap(String key, Map<String, bool> map) async {
    await init();
    await _prefs!.setString(key, jsonEncode(map));
  }
}
