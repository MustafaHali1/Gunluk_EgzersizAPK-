// lib/ozellikler/toplu_rutinler/sunum/ekranlar/rutin_liderlik_ekrani.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../cekirdek/tema/uygulama_renkleri.dart';
import '../../alan/toplu_rutin_modeli.dart';
import '../kontrolculer/grup_kontrolcusu.dart';

/// Rutin katılımcılarının liderlik podyumu, puan tablosu ve açılıştan beri devamlılık (örn. 20/20 gün) ekranı.
/// Renkler doğrudan UygulamaRenkleri sınıfından çağrılır (Thin UI).
class RutinLiderlikEkrani extends ConsumerWidget {
  final TopluRutinModeli rutin;

  const RutinLiderlikEkrani({
    super.key,
    required this.rutin,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uyelerAsync = ref.watch(rutinUyeleriSaglayici(rutin.id));
    final toplamGun = rutin.acilisindanBeriGecenGun > 0 ? rutin.acilisindanBeriGecenGun : 1;

    final birincil = UygulamaRenkleri.birincil(context);
    final kartZemin = UygulamaRenkleri.kartZemini(context);
    final arkaPlan = UygulamaRenkleri.arkaPlan(context);
    final metinBirincil = UygulamaRenkleri.metinBirincil(context);
    final metinIkincil = UygulamaRenkleri.metinIkincil(context);
    final kupaAltin = UygulamaRenkleri.kupa(context);
    final basari = UygulamaRenkleri.basariRengi(context);

    return Container(
      color: arkaPlan,
      child: uyelerAsync.when(
        data: (uyeler) {
          if (uyeler.isEmpty) {
            return Center(
              child: Text('Henüz katılımcı bulunamadı.', style: TextStyle(color: metinIkincil)),
            );
          }

          // Üyeleri puana ve seriye göre sırala
          final siraliUyeler = List.of(uyeler)
            ..sort((a, b) {
              final puanFarki = b.toplamPuan.compareTo(a.toplamPuan);
              if (puanFarki != 0) return puanFarki;
              return b.mevcutSeri.compareTo(a.mevcutSeri);
            });

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // PODYUM KARTI
              Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      birincil,
                      birincil.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: birincil.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.emoji_events, color: kupaAltin, size: 22),
                        const SizedBox(width: 8),
                        const Text(
                          'LİDERLİK PODYUMU',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (siraliUyeler.length > 1)
                          _podyumBasamagi(siraliUyeler[1], 2, const Color(0xFF94A3B8), 75),
                        if (siraliUyeler.isNotEmpty)
                          _podyumBasamagi(siraliUyeler[0], 1, kupaAltin, 100),
                        if (siraliUyeler.length > 2)
                          _podyumBasamagi(siraliUyeler[2], 3, const Color(0xFFD97706), 65),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // DEVAMLILIK ORANI BAŞLIĞI
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tüm Zamanlar Devamlılık Oranı',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: metinBirincil,
                      ),
                    ),
                    Text(
                      'Toplam $toplamGun Gün',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: birincil,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // KATILIMCI ORAN KARTLARI
              ...siraliUyeler.asMap().entries.map((entry) {
                final sira = entry.key + 1;
                final uye = entry.value;
                final tamamlanan = uye.tamamlananGunSayisi;
                final oranDouble = (tamamlanan / toplamGun).clamp(0.0, 1.0);
                final yuzde = (oranDouble * 100).toInt();

                return Card(
                  color: kartZemin,
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 26,
                              height: 26,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: sira <= 3 ? kupaAltin.withValues(alpha: 0.15) : birincil.withValues(alpha: 0.08),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$sira',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: sira <= 3 ? kupaAltin : metinBirincil,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '@${uye.gorunenAd}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                  color: metinBirincil,
                                ),
                              ),
                            ),
                            Text(
                              '$tamamlanan/$toplamGun Gün (%$yuzde)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: yuzde >= 80 ? basari : birincil,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: oranDouble,
                            minHeight: 6,
                            backgroundColor: birincil.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              yuzde >= 80 ? basari : birincil,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '🔥 ${uye.mevcutSeri} Gün Seri',
                              style: TextStyle(fontSize: 11, color: metinIkincil),
                            ),
                            Text(
                              '${uye.toplamPuan} Puan',
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: metinIkincil),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e', style: TextStyle(color: metinIkincil))),
      ),
    );
  }

  Widget _podyumBasamagi(dynamic uye, int sira, Color renk, double yukseklik) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '@${uye.gorunenAd}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Container(
          width: 72,
          height: yukseklik,
          decoration: BoxDecoration(
            color: renk,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$sira',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Text(
                '${uye.toplamPuan}P',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
