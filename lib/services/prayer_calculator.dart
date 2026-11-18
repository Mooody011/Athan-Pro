import 'dart:math' as math;
import '../models/app_models.dart';

class CalcMethodConfig {
  final String id;
  final String nameAr;
  final double fajrAngle;
  final double ishaAngle;
  final int ishaMinutesAfterMaghrib; // > 0 means fixed minutes instead of angle

  const CalcMethodConfig({
    required this.id,
    required this.nameAr,
    required this.fajrAngle,
    this.ishaAngle = 0,
    this.ishaMinutesAfterMaghrib = 0,
  });
}

class PrayerCalculator {
  static const Map<String, CalcMethodConfig> methods = {
    'egypt': CalcMethodConfig(
      id: 'egypt',
      nameAr: 'الهيئة المصرية العامة للمساحة',
      fajrAngle: 19.5,
      ishaAngle: 17.5,
    ),
    'umm_al_qura': CalcMethodConfig(
      id: 'umm_al_qura',
      nameAr: 'تقويم أم القرى (مكة المكرمة)',
      fajrAngle: 18.5,
      ishaMinutesAfterMaghrib: 90,
    ),
    'mwl': CalcMethodConfig(
      id: 'mwl',
      nameAr: 'رابطة العالم الإسلامي',
      fajrAngle: 18.0,
      ishaAngle: 17.0,
    ),
    'karachi': CalcMethodConfig(
      id: 'karachi',
      nameAr: 'جامعة العلوم الإسلامية بكراتشي',
      fajrAngle: 18.0,
      ishaAngle: 18.0,
    ),
    'isna': CalcMethodConfig(
      id: 'isna',
      nameAr: 'الجمعية الإسلامية لأمريكا الشمالية (ISNA)',
      fajrAngle: 15.0,
      ishaAngle: 15.0,
    ),
    'dubai': CalcMethodConfig(
      id: 'dubai',
      nameAr: 'الهيئة العامة للشؤون الإسلامية (دبي)',
      fajrAngle: 18.2,
      ishaAngle: 18.2,
    ),
    'qatar': CalcMethodConfig(
      id: 'qatar',
      nameAr: 'تقويم قطر',
      fajrAngle: 18.0,
      ishaMinutesAfterMaghrib: 90,
    ),
    'kuwait': CalcMethodConfig(
      id: 'kuwait',
      nameAr: 'وزارة الأوقاف الكويتية',
      fajrAngle: 18.0,
      ishaAngle: 17.5,
    ),
    'singapore': CalcMethodConfig(
      id: 'singapore',
      nameAr: 'مجلس الشؤون الإسلامية (سنغافورة)',
      fajrAngle: 20.0,
      ishaAngle: 18.0,
    ),
  };

  static double _degToRad(double d) => d * math.pi / 180.0;
  static double _radToDeg(double r) => r * 180.0 / math.pi;

  static double _fixAngle(double a) {
    a = a - 360.0 * (a / 360.0).floor();
    return a < 0 ? a + 360.0 : a;
  }

  static double _fixHour(double h) {
    h = h - 24.0 * (h / 24.0).floor();
    return h < 0 ? h + 24.0 : h;
  }

  static double _julianDate(int year, int month, int day) {
    if (month <= 2) {
      year -= 1;
      month += 12;
    }
    final a = (year / 100.0).floor();
    final b = 2 - a + (a / 4.0).floor();
    return (365.25 * (year + 4716)).floor() +
        (30.6001 * (month + 1)).floor() +
        day +
        b -
        1524.5;
  }

  /// Returns [declinationDeg, equationOfTimeHours]
  static List<double> _sunPosition(double jd) {
    final d = jd - 2451545.0;
    final g = _fixAngle(357.529 + 0.98560028 * d);
    final q = _fixAngle(280.459 + 0.98564736 * d);
    final l = _fixAngle(
      q + 1.915 * math.sin(_degToRad(g)) + 0.020 * math.sin(_degToRad(2 * g)),
    );
    final e = 23.439 - 0.00000036 * d;
    final ra = _radToDeg(
          math.atan2(
            math.cos(_degToRad(e)) * math.sin(_degToRad(l)),
            math.cos(_degToRad(l)),
          ),
        ) /
        15.0;
    final eqt = q / 15.0 - _fixHour(ra);
    final decl = _radToDeg(
      math.asin(math.sin(_degToRad(e)) * math.sin(_degToRad(l))),
    );
    return [decl, eqt];
  }

  static double _midDay(double jd, double tz, double lng) {
    final eqt = _sunPosition(jd + 0.5 - lng / 360.0)[1];
    return _fixHour(12.0 - eqt + tz - lng / 15.0);
  }

  static double _sunAngleTime(
    double jd,
    double lat,
    double lng,
    double tz,
    double angleDeg,
    bool isMorning,
  ) {
    final approx = isMorning ? 0.25 : 0.75;
    final sun = _sunPosition(jd + approx - lng / 360.0);
    final decl = sun[0];
    final noon = _midDay(jd, tz, lng);
    final num = -math.sin(_degToRad(angleDeg)) -
        math.sin(_degToRad(lat)) * math.sin(_degToRad(decl));
    final den = math.cos(_degToRad(lat)) * math.cos(_degToRad(decl));
    final cosVal = (num / den).clamp(-1.0, 1.0);
    final t = _radToDeg(math.acos(cosVal)) / 15.0;
    return noon + (isMorning ? -t : t);
  }

  static double _asrTime(
    double jd,
    double lat,
    double lng,
    double tz,
    int shadowFactor,
  ) {
    final sun = _sunPosition(jd + 0.625 - lng / 360.0);
    final decl = sun[0];
    final noon = _midDay(jd, tz, lng);
    final angle = -_radToDeg(
      math.atan(1.0 / (shadowFactor + math.tan(_degToRad((lat - decl).abs())))),
    );
    final num = -math.sin(_degToRad(angle)) -
        math.sin(_degToRad(lat)) * math.sin(_degToRad(decl));
    final den = math.cos(_degToRad(lat)) * math.cos(_degToRad(decl));
    final cosVal = (num / den).clamp(-1.0, 1.0);
    final t = _radToDeg(math.acos(cosVal)) / 15.0;
    return noon + t;
  }

  static DateTime _hoursToDateTime(DateTime date, double hours, int adjustMin) {
    final totalMinutes = (hours * 60.0).round() + adjustMin;
    return DateTime(date.year, date.month, date.day).add(
      Duration(minutes: totalMinutes),
    );
  }

  static PrayerDaySchedule calculateForDate(
    DateTime date,
    PrayerSettings settings,
  ) {
    final method = methods[settings.calculationMethod] ?? methods['egypt']!;
    final jd = _julianDate(date.year, date.month, date.day);
    final lat = settings.latitude;
    final lng = settings.longitude;
    final tz = settings.timezone;

    final fajrH = _sunAngleTime(jd, lat, lng, tz, method.fajrAngle, true);
    final sunriseH = _sunAngleTime(jd, lat, lng, tz, 0.833, true);
    final dhuhrH = _midDay(jd, tz, lng) + (1.0 / 60.0);
    final asrH = _asrTime(jd, lat, lng, tz, settings.isHanafi ? 2 : 1);
    final maghribH = _sunAngleTime(jd, lat, lng, tz, 0.833, false);
    final ishaH = method.ishaMinutesAfterMaghrib > 0
        ? maghribH + (method.ishaMinutesAfterMaghrib / 60.0)
        : _sunAngleTime(jd, lat, lng, tz, method.ishaAngle, false);

    final adj = settings.minuteAdjustments;
    final fajrDt = _hoursToDateTime(date, fajrH, adj['fajr'] ?? 0);
    final sunriseDt = _hoursToDateTime(date, sunriseH, adj['sunrise'] ?? 0);
    final dhuhrDt = _hoursToDateTime(date, dhuhrH, adj['dhuhr'] ?? 0);
    final asrDt = _hoursToDateTime(date, asrH, adj['asr'] ?? 0);
    final maghribDt = _hoursToDateTime(date, maghribH, adj['maghrib'] ?? 0);
    final ishaDt = _hoursToDateTime(date, ishaH, adj['isha'] ?? 0);

    // Night duration from Maghrib to next day's Fajr
    final nextFajrDt = fajrDt.add(const Duration(days: 1));
    final nightDuration = nextFajrDt.difference(maghribDt);
    final midnight = maghribDt.add(Duration(seconds: nightDuration.inSeconds ~/ 2));
    final lastThird = nextFajrDt.subtract(Duration(seconds: nightDuration.inSeconds ~/ 3));

    return PrayerDaySchedule(
      date: date,
      entries: [
        PrayerTimeEntry(key: 'fajr', nameAr: 'الفجر', time: fajrDt),
        PrayerTimeEntry(key: 'sunrise', nameAr: 'الشروق', time: sunriseDt, isFard: false),
        PrayerTimeEntry(key: 'dhuhr', nameAr: 'الظهر', time: dhuhrDt),
        PrayerTimeEntry(key: 'asr', nameAr: 'العصر', time: asrDt),
        PrayerTimeEntry(key: 'maghrib', nameAr: 'المغرب', time: maghribDt),
        PrayerTimeEntry(key: 'isha', nameAr: 'العشاء', time: ishaDt),
      ],
      midnight: midnight,
      lastThird: lastThird,
    );
  }

  /// Great-circle Qibla bearing in degrees clockwise from True North (0..360)
  static double calculateQiblaBearing(double lat, double lng) {
    const kaabaLat = 21.422487;
    const kaabaLng = 39.826206;
    final phiK = _degToRad(kaabaLat);
    final lambdaK = _degToRad(kaabaLng);
    final phi = _degToRad(lat);
    final lambda = _degToRad(lng);
    final y = math.sin(lambdaK - lambda);
    final x = math.cos(phi) * math.tan(phiK) -
        math.sin(phi) * math.cos(lambdaK - lambda);
    return (_radToDeg(math.atan2(y, x)) + 360.0) % 360.0;
  }

  /// Haversine distance to Kaaba in kilometers
  static double distanceToKaabaKm(double lat, double lng) {
    const kaabaLat = 21.422487;
    const kaabaLng = 39.826206;
    const earthRadiusKm = 6371.0;
    final dLat = _degToRad(kaabaLat - lat);
    final dLng = _degToRad(kaabaLng - lng);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degToRad(lat)) *
            math.cos(_degToRad(kaabaLat)) *
            math.sin(dLng / 2) *
            math.sin(dLng / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadiusKm * c;
  }

  /// Pure Dart Hijri date conversion (Kuwaiti tabular algorithm + offset)
  static String formatHijriDate(DateTime date, {int offsetDays = 0}) {
    final adjusted = date.add(Duration(days: offsetDays));
    final jd = (_julianDate(adjusted.year, adjusted.month, adjusted.day) + 0.5).floor();
    int l = jd - 1948440 + 10632;
    final n = ((l - 1) / 10631).floor();
    l = l - 10631 * n + 354;
    final j = (((10985 - l) / 5316).floor()) * (((50 * l) / 17719).floor()) +
        ((l / 5670).floor()) * (((43 * l) / 15238).floor());
    l = l -
        (((30 - j) / 15).floor()) * (((17719 * j) / 50).floor()) -
        ((j / 16).floor()) * (((15238 * j) / 43).floor()) +
        29;
    final month = ((24 * l) / 709).floor();
    final day = l - ((709 * month) / 24).floor();
    final year = 30 * n + j - 30;

    const hijriMonths = [
      'محرم',
      'صفر',
      'ربيع الأول',
      'ربيع الآخر',
      'جمادى الأولى',
      'جمادى الآخرة',
      'رجب',
      'شعبان',
      'رمضان',
      'شوال',
      'ذو القعدة',
      'ذو الحجة',
    ];
    final mName = hijriMonths[(month - 1).clamp(0, 11)];
    return '$day $mName $year هـ';
  }

  static String formatGregorianDateAr(DateTime date) {
    const weekdays = [
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    const months = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    return '${weekdays[date.weekday - 1]}، ${date.day} ${months[date.month - 1]} ${date.year}';
  }

  static String formatTime(DateTime dt, {bool use24Hour = false}) {
    final m = dt.minute.toString().padLeft(2, '0');
    if (use24Hour) {
      return '${dt.hour.toString().padLeft(2, '0')}:$m';
    }
    final isPm = dt.hour >= 12;
    int h12 = dt.hour % 12;
    if (h12 == 0) h12 = 12;
    return '$h12:$m ${isPm ? 'م' : 'ص'}';
  }

  static String formatCountdown(Duration d) {
    if (d.isNegative) return '00:00:00';
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
