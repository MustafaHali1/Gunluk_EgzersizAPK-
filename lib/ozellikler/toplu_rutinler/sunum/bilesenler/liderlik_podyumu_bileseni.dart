// lib/ozellikler/toplu_rutinler/sunum/bilesenler/liderlik_podyumu_bileseni.dart

import 'package:flutter/material.dart';
import '../../alan/grup_uyesi_modeli.dart';

/// Liderlik ekranında ilk 3 sıradaki üyeleri podyum (🥇, 🥈, 🥉) şeklinde gösteren görsel bileşen.
class LiderlikPodyumuBileseni extends StatelessWidget {
  final List<GrupUyesiModeli> ilkUc;

  const LiderlikPodyumuBileseni({super.key, required this.ilkUc});

  @override
  Widget build(BuildContext context) {
    if (ilkUc.isEmpty) return const SizedBox.shrink();

    final birinci = ilkUc.isNotEmpty ? ilkUc[0] : null;
    final ikinci = ilkUc.length > 1 ? ilkUc[1] : null;
    final ucuncu = ilkUc.length > 2 ? ilkUc[2] : null;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2. Sıra
          if (ikinci != null)
            _podyumSutunu(
              context: context,
              uye: ikinci,
              derece: 2,
              madalya: '🥈',
              renk: Colors.grey.shade400,
              yukseklik: 100,
            )
          else
            const SizedBox(width: 80),

          const SizedBox(width: 8),

          // 1. Sıra (En Yüksek)
          if (birinci != null)
            _podyumSutunu(
              context: context,
              uye: birinci,
              derece: 1,
              madalya: '🥇',
              renk: Colors.amber.shade600,
              yukseklik: 130,
            ),

          const SizedBox(width: 8),

          // 3. Sıra
          if (ucuncu != null)
            _podyumSutunu(
              context: context,
              uye: ucuncu,
              derece: 3,
              madalya: '🥉',
              renk: Colors.brown.shade400,
              yukseklik: 80,
            )
          else
            const SizedBox(width: 80),
        ],
      ),
    );
  }

  Widget _podyumSutunu({
    required BuildContext context,
    required GrupUyesiModeli uye,
    required int derece,
    required String madalya,
    required Color renk,
    required double yukseklik,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(madalya, style: const TextStyle(fontSize: 24)),
        const SizedBox(height: 4),
        Text(
          uye.gorunenAd,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          '${uye.toplamPuan} P',
          style: TextStyle(color: renk, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        Container(
          width: 80,
          height: yukseklik,
          decoration: BoxDecoration(
            color: renk.withValues(alpha: 0.3),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: renk, width: 2),
          ),
          child: Center(
            child: Text(
              '#$derece',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: renk,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
