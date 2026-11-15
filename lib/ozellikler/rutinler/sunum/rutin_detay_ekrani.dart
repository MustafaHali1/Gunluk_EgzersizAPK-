// lib/ozellikler/rutinler/sunum/rutin_detay_ekrani.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cekirdek/veritabani/uygulama_veritabani.dart';
import '../../../cekirdek/yardimcilar/tarih_yardimcisi.dart';
import '../../bugun/sunum/bugun_hareket_karti.dart';
import '../../bugun/sunum/bugun_kontrolcusu.dart';
import '../../bugun/veri/antrenman_deposu_uygulamasi.dart';
import '../../egzersizler/veri/egzersiz_deposu_uygulamasi.dart';
import '../veri/rutin_deposu_uygulamasi.dart';

// Tek bir rutinin bugünkü görev kayıtlarını ve detaylarını tutan durum sınıfı.
class RutinDetayDurumu {
  final RutinlerData rutin;
  final List<EgzersizKayitlariData> gorevKayitlari;
  final Map<int, EgzersizlerData> gorevDetayHaritasi;

  const RutinDetayDurumu({
    required this.rutin,
    required this.gorevKayitlari,
    required this.gorevDetayHaritasi,
  });

  int get yapilanSayisi =>
      gorevKayitlari.where((k) => k.durum == 'yapildi').length;

  int get yapilmayanSayisi =>
      gorevKayitlari.where((k) => k.durum == 'atlandi').length;

  int get bekleyenSayisi =>
      gorevKayitlari.where((k) => k.durum == 'bekliyor').length;

  int get toplamSayisi => gorevKayitlari.length;

  double get oran => toplamSayisi == 0 ? 0.0 : yapilanSayisi / toplamSayisi;
}

// Belirli bir rutinin bugünkü görev durumunu yöneten sağlayıcı.
final rutinDetayDurumuSaglayici =
    FutureProvider.family<RutinDetayDurumu?, int>((ref, rutinId) async {
      final rutin = await ref
          .read(rutinDeposuSaglayici)
          .idIleRutinGetir(rutinId);
      if (rutin == null) return null;

      final bugun = TarihYardimcisi.bugununTarihi();
      final kayitlar = await ref
          .read(antrenmanDeposuSaglayici)
          .rutinIcinGunlukKayitlariGetirVeyaOlustur(
            rutinId: rutinId,
            tarih: bugun,
          );
      final tumGorevler = await ref
          .read(egzersizDeposuSaglayici)
          .tumEgzersizleriGetir();

      return RutinDetayDurumu(
        rutin: rutin,
        gorevKayitlari: kayitlar,
        gorevDetayHaritasi: {for (final g in tumGorevler) g.id: g},
      );
    });

// Kullanıcının yalnızca görevleri "Yaptım" / "Yapmadım" işaretlediği sade rutin içi ekranı.
class RutinDetayEkrani extends ConsumerWidget {
  final int rutinId;

  const RutinDetayEkrani({
    super.key,
    required this.rutinId,
  });

  Future<void> _durumDegistir(
    WidgetRef ref,
    EgzersizKayitlariData kayit,
    String hedefDurum,
  ) async {
    final yeniDurum = kayit.durum == hedefDurum ? 'bekliyor' : hedefDurum;
    await ref
        .read(antrenmanDeposuSaglayici)
        .egzersizDurumunuGuncelle(
          egzersizKaydiId: kayit.id,
          durum: yeniDurum,
        );
    ref.invalidate(rutinDetayDurumuSaglayici(rutinId));
    ref.invalidate(bugunKontrolcusuSaglayici);
  }

  Future<void> _notKaydet(
    WidgetRef ref,
    EgzersizKayitlariData kayit,
    String notMetni,
  ) async {
    await ref
        .read(antrenmanDeposuSaglayici)
        .egzersizDurumunuGuncelle(
          egzersizKaydiId: kayit.id,
          durum: kayit.durum,
          notMetni: notMetni.trim(),
        );
    ref.invalidate(rutinDetayDurumuSaglayici(rutinId));
  }

  Future<void> _tumunuYaptim(WidgetRef ref) async {
    final simdi = DateTime.now();
    await ref
        .read(antrenmanDeposuSaglayici)
        .gununTumHareketleriniYapildiIsaretle(
          tarih: TarihYardimcisi.tarihiFormatla(simdi),
          haftaninGunu: simdi.weekday,
          rutinId: rutinId,
        );
    ref.invalidate(rutinDetayDurumuSaglayici(rutinId));
    ref.invalidate(bugunKontrolcusuSaglayici);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detayDurumu = ref.watch(rutinDetayDurumuSaglayici(rutinId));

    return detayDurumu.when(
      loading: () => Scaffold(
        appBar: AppBar(title: const Text('Rutin')),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (hata, _) => Scaffold(
        appBar: AppBar(title: const Text('Rutin')),
        body: Center(child: Text('Rutin yüklenemedi: $hata')),
      ),
      data: (durum) {
        if (durum == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Rutin')),
            body: const Center(child: Text('Rutin bulunamadı.')),
          );
        }

        final yuzde = (durum.oran * 100).round();
        return Scaffold(
          appBar: AppBar(title: Text(durum.rutin.ad)),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Bugünkü İlerleme',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '%$yuzde',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: durum.oran,
                          minHeight: 10,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${durum.yapilanSayisi}/${durum.toplamSayisi} yapıldı • ${durum.yapilmayanSayisi} yapılmadı',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                          if (durum.bekleyenSayisi > 0)
                            TextButton.icon(
                              onPressed: () => _tumunuYaptim(ref),
                              icon: const Icon(Icons.done_all, size: 18),
                              label: const Text('Tümünü Yaptım'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (durum.gorevKayitlari.isEmpty)
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'Bu rutinde henüz görev yok. Rutinlerim ekranındaki üç noktadan (⋮) Düzenle diyerek görev ekleyebilirsiniz.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                ...durum.gorevKayitlari.map(
                  (kayit) => BugunHareketKarti(
                    kayit: kayit,
                    egzersizDetayi:
                        durum.gorevDetayHaritasi[kayit.egzersizId],
                    durumDegistirildiginde: (hedefDurum) =>
                        _durumDegistir(ref, kayit, hedefDurum),
                    notKaydedildiginde: (notMetni) =>
                        _notKaydet(ref, kayit, notMetni),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
