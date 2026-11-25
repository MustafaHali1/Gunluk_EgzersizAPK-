// lib/ozellikler/toplu_rutinler/sunum/bilesenler/kanit_karti_bileseni.dart

import 'package:flutter/material.dart';
import '../../../../cekirdek/tema/uygulama_renkleri.dart';
import '../../alan/grup_mesaj_modeli.dart';

/// Grup sohbeti içerisinde onaylanmış bir kanıtı ve etkileşimli emoji tepkilerini gösteren ince kart.
/// Renkler doğrudan UygulamaRenkleri sınıfından çağrılır.
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

    final kartZemin = UygulamaRenkleri.kartZemini(context);
    final metinBirincil = UygulamaRenkleri.metinBirincil(context);
    final metinIkincil = UygulamaRenkleri.metinIkincil(context);
    final basari = UygulamaRenkleri.basariRengi(context);
    final kenarlik = UygulamaRenkleri.kenarlik(context);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: kartZemin,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: basari.withValues(alpha: 0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
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
                  backgroundColor: basari,
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
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: metinBirincil),
                      ),
                      Text(
                        '${kanit.rutinBasligi} rutinini tamamladı!',
                        style: TextStyle(color: metinIkincil, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: basari.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome, color: basari, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        'AI Onaylı',
                        style: TextStyle(color: basari, fontSize: 11, fontWeight: FontWeight.bold),
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
                    color: kenarlik,
                    child: Center(
                      child: Icon(Icons.broken_image, size: 40, color: metinIkincil),
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
              style: TextStyle(fontSize: 12, color: metinBirincil),
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
    final kupaAltin = UygulamaRenkleri.kupa(context);
    final kenarlik = UygulamaRenkleri.kenarlik(context);
    final metinBirincil = UygulamaRenkleri.metinBirincil(context);

    return InkWell(
      onTap: () => onTepkiVer(emoji),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: benBiraktim ? kupaAltin.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: benBiraktim ? kupaAltin : kenarlik,
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
                  color: metinBirincil,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
