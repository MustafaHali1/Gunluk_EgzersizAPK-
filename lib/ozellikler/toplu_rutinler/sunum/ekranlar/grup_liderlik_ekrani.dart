// lib/ozellikler/toplu_rutinler/sunum/ekranlar/grup_liderlik_ekrani.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../alan/grup_modeli.dart';
import '../bilesenler/liderlik_podyumu_bileseni.dart';
import '../kontrolculer/liderlik_rapor_kontrolcusu.dart';

/// Grup içi sıralama, yüzdelik başarı oranları ve podyum ekranı.
class GrupLiderlikEkrani extends ConsumerWidget {
  final GrupModeli grup;

  const GrupLiderlikEkrani({super.key, required this.grup});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liderlikAsync = ref.watch(grupLiderlikSaglayici(grup.id));
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('${grup.ad} — Sıralama & Rapor'),
      ),
      body: liderlikAsync.when(
        data: (uyeler) {
          if (uyeler.isEmpty) {
            return const Center(child: Text('Henüz üye istatistiği bulunmuyor.'));
          }

          final ilkUc = LiderlikRaporKontrolcusu.ilkUcuGetir(uyeler);

          return ListView(
            padding: const EdgeInsets.all(12),
            children: [
              // 1. İlk Üç Podyumu
              LiderlikPodyumuBileseni(ilkUc: ilkUc),

              const Divider(height: 32),

              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  '📊 Tüm Katılımcılar & Başarı Oranları',
                  style: tema.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),

              // 2. Sıralama ve Yüzdelik Oran Listesi
              ...List.generate(uyeler.length, (index) {
                final uye = uyeler[index];
                final yuzde = LiderlikRaporKontrolcusu.yuzdelikOranHesapla(
                  tamamlananGorevSayisi: uye.tamamlananGorevSayisi,
                  katilmaTarihi: uye.katilmaTarihi,
                );

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: index == 0
                          ? Colors.amber
                          : index == 1
                              ? Colors.grey.shade400
                              : index == 2
                                  ? Colors.brown.shade400
                                  : tema.colorScheme.surfaceContainerHighest,
                      foregroundColor: index < 3 ? Colors.black : tema.colorScheme.onSurface,
                      child: Text(
                        '#${index + 1}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(
                      uye.gorunenAd,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      '🔥 ${uye.mevcutSeri} gün seri • ${uye.tamamlananGorevSayisi} görev',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${uye.toplamPuan} Puan',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: tema.colorScheme.primary,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          'Başarı: %$yuzde',
                          style: const TextStyle(fontSize: 11, color: Colors.green),
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
        error: (hata, _) => Center(child: Text('Liderlik tablosu yüklenemedi: $hata')),
      ),
    );
  }
}
