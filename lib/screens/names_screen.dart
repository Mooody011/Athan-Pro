import 'package:flutter/material.dart';
import '../data/names_of_allah_data.dart';

class NamesOfAllahScreen extends StatefulWidget {
  const NamesOfAllahScreen({super.key});

  @override
  State<NamesOfAllahScreen> createState() => _NamesOfAllahScreenState();
}

class _NamesOfAllahScreenState extends State<NamesOfAllahScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final list = kAllahNames
        .where((n) => n.name.contains(_query) || n.meaning.contains(_query))
        .toList();

    return Scaffold(
      appBar: AppBar(title: const Text('أسماء الله الحسنى (99)')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(14),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'ابحث في الأسماء أو المعاني...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
              ),
              onChanged: (v) => setState(() => _query = v.trim()),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(14, 0, 14, 24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.45,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: list.length,
              itemBuilder: (_, i) {
                final item = list[i];
                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (_) => Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              item.name,
                              style: const TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFD4AF37),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              item.meaning,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16, height: 1.6),
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Theme.of(context).colorScheme.surfaceContainerHighest.withAlpha(90),
                      border: Border.all(color: const Color(0xFFD4AF37).withAlpha(90)),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFD4AF37),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.meaning,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 11.5),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
