// lib/ozellikler/toplu_rutinler/sunum/bilesenler/canli_yaris_cubugu.dart

import 'package:flutter/material.dart';
import '../kontrolculer/rutin_yaris_kontrolcusu.dart';

/// Rutin detayında ve sohbetin en tepesinde sabit kalan canlı yarış panosu.
class CanliYarisCubugu extends StatelessWidget {
  final Map<String, dynamic>? yarisVerisi;
  final VoidCallback onYarisBaslatTiklandi;

  const CanliYarisCubugu({
    super.key,
    required this.yarisVerisi,
    required this.onYarisBaslatTiklandi,
  });

  @override
  Widget build(BuildContext context) {
    if (yarisVerisi == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.amber.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber.shade200),
        ),
        child: Row(
          children: [
            const Text('🏆', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Şu an aktif bir yarış yok. Arkadaşlarına meydan oku!',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
            ElevatedButton(
              onPressed: onYarisBaslatTiklandi,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade800,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                textStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('Yarış Başlat 🏁'),
            ),
          ],
        ),
      );
    }

    final baslik = yarisVerisi!['baslik'] as String? ?? 'Süreli Yarış';
    final kalanSure = RutinYarisKontrolcusu.kalanSureMetni(yarisVerisi);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.amber.shade700, Colors.orange.shade800],
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text('🏁', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  baslik,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                Text(
                  kalanSure,
                  style: TextStyle(
                    color: Colors.amber.shade100,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.black26,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
              'Liderlik Podyumu ➔',
              style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
