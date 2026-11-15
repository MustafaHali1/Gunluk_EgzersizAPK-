// lib/ozellikler/gecmis/sunum/gecmis_ekrani.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cekirdek/sabitler/uygulama_sabitleri.dart';
import '../../../cekirdek/veritabani/uygulama_veritabani.dart';
import '../../../cekirdek/yardimcilar/tarih_yardimcisi.dart';
import '../alan/seri_hesaplayici.dart';
import 'gecmis_kontrolcusu.dart';
import 'gecmis_takvim_izgarasi.dart';

// Kullanıcının geçmiş antrenman takvimini, gün detaylarını ve seri sayacını gösteren ekran.
class GecmisEkrani extends StatelessWidget {
  const GecmisEkrani({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(UygulamaSabitleri.sekmeGecmis)),
      body: const GecmisGorunumu(),
    );
  }
}

// Rapor ve Geçmiş ekranlarında ortak kullanılabilen takvim ve seri görünümü.
class GecmisGorunumu extends ConsumerWidget {
  const GecmisGorunumu({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gecmisDurumu = ref.watch(gecmisKontrolcusuSaglayici);
    final kontrolcu = ref.read(gecmisKontrolcusuSaglayici.notifier);

    return gecmisDurumu.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (h, _) => Center(child: Text('Geçmiş yüklenemedi: $h')),
      data: (durum) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _SeriSayaciKarti(seri: durum.seriSonucu),
          const SizedBox(height: 12),
          GecmisTakvimIzgarasi(
            goruntulenenAy: durum.goruntulenenAy,
            seciliTarih: durum.seciliTarih,
            gunlukKayitlar: durum.gunlukKayitlar,
            oncekiAyTiklandiginda: kontrolcu.oncekiAyaGec,
            sonrakiAyTiklandiginda: kontrolcu.sonrakiAyaGec,
            gunSecildiginde: kontrolcu.gunSec,
          ),
          const SizedBox(height: 16),
          _SeciliGunHareketDetayi(
            seciliTarih: durum.seciliTarih,
            hareketler: durum.seciliGunDetayi?.egzersizKayitlari ?? const [],
            planliGunMu: durum.planliGunler.contains(
              TarihYardimcisi.metindenTarihe(durum.seciliTarih).weekday,
            ),
          ),
        ],
      ),
    );
  }
}

// Mevcut seri ve en uzun seri sayılarını gösteren üst özet kartı.
class _SeriSayaciKarti extends StatelessWidget {
  final SeriSonucu seri;

  const _SeriSayaciKarti({required this.seri});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _SeriKutusu(
                    ikon: Icons.local_fire_department,
                    baslik: 'Mevcut Seri',
                    deger: '${seri.mevcutSeri} Gün',
                  ),
                ),
                Container(
                  width: 1,
                  height: 44,
                  color: Theme.of(context).dividerColor,
                ),
                Expanded(
                  child: _SeriKutusu(
                    ikon: Icons.emoji_events_outlined,
                    baslik: 'En Uzun Seri',
                    deger: '${seri.enUzunSeri} Gün',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Not: Rutininizde planlı olmayan dinlenme günleri serinizi bozmaz.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SeriKutusu extends StatelessWidget {
  final IconData ikon;
  final String baslik;
  final String deger;

  const _SeriKutusu({
    required this.ikon,
    required this.baslik,
    required this.deger,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(ikon, color: Theme.of(context).colorScheme.primary, size: 28),
        const SizedBox(height: 4),
        Text(baslik, style: Theme.of(context).textTheme.labelMedium),
        Text(
          deger,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }
}

// Takvimde seçilen güne ait hareket kayıtlarını ve notlarını gösteren bileşen.
class _SeciliGunHareketDetayi extends StatelessWidget {
  final String seciliTarih;
  final List<EgzersizKayitlariData> hareketler;
  final bool planliGunMu;

  const _SeciliGunHareketDetayi({
    required this.seciliTarih,
    required this.hareketler,
    required this.planliGunMu,
  });

  @override
  Widget build(BuildContext context) {
    final tarihNesnesi = TarihYardimcisi.metindenTarihe(seciliTarih);
    final baslik =
        '${TarihYardimcisi.okunabilirTarih(tarihNesnesi)} • ${TarihYardimcisi.gunAdi(tarihNesnesi.weekday)}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              baslik,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const Divider(height: 20),
            if (hareketler.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Center(
                  child: Text(
                    planliGunMu
                        ? 'Bu tarihte kaydedilmiş hareket bulunmuyor.'
                        : 'Bu tarih planlı dinlenme günü (hareket kaydı yok).',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ...hareketler.map((kayit) {
                final yapildi = kayit.durum == 'yapildi';
                final atlandi = kayit.durum == 'atlandi';
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    yapildi
                        ? Icons.check_circle
                        : atlandi
                            ? Icons.cancel
                            : Icons.schedule,
                    color: yapildi
                        ? UygulamaRenkleri.basariYesili
                        : atlandi
                            ? UygulamaRenkleri.hataKirmizisi
                            : null,
                  ),
                  title: Text(kayit.egzersizAdiKopyasi),
                  subtitle:
                      kayit.notMetni != null && kayit.notMetni!.trim().isNotEmpty
                          ? Text('Not: ${kayit.notMetni}')
                          : null,
                  trailing: Chip(
                    label: Text(
                      yapildi
                          ? 'Yaptım'
                          : atlandi
                              ? 'Yapmadım'
                              : 'Bekliyor',
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
