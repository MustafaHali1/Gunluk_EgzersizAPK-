// lib/ozellikler/toplu_rutinler/sunum/ekranlar/rutin_kanitlar_ekrani.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../cekirdek/tema/uygulama_renkleri.dart';
import '../../alan/toplu_rutin_modeli.dart';
import '../bilesenler/kanit_karti_bileseni.dart';
import '../kontrolculer/grup_kontrolcusu.dart';
import '../kontrolculer/grup_sohbet_kontrolcusu.dart';

enum KanitFiltresi { hepsi, sadeceBenim, bugun }

/// Rutin üyelerinin AI onaylı fotoğraflı kanıt akışı ve galeri ekranı.
/// Renkler doğrudan UygulamaRenkleri sınıfından çağrılır (Thin UI).
class RutinKanitlarEkrani extends ConsumerStatefulWidget {
  final TopluRutinModeli rutin;

  const RutinKanitlarEkrani({
    super.key,
    required this.rutin,
  });

  @override
  ConsumerState<RutinKanitlarEkrani> createState() => _RutinKanitlarEkraniState();
}

class _RutinKanitlarEkraniState extends ConsumerState<RutinKanitlarEkrani> {
  KanitFiltresi _filtre = KanitFiltresi.hepsi;

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(mevcutKullaniciIdSaglayici).value ?? '';
    final mesajlarAsync = ref.watch(rutinMesajlariSaglayici(widget.rutin.id));

    final birincil = UygulamaRenkleri.birincil(context);
    final kartZemin = UygulamaRenkleri.kartZemini(context);
    final arkaPlan = UygulamaRenkleri.arkaPlan(context);
    final metinBirincil = UygulamaRenkleri.metinBirincil(context);
    final metinIkincil = UygulamaRenkleri.metinIkincil(context);
    final kenarlik = UygulamaRenkleri.kenarlik(context);

    return Container(
      color: arkaPlan,
      child: Column(
        children: [
          // FİLTRELEME ÇUBUĞU
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: kartZemin,
              border: Border(bottom: BorderSide(color: kenarlik, width: 0.8)),
            ),
            child: Row(
              children: [
                _filtreChip('Tüm Kanıtlar', KanitFiltresi.hepsi, birincil, metinBirincil, metinIkincil),
                const SizedBox(width: 8),
                _filtreChip('Bugün', KanitFiltresi.bugun, birincil, metinBirincil, metinIkincil),
                const SizedBox(width: 8),
                _filtreChip('Benim Kanıtlarım', KanitFiltresi.sadeceBenim, birincil, metinBirincil, metinIkincil),
              ],
            ),
          ),

          // KANIT LİSTESİ
          Expanded(
            child: mesajlarAsync.when(
              data: (mesajlar) {
                var kanitMesajlari = mesajlar
                    .where((m) => m.tur == 'kanit_karti' && m.kanit != null)
                    .toList()
                    .reversed
                    .toList();

                // Filtreleme
                if (_filtre == KanitFiltresi.sadeceBenim) {
                  kanitMesajlari = kanitMesajlari.where((m) => m.gonderenId == uid).toList();
                } else if (_filtre == KanitFiltresi.bugun) {
                  final bugun = DateTime.now();
                  kanitMesajlari = kanitMesajlari.where((m) {
                    final t = m.tarih;
                    return t.year == bugun.year && t.month == bugun.month && t.day == bugun.day;
                  }).toList();
                }

                if (kanitMesajlari.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo_library_outlined, size: 56, color: metinIkincil.withValues(alpha: 0.5)),
                        const SizedBox(height: 12),
                        Text(
                          'Henüz bu filtrede kanıt fotoğrafı yok.',
                          style: TextStyle(fontWeight: FontWeight.bold, color: metinBirincil, fontSize: 15),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Görevler sekmesinden "Kanıtla" diyerek ilk alevi sen yak! 🔥',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: metinIkincil, fontSize: 13),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: kanitMesajlari.length,
                  itemBuilder: (context, index) {
                    final mesaj = kanitMesajlari[index];
                    return KanitKartiBileseni(
                      mesaj: mesaj,
                      mevcutKullaniciId: uid,
                      onTepkiVer: (_) {},
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Hata: $e', style: TextStyle(color: metinIkincil))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _filtreChip(
    String etiket,
    KanitFiltresi secenek,
    Color birincil,
    Color metinBirincil,
    Color metinIkincil,
  ) {
    final seciliMi = _filtre == secenek;

    return InkWell(
      onTap: () => setState(() => _filtre = secenek),
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: seciliMi ? birincil : birincil.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          etiket,
          style: TextStyle(
            color: seciliMi ? Colors.white : metinBirincil,
            fontSize: 12,
            fontWeight: seciliMi ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
