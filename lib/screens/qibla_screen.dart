import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../models/app_models.dart';
import '../services/prayer_calculator.dart';

class QiblaScreen extends StatefulWidget {
  final PrayerSettings settings;
  const QiblaScreen({super.key, required this.settings});

  @override
  State<QiblaScreen> createState() => _QiblaScreenState();
}

class _QiblaScreenState extends State<QiblaScreen> {
  StreamSubscription<MagnetometerEvent>? _magSub;
  StreamSubscription<AccelerometerEvent>? _accSub;
  double _heading = 0.0;
  bool _hasSensor = false;
  bool _manualMode = false;

  double _ax = 0, _ay = 0, _az = 9.8;

  @override
  void initState() {
    super.initState();
    _startSensors();
  }

  void _startSensors() {
    try {
      _accSub = accelerometerEventStream().listen(
        (e) {
          _ax = e.x;
          _ay = e.y;
          _az = e.z;
        },
        onError: (_) {},
      );
      _magSub = magnetometerEventStream().listen(
        (m) {
          if (!mounted || _manualMode) return;
          // Tilt-compensated compass heading
          final normA = math.sqrt(_ax * _ax + _ay * _ay + _az * _az);
          double azimuth;
          if (normA > 0.1) {
            final ax = _ax / normA;
            final ay = _ay / normA;
            final az = _az / normA;
            final pitch = math.asin(-ax.clamp(-1.0, 1.0));
            final roll = math.atan2(ay, az);
            final xh = m.x * math.cos(pitch) + m.z * math.sin(pitch);
            final yh = m.x * math.sin(roll) * math.sin(pitch) +
                m.y * math.cos(roll) -
                m.z * math.sin(roll) * math.cos(pitch);
            azimuth = (math.atan2(yh, xh) * 180 / math.pi + 360) % 360;
          } else {
            azimuth = (math.atan2(m.y, m.x) * 180 / math.pi + 360) % 360;
          }
          setState(() {
            _hasSensor = true;
            _heading = azimuth;
          });
        },
        onError: (_) {
          if (mounted) setState(() => _hasSensor = false);
        },
      );
    } catch (_) {
      _hasSensor = false;
    }
  }

  @override
  void dispose() {
    _magSub?.cancel();
    _accSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final qiblaAngle = PrayerCalculator.calculateQiblaBearing(
      widget.settings.latitude,
      widget.settings.longitude,
    );
    final distanceKm = PrayerCalculator.distanceToKaabaKm(
      widget.settings.latitude,
      widget.settings.longitude,
    );
    final diff = ((qiblaAngle - _heading + 540) % 360) - 180;
    final isAligned = diff.abs() <= 5.0;
    final gold = const Color(0xFFD4AF37);

    return Scaffold(
      appBar: AppBar(
        title: const Text('اتجاه القبلة'),
        actions: [
          TextButton.icon(
            onPressed: () => setState(() => _manualMode = !_manualMode),
            icon: Icon(_manualMode ? Icons.sensors : Icons.tune),
            label: Text(_manualMode ? 'الحساس' : 'يدوي'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isAligned
                  ? const Color(0xFF065F46).withAlpha(60)
                  : Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(90),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isAligned ? const Color(0xFF10B981) : Colors.grey.withAlpha(60),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const Text('زاوية القبلة', style: TextStyle(fontSize: 12)),
                    Text(
                      '${qiblaAngle.toStringAsFixed(1)}°',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: gold,
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text('المسافة للكعبة', style: TextStyle(fontSize: 12)),
                    Text(
                      '${distanceKm.toStringAsFixed(0)} كم',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Compass Dial
          Center(
            child: SizedBox(
              width: 280,
              height: 280,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Rotating Dial
                  Transform.rotate(
                    angle: -_heading * math.pi / 180,
                    child: CustomPaint(
                      size: const Size(270, 270),
                      painter: _CompassDialPainter(
                        qiblaAngleDeg: qiblaAngle,
                        isAligned: isAligned,
                      ),
                    ),
                  ),
                  // Center Kaaba Badge
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isAligned ? const Color(0xFF10B981) : const Color(0xFF064E3B),
                      border: Border.all(color: gold, width: 2.5),
                    ),
                    child: const Icon(Icons.mosque_rounded, color: Colors.white, size: 30),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),

          Center(
            child: Text(
              isAligned
                  ? 'أنت الآن في اتجاه القبلة تماماً ✓'
                  : (diff > 0
                      ? 'استدر يميناً بمقدار ${diff.abs().toStringAsFixed(0)}°'
                      : 'استدر يساراً بمقدار ${diff.abs().toStringAsFixed(0)}°'),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isAligned ? const Color(0xFF10B981) : gold,
              ),
            ),
          ),
          const SizedBox(height: 14),

          if (_manualMode || !_hasSensor) ...[
            const Text(
              'التوجيه اليدوي (حرّك الشريط لمطابقة الشمال الجغرافي):',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13),
            ),
            Slider(
              value: _heading,
              min: 0,
              max: 359,
              onChanged: (v) => setState(() => _heading = v),
            ),
          ] else
            const Text(
              'ضع الهاتف بشكل أفقي بعيداً عن المعادن، ولو احتاج معايرة حرّكه على شكل رقم 8.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12.5, color: Colors.grey),
            ),
        ],
      ),
    );
  }
}

class _CompassDialPainter extends CustomPainter {
  final double qiblaAngleDeg;
  final bool isAligned;

  _CompassDialPainter({required this.qiblaAngleDeg, required this.isAligned});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 8;

    final outerPaint = Paint()
      ..color = isAligned ? const Color(0xFF10B981) : const Color(0xFFD4AF37)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, outerPaint);

    // Tick marks
    final tickPaint = Paint()
      ..color = Colors.grey.withAlpha(140)
      ..strokeWidth = 1.5;
    for (int i = 0; i < 36; i++) {
      final rad = i * 10 * math.pi / 180;
      final inner = i % 9 == 0 ? radius - 16 : radius - 8;
      canvas.drawLine(
        Offset(center.dx + inner * math.sin(rad), center.dy - inner * math.cos(rad)),
        Offset(center.dx + radius * math.sin(rad), center.dy - radius * math.cos(rad)),
        tickPaint,
      );
    }

    // Cardinal labels (N, E, S, W)
    const dirs = {'ش': 0.0, 'ق': 90.0, 'ج': 180.0, 'غ': 270.0};
    dirs.forEach((label, deg) {
      final rad = deg * math.pi / 180;
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(
            color: deg == 0 ? Colors.redAccent : const Color(0xFFD4AF37),
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        textDirection: TextDirection.rtl,
      )..layout();
      final pos = Offset(
        center.dx + (radius - 30) * math.sin(rad) - tp.width / 2,
        center.dy - (radius - 30) * math.cos(rad) - tp.height / 2,
      );
      tp.paint(canvas, pos);
    });

    // Qibla Pointer Arrow
    final qRad = qiblaAngleDeg * math.pi / 180;
    final tip = Offset(
      center.dx + (radius - 10) * math.sin(qRad),
      center.dy - (radius - 10) * math.cos(qRad),
    );
    final arrowPaint = Paint()
      ..color = isAligned ? const Color(0xFF10B981) : const Color(0xFFD4AF37)
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, tip, arrowPaint);

    canvas.drawCircle(tip, 8, Paint()..color = const Color(0xFFD4AF37));
  }

  @override
  bool shouldRepaint(covariant _CompassDialPainter oldDelegate) =>
      oldDelegate.qiblaAngleDeg != qiblaAngleDeg ||
      oldDelegate.isAligned != isAligned;
}
