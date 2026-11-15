// lib/ozellikler/gecmis/sunum/gecmis_takvim_izgarasi.dart

import 'package:flutter/material.dart';
import '../../../cekirdek/sabitler/uygulama_sabitleri.dart';
import '../../../cekirdek/yardimcilar/tarih_yardimcisi.dart';
import '../../bugun/veri/antrenman_dao.dart';
import '../alan/seri_hesaplayici.dart';

// Aylık takvim ızgarasını ve günlerin tamamlanma işaretlerini gösteren bileşen.
class GecmisTakvimIzgarasi extends StatelessWidget {
  final DateTime goruntulenenAy;
  final String seciliTarih;
  final Map<String, GunlukAntrenmanDetayi> gunlukKayitlar;
  final VoidCallback oncekiAyTiklandiginda;
  final VoidCallback sonrakiAyTiklandiginda;
  final ValueChanged<String> gunSecildiginde;

  const GecmisTakvimIzgarasi({
    super.key,
    required this.goruntulenenAy,
    required this.seciliTarih,
    required this.gunlukKayitlar,
    required this.oncekiAyTiklandiginda,
    required this.sonrakiAyTiklandiginda,
    required this.gunSecildiginde,
  });

  String _ayBasligi(DateTime ay) {
    const aylar = {
      1: 'Ocak',
      2: 'Şubat',
      3: 'Mart',
      4: 'Nisan',
      5: 'Mayıs',
      6: 'Haziran',
      7: 'Temmuz',
      8: 'Ağustos',
      9: 'Eylül',
      10: 'Ekim',
      11: 'Kasım',
      12: 'Aralık',
    };
    return '${aylar[ay.month] ?? ''} ${ay.year}';
  }

  @override
  Widget build(BuildContext context) {
    final ilkGun = DateTime(goruntulenenAy.year, goruntulenenAy.month, 1);
    final sonGunSayisi = DateTime(
      goruntulenenAy.year,
      goruntulenenAy.month + 1,
      0,
    ).day;
    final baslangicBosluk = ilkGun.weekday - 1; // Pazartesi = 0

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  onPressed: oncekiAyTiklandiginda,
                  icon: const Icon(Icons.chevron_left),
                  tooltip: 'Önceki Ay',
                ),
                Text(
                  _ayBasligi(goruntulenenAy),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                IconButton(
                  onPressed: sonrakiAyTiklandiginda,
                  icon: const Icon(Icons.chevron_right),
                  tooltip: 'Sonraki Ay',
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: List.generate(7, (i) {
                return Expanded(
                  child: Center(
                    child: Text(
                      TarihYardimcisi.gunKisaAdi(i + 1),
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: baslangicBosluk + sonGunSayisi,
              itemBuilder: (context, indeks) {
                if (indeks < baslangicBosluk) {
                  return const SizedBox.shrink();
                }
                final gunSayisi = indeks - baslangicBosluk + 1;
                final tarih = DateTime(
                  goruntulenenAy.year,
                  goruntulenenAy.month,
                  gunSayisi,
                );
                final tarihMetni = TarihYardimcisi.tarihiFormatla(tarih);
                final detay = gunlukKayitlar[tarihMetni];
                final tamMi = SeriHesaplayici.gunTamamlandiMi(detay);
                final kismiMi =
                    detay != null && detay.egzersizKayitlari.isNotEmpty && !tamMi;

                return _TakvimGunHucresi(
                  gunSayisi: gunSayisi,
                  seciliMi: tarihMetni == seciliTarih,
                  tamamlandiMi: tamMi,
                  kismiKayitVarMi: kismiMi,
                  tiklandiginda: () => gunSecildiginde(tarihMetni),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Takvimdeki tek bir gün kutusunu ve durum noktasını gösteren alt bileşen.
class _TakvimGunHucresi extends StatelessWidget {
  final int gunSayisi;
  final bool seciliMi;
  final bool tamamlandiMi;
  final bool kismiKayitVarMi;
  final VoidCallback tiklandiginda;

  const _TakvimGunHucresi({
    required this.gunSayisi,
    required this.seciliMi,
    required this.tamamlandiMi,
    required this.kismiKayitVarMi,
    required this.tiklandiginda,
  });

  @override
  Widget build(BuildContext context) {
    final renkSemasi = Theme.of(context).colorScheme;

    return InkWell(
      onTap: tiklandiginda,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          color: seciliMi
              ? renkSemasi.primaryContainer
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: seciliMi
              ? Border.all(color: renkSemasi.primary, width: 1.5)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '$gunSayisi',
              style: TextStyle(
                fontWeight: seciliMi ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(height: 2),
            if (tamamlandiMi || kismiKayitVarMi)
              Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: tamamlandiMi
                      ? UygulamaRenkleri.basariYesili
                      : UygulamaRenkleri.uyariTuruncusu,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
