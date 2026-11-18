import 'package:audioplayers/audioplayers.dart';
import '../models/app_models.dart';

class AudioService {
  AudioService._();
  static final AudioService instance = AudioService._();

  final AudioPlayer _player = AudioPlayer();
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;

  static const List<MuezzinOption> muezzins = [
    MuezzinOption(
      id: 'offline_chime',
      nameAr: 'نغمة تنبيه إسلامية هادئة (أوفلاين)',
      subtitle: 'مدمجة داخل التطبيق وتعمل بدون إنترنت',
      streamUrl: null,
    ),
    MuezzinOption(
      id: 'makkah',
      nameAr: 'آذان الحرم المكي (علي أحمد ملا)',
      subtitle: 'يحتاج إنترنت للتشغيل - يعود للنغمة المدمجة تلقائياً أوفلاين',
      streamUrl: 'https://www.islamcan.com/audio/adhan/azan1.mp3',
    ),
    MuezzinOption(
      id: 'madinah',
      nameAr: 'آذان المسجد النبوي الشريف',
      subtitle: 'يحتاج إنترنت للتشغيل - يعود للنغمة المدمجة تلقائياً أوفلاين',
      streamUrl: 'https://www.islamcan.com/audio/adhan/azan2.mp3',
    ),
    MuezzinOption(
      id: 'alafasy',
      nameAr: 'الشيخ مشاري راشد العفاسي',
      subtitle: 'يحتاج إنترنت للتشغيل - يعود للنغمة المدمجة تلقائياً أوفلاين',
      streamUrl: 'https://www.islamcan.com/audio/adhan/azan15.mp3',
    ),
    MuezzinOption(
      id: 'aqsa',
      nameAr: 'آذان المسجد الأقصى المبارك',
      subtitle: 'يحتاج إنترنت للتشغيل - يعود للنغمة المدمجة تلقائياً أوفلاين',
      streamUrl: 'https://www.islamcan.com/audio/adhan/azan7.mp3',
    ),
  ];

  Future<String> playMuezzin(String muezzinId) async {
    await stop();
    final option = muezzins.firstWhere(
      (m) => m.id == muezzinId,
      orElse: () => muezzins.first,
    );
    _player.onPlayerComplete.listen((_) {
      _isPlaying = false;
    });

    if (option.streamUrl != null) {
      try {
        _isPlaying = true;
        await _player.play(UrlSource(option.streamUrl!));
        return 'جاري تشغيل: ${option.nameAr}';
      } catch (_) {
        // Fallback smoothly to bundled offline chime
      }
    }
    try {
      _isPlaying = true;
      await _player.play(AssetSource('audio/athan_chime.wav'));
      return 'تم تشغيل نغمة التنبيه المدمجة (أوفلاين)';
    } catch (_) {
      _isPlaying = false;
      return 'تعذر تشغيل الصوت على هذا الجهاز';
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (_) {}
    _isPlaying = false;
  }
}
