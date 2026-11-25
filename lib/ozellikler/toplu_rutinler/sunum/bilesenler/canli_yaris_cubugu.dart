// lib/ozellikler/toplu_rutinler/sunum/bilesenler/canli_yaris_cubugu.dart

import 'package:flutter/material.dart';
import '../../../../cekirdek/tema/uygulama_renkleri.dart';
import '../kontrolculer/rutin_yaris_kontrolcusu.dart';

/// Rutin detayında ve sohbetin en tepesinde sabit kalan canlı yarış panosu.
/// Renkler doğrudan UygulamaRenkleri sınıfından çağrılır.
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
    final kupaAltin = UygulamaRenkleri.kupa(context);
    final kartZemin = UygulamaRenkleri.kartZemini(context);
    final metinBirincil = UygulamaRenkleri.metinBirincil(context);
    final kenarlik = UygulamaRenkleri.kenarlik(context);

    if (yarisVerisi == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: kartZemin,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: kenarlik),
        ),
        child: Row(
          children: [
            const Text('🏆', style: TextStyle(fontSize: 20)),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Şu an aktif bir yarış yok. Arkadaşlarına meydan oku!',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: metinBirincil),
              ),
            ),
            ElevatedButton(
              onPressed: onYarisBaslatTiklandi,
              style: ElevatedButton.styleFrom(
                backgroundColor: kupaAltin,
                foregroundColor: Colors.black87,
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
          colors: [
            kupaAltin,
            kupaAltin.withValues(alpha: 0.85),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: kupaAltin.withValues(alpha: 0.25),
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
                  style: const TextStyle(
                    color: Colors.white70,
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
