import '../models/app_models.dart';

const List<CityLocation> kCitiesData = [
  // مصر
  CityLocation(id: 'cairo', nameAr: 'القاهرة', countryAr: 'مصر', latitude: 30.0444, longitude: 31.2357, timezone: 2.0, defaultMethod: 'egypt'),
  CityLocation(id: 'new_cairo', nameAr: 'القاهرة الجديدة', countryAr: 'مصر', latitude: 30.0074, longitude: 31.4913, timezone: 2.0, defaultMethod: 'egypt'),
  CityLocation(id: 'giza', nameAr: 'الجيزة', countryAr: 'مصر', latitude: 30.0131, longitude: 31.2089, timezone: 2.0, defaultMethod: 'egypt'),
  CityLocation(id: 'alexandria', nameAr: 'الإسكندرية', countryAr: 'مصر', latitude: 31.2001, longitude: 29.9187, timezone: 2.0, defaultMethod: 'egypt'),
  CityLocation(id: 'mansoura', nameAr: 'المنصورة', countryAr: 'مصر', latitude: 31.0409, longitude: 31.3785, timezone: 2.0, defaultMethod: 'egypt'),
  CityLocation(id: 'tanta', nameAr: 'طنطا', countryAr: 'مصر', latitude: 30.7865, longitude: 31.0004, timezone: 2.0, defaultMethod: 'egypt'),
  CityLocation(id: 'zagazig', nameAr: 'الزقازيق', countryAr: 'مصر', latitude: 30.5877, longitude: 31.5020, timezone: 2.0, defaultMethod: 'egypt'),
  CityLocation(id: 'ismailia', nameAr: 'الإسماعيلية', countryAr: 'مصر', latitude: 30.5965, longitude: 32.2715, timezone: 2.0, defaultMethod: 'egypt'),
  CityLocation(id: 'suez', nameAr: 'السويس', countryAr: 'مصر', latitude: 29.9668, longitude: 32.5498, timezone: 2.0, defaultMethod: 'egypt'),
  CityLocation(id: 'port_said', nameAr: 'بورسعيد', countryAr: 'مصر', latitude: 31.2653, longitude: 32.3019, timezone: 2.0, defaultMethod: 'egypt'),
  CityLocation(id: 'asyut', nameAr: 'أسيوط', countryAr: 'مصر', latitude: 27.1809, longitude: 31.1837, timezone: 2.0, defaultMethod: 'egypt'),
  CityLocation(id: 'sohag', nameAr: 'سوهاج', countryAr: 'مصر', latitude: 26.5569, longitude: 31.6948, timezone: 2.0, defaultMethod: 'egypt'),
  CityLocation(id: 'luxor', nameAr: 'الأقصر', countryAr: 'مصر', latitude: 25.6872, longitude: 32.6396, timezone: 2.0, defaultMethod: 'egypt'),
  CityLocation(id: 'aswan', nameAr: 'أسوان', countryAr: 'مصر', latitude: 24.0889, longitude: 32.8998, timezone: 2.0, defaultMethod: 'egypt'),
  CityLocation(id: 'hurghada', nameAr: 'الغردقة', countryAr: 'مصر', latitude: 27.2579, longitude: 33.8116, timezone: 2.0, defaultMethod: 'egypt'),
  CityLocation(id: 'sharm', nameAr: 'شرم الشيخ', countryAr: 'مصر', latitude: 27.9158, longitude: 34.3300, timezone: 2.0, defaultMethod: 'egypt'),

  // السعودية
  CityLocation(id: 'makkah', nameAr: 'مكة المكرمة', countryAr: 'السعودية', latitude: 21.4225, longitude: 39.8262, timezone: 3.0, defaultMethod: 'umm_al_qura'),
  CityLocation(id: 'madinah', nameAr: 'المدينة المنورة', countryAr: 'السعودية', latitude: 24.5247, longitude: 39.5692, timezone: 3.0, defaultMethod: 'umm_al_qura'),
  CityLocation(id: 'riyadh', nameAr: 'الرياض', countryAr: 'السعودية', latitude: 24.7136, longitude: 46.6753, timezone: 3.0, defaultMethod: 'umm_al_qura'),
  CityLocation(id: 'jeddah', nameAr: 'جدة', countryAr: 'السعودية', latitude: 21.4858, longitude: 39.1925, timezone: 3.0, defaultMethod: 'umm_al_qura'),
  CityLocation(id: 'dammam', nameAr: 'الدمام', countryAr: 'السعودية', latitude: 26.4207, longitude: 50.0888, timezone: 3.0, defaultMethod: 'umm_al_qura'),

  // الخليج
  CityLocation(id: 'dubai', nameAr: 'دبي', countryAr: 'الإمارات', latitude: 25.2048, longitude: 55.2708, timezone: 4.0, defaultMethod: 'dubai'),
  CityLocation(id: 'abudhabi', nameAr: 'أبو ظبي', countryAr: 'الإمارات', latitude: 24.4539, longitude: 54.3773, timezone: 4.0, defaultMethod: 'dubai'),
  CityLocation(id: 'kuwait', nameAr: 'مدينة الكويت', countryAr: 'الكويت', latitude: 29.3759, longitude: 47.9774, timezone: 3.0, defaultMethod: 'kuwait'),
  CityLocation(id: 'doha', nameAr: 'الدوحة', countryAr: 'قطر', latitude: 25.2854, longitude: 51.5310, timezone: 3.0, defaultMethod: 'qatar'),
  CityLocation(id: 'manama', nameAr: 'المنامة', countryAr: 'البحرين', latitude: 26.2285, longitude: 50.5860, timezone: 3.0, defaultMethod: 'umm_al_qura'),
  CityLocation(id: 'muscat', nameAr: 'مسقط', countryAr: 'عُمان', latitude: 23.5880, longitude: 58.3829, timezone: 4.0, defaultMethod: 'umm_al_qura'),

  // بلاد الشام والعراق واليمن
  CityLocation(id: 'jerusalem', nameAr: 'القدس', countryAr: 'فلسطين', latitude: 31.7683, longitude: 35.2137, timezone: 2.0, defaultMethod: 'mwl'),
  CityLocation(id: 'gaza', nameAr: 'غزة', countryAr: 'فلسطين', latitude: 31.5017, longitude: 34.4668, timezone: 2.0, defaultMethod: 'egypt'),
  CityLocation(id: 'amman', nameAr: 'عمّان', countryAr: 'الأردن', latitude: 31.9454, longitude: 35.9284, timezone: 3.0, defaultMethod: 'mwl'),
  CityLocation(id: 'damascus', nameAr: 'دمشق', countryAr: 'سوريا', latitude: 33.5138, longitude: 36.2765, timezone: 3.0, defaultMethod: 'mwl'),
  CityLocation(id: 'beirut', nameAr: 'بيروت', countryAr: 'لبنان', latitude: 33.8938, longitude: 35.5018, timezone: 2.0, defaultMethod: 'mwl'),
  CityLocation(id: 'baghdad', nameAr: 'بغداد', countryAr: 'العراق', latitude: 33.3152, longitude: 44.3661, timezone: 3.0, defaultMethod: 'mwl'),
  CityLocation(id: 'sanaa', nameAr: 'صنعاء', countryAr: 'اليمن', latitude: 15.3694, longitude: 44.1910, timezone: 3.0, defaultMethod: 'umm_al_qura'),

  // المغرب العربي والسودان
  CityLocation(id: 'khartoum', nameAr: 'الخرطوم', countryAr: 'السودان', latitude: 15.5007, longitude: 32.5599, timezone: 2.0, defaultMethod: 'egypt'),
  CityLocation(id: 'tripoli', nameAr: 'طرابلس', countryAr: 'ليبيا', latitude: 32.8872, longitude: 13.1913, timezone: 2.0, defaultMethod: 'egypt'),
  CityLocation(id: 'tunis', nameAr: 'تونس', countryAr: 'تونس', latitude: 36.8065, longitude: 10.1815, timezone: 1.0, defaultMethod: 'mwl'),
  CityLocation(id: 'algiers', nameAr: 'الجزائر', countryAr: 'الجزائر', latitude: 36.7538, longitude: 3.0588, timezone: 1.0, defaultMethod: 'mwl'),
  CityLocation(id: 'rabat', nameAr: 'الرباط', countryAr: 'المغرب', latitude: 34.0209, longitude: -6.8416, timezone: 1.0, defaultMethod: 'mwl'),
  CityLocation(id: 'casablanca', nameAr: 'الدار البيضاء', countryAr: 'المغرب', latitude: 33.5731, longitude: -7.5898, timezone: 1.0, defaultMethod: 'mwl'),

  // مدن عالمية
  CityLocation(id: 'istanbul', nameAr: 'إسطنبول', countryAr: 'تركيا', latitude: 41.0082, longitude: 28.9784, timezone: 3.0, defaultMethod: 'mwl'),
  CityLocation(id: 'london', nameAr: 'لندن', countryAr: 'بريطانيا', latitude: 51.5074, longitude: -0.1278, timezone: 0.0, defaultMethod: 'mwl'),
  CityLocation(id: 'paris', nameAr: 'باريس', countryAr: 'فرنسا', latitude: 48.8566, longitude: 2.3522, timezone: 1.0, defaultMethod: 'mwl'),
  CityLocation(id: 'berlin', nameAr: 'برلين', countryAr: 'ألمانيا', latitude: 52.5200, longitude: 13.4050, timezone: 1.0, defaultMethod: 'mwl'),
  CityLocation(id: 'new_york', nameAr: 'نيويورك', countryAr: 'أمريكا', latitude: 40.7128, longitude: -74.0060, timezone: -5.0, defaultMethod: 'isna'),
  CityLocation(id: 'kuala_lumpur', nameAr: 'كوالالمبور', countryAr: 'ماليزيا', latitude: 3.1390, longitude: 101.6869, timezone: 8.0, defaultMethod: 'singapore'),
];
