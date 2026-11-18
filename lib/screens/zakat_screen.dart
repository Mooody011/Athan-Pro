import 'package:flutter/material.dart';

class ZakatScreen extends StatefulWidget {
  const ZakatScreen({super.key});

  @override
  State<ZakatScreen> createState() => _ZakatScreenState();
}

class _ZakatScreenState extends State<ZakatScreen> {
  final _cashCtrl = TextEditingController();
  final _goldGramsCtrl = TextEditingController();
  final _goldPriceCtrl = TextEditingController(text: '4200');
  final _investCtrl = TextEditingController();
  final _debtCtrl = TextEditingController();

  double _parse(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0.0;

  @override
  void dispose() {
    _cashCtrl.dispose();
    _goldGramsCtrl.dispose();
    _goldPriceCtrl.dispose();
    _investCtrl.dispose();
    _debtCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final goldPrice = _parse(_goldPriceCtrl);
    final nisab = 85.0 * goldPrice;
    final totalWealth = _parse(_cashCtrl) +
        (_parse(_goldGramsCtrl) * goldPrice) +
        _parse(_investCtrl) -
        _parse(_debtCtrl);
    final eligible = totalWealth >= nisab && nisab > 0;
    final zakatDue = eligible ? totalWealth * 0.025 : 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('حاسبة الزكاة الشرعية')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _numField(_goldPriceCtrl, 'سعر جرام الذهب عيار 24 (بعملتك)'),
          _numField(_cashCtrl, 'النقد والمدخرات البنكية'),
          _numField(_goldGramsCtrl, 'وزن الذهب المدّخر (بالجرام - عيار 24)'),
          _numField(_investCtrl, 'الأسهم وعروض التجارة'),
          _numField(_debtCtrl, 'الديون المستحقة عليك (تُخصم)'),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: eligible
                  ? const Color(0xFF065F46).withAlpha(65)
                  : Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(90),
              border: Border.all(
                color: eligible ? const Color(0xFF10B981) : Colors.grey.withAlpha(70),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('قيمة النصاب (85 جم ذهب): ${nisab.toStringAsFixed(0)}'),
                const SizedBox(height: 6),
                Text('صافي المال الخاضع للزكاة: ${totalWealth.clamp(0, double.infinity).toStringAsFixed(0)}'),
                const Divider(height: 22),
                Text(
                  eligible
                      ? 'الزكاة الواجبة (2.5%): ${zakatDue.toStringAsFixed(2)}'
                      : 'المال لم يبلغ النصاب الشرعي بعد (لا تجب الزكاة).',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: eligible ? const Color(0xFFD4AF37) : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _numField(TextEditingController ctrl, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: ctrl,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
        onChanged: (_) => setState(() {}),
      ),
    );
  }
}
