// lib/ozellikler/toplu_rutinler/sunum/bilesenler/kanit_karti_bileseni.dart

import 'package:flutter/material.dart';
import '../../alan/grup_mesaj_modeli.dart';

/// Grup sohbeti içerisinde onaylanmış bir kanıtı ve etkileşimli emoji tepkilerini gösteren ince kart.
class KanitKartiBileseni extends StatelessWidget {
  final GrupMesajModeli mesaj;
  final String mevcutKullaniciId;
  final Function(String emoji) onTepkiVer;

  const KanitKartiBileseni({
    super.key,
    required this.mesaj,
    required this.mevcutKullaniciId,
    required this.onTepkiVer,
  });

  @override
  Widget build(BuildContext context) {
    final kanit = mesaj.kanit;
    if (kanit == null) return const SizedBox.shrink();

    final tema = Theme.of(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: tema.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.4), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst Başlık (Kullanıcı Adı ve AI Onay Rozeti)
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green.shade700,
                  radius: 16,
                  child: const Icon(Icons.check, color: Colors.white, size: 18),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kanit.kullaniciAdi,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                      Text(
                        '${kanit.rutinBasligi} rutinini tamamladı!',
                        style: TextStyle(color: tema.colorScheme.onSurfaceVariant, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.green, size: 14),
                      SizedBox(width: 4),
                      Text(
                        'AI Onaylı',
                        style: TextStyle(color: Colors.green, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Supabase'den yüklenen Kanıt Fotoğrafı
          if (kanit.fotoUrl.isNotEmpty)
            ClipRRect(
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Image.network(
                  kanit.fotoUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (_, _, _) => Container(
                    color: Colors.grey.shade300,
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                    ),
                  ),
                ),
              ),
            ),

          // İstenen Dinamik Poz ve Geri Bildirim
          Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              '🎯 Görev: ${kanit.istenenDinamikPoz}\n💬 AI: ${kanit.aiGeriBildirimi}',
              style: TextStyle(fontSize: 12, color: tema.colorScheme.onSurface),
            ),
          ),

          // Emoji Tepkileri Barı (Tebrik Et, Ateş, Güç)
          Padding(
            padding: const EdgeInsets.only(left: 10, right: 10, bottom: 8),
            child: Row(
              children: [
                _tepkiButonu(context, '👏', mesaj.tepkiler['👏'] ?? []),
                const SizedBox(width: 8),
                _tepkiButonu(context, '🔥', mesaj.tepkiler['🔥'] ?? []),
                const SizedBox(width: 8),
                _tepkiButonu(context, '💪', mesaj.tepkiler['💪'] ?? []),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _tepkiButonu(BuildContext context, String emoji, List<String> birakanlar) {
    final benBiraktim = birakanlar.contains(mevcutKullaniciId);
    return InkWell(
      onTap: () => onTepkiVer(emoji),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: benBiraktim ? Colors.amber.withValues(alpha: 0.25) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: benBiraktim ? Colors.amber : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            if (birakanlar.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                '${birakanlar.length}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: benBiraktim ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
