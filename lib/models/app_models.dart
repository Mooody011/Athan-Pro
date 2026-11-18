class CityLocation {
  final String id;
  final String nameAr;
  final String countryAr;
  final double latitude;
  final double longitude;
  final double timezone;
  final String defaultMethod;

  const CityLocation({
    required this.id,
    required this.nameAr,
    required this.countryAr,
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.defaultMethod,
  });
}

class PrayerSettings {
  final String cityId;
  final String customCityName;
  final double latitude;
  final double longitude;
  final double timezone;
  final bool useCustomCoords;
  final String calculationMethod;
  final bool isHanafi;
  final int hijriOffset;
  final bool isDarkMode;
  final bool use24Hour;
  final String muezzinId;
  final bool vibrateEnabled;
  final Map<String, bool> prayerAlerts;
  final Map<String, int> minuteAdjustments;

  const PrayerSettings({
    this.cityId = 'cairo',
    this.customCityName = 'القاهرة',
    this.latitude = 30.0444,
    this.longitude = 31.2357,
    this.timezone = 2.0,
    this.useCustomCoords = false,
    this.calculationMethod = 'egypt',
    this.isHanafi = false,
    this.hijriOffset = 0,
    this.isDarkMode = true,
    this.use24Hour = false,
    this.muezzinId = 'offline_chime',
    this.vibrateEnabled = true,
    this.prayerAlerts = const {
      'fajr': true,
      'sunrise': false,
      'dhuhr': true,
      'asr': true,
      'maghrib': true,
      'isha': true,
    },
    this.minuteAdjustments = const {
      'fajr': 0,
      'sunrise': 0,
      'dhuhr': 0,
      'asr': 0,
      'maghrib': 0,
      'isha': 0,
    },
  });

  PrayerSettings copyWith({
    String? cityId,
    String? customCityName,
    double? latitude,
    double? longitude,
    double? timezone,
    bool? useCustomCoords,
    String? calculationMethod,
    bool? isHanafi,
    int? hijriOffset,
    bool? isDarkMode,
    bool? use24Hour,
    String? muezzinId,
    bool? vibrateEnabled,
    Map<String, bool>? prayerAlerts,
    Map<String, int>? minuteAdjustments,
  }) {
    return PrayerSettings(
      cityId: cityId ?? this.cityId,
      customCityName: customCityName ?? this.customCityName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      timezone: timezone ?? this.timezone,
      useCustomCoords: useCustomCoords ?? this.useCustomCoords,
      calculationMethod: calculationMethod ?? this.calculationMethod,
      isHanafi: isHanafi ?? this.isHanafi,
      hijriOffset: hijriOffset ?? this.hijriOffset,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      use24Hour: use24Hour ?? this.use24Hour,
      muezzinId: muezzinId ?? this.muezzinId,
      vibrateEnabled: vibrateEnabled ?? this.vibrateEnabled,
      prayerAlerts: prayerAlerts ?? this.prayerAlerts,
      minuteAdjustments: minuteAdjustments ?? this.minuteAdjustments,
    );
  }
}

class PrayerTimeEntry {
  final String key;
  final String nameAr;
  final DateTime time;
  final bool isFard;

  const PrayerTimeEntry({
    required this.key,
    required this.nameAr,
    required this.time,
    this.isFard = true,
  });
}

class PrayerDaySchedule {
  final DateTime date;
  final List<PrayerTimeEntry> entries;
  final DateTime midnight;
  final DateTime lastThird;

  const PrayerDaySchedule({
    required this.date,
    required this.entries,
    required this.midnight,
    required this.lastThird,
  });
}

class DhikrItem {
  final String id;
  final String category;
  final String text;
  final int count;
  final String virtue;

  const DhikrItem({
    required this.id,
    required this.category,
    required this.text,
    required this.count,
    required this.virtue,
  });
}

class AllahNameItem {
  final int number;
  final String name;
  final String meaning;

  const AllahNameItem({
    required this.number,
    required this.name,
    required this.meaning,
  });
}

class SurahInfo {
  final int number;
  final String name;
  final int verses;
  final String type;
  final int juz;

  const SurahInfo({
    required this.number,
    required this.name,
    required this.verses,
    required this.type,
    required this.juz,
  });
}

class MuezzinOption {
  final String id;
  final String nameAr;
  final String subtitle;
  final String? streamUrl;

  const MuezzinOption({
    required this.id,
    required this.nameAr,
    required this.subtitle,
    this.streamUrl,
  });
}
