// lib/ozellikler/bugun/sunum/bugun_kontrolcusu.dart

import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cekirdek/hatalar/merkezi_kaydedici.dart';
import '../../../cekirdek/veritabani/uygulama_veritabani.dart';
import '../../../cekirdek/yardimcilar/tarih_yardimcisi.dart';
import '../../egzersizler/alan/egzersiz_deposu.dart';
import '../../egzersizler/sunum/egzersiz_kontrolcusu.dart';
import '../../egzersizler/veri/egzersiz_deposu_uygulamasi.dart';
import '../../rutinler/alan/rutin_deposu.dart';
import '../../rutinler/veri/rutin_deposu_uygulamasi.dart';
import '../alan/antrenman_deposu.dart';
import '../alan/bugun_durumu.dart';
import '../veri/antrenman_deposu_uygulamasi.dart';

// Bugün ekranının durumunu, gece yarısı geçişini ve rutin özetlerini yöneten kontrolcü sağlayıcısı.
final bugunKontrolcusuSaglayici =
    AsyncNotifierProvider<BugunKontrolcusu, BugunDurumu>(BugunKontrolcusu.new);

// Bugün ekranı iş mantığını yöneten Riverpod AsyncNotifier sınıfı.
class BugunKontrolcusu extends AsyncNotifier<BugunDurumu> {
  Timer? _geceYarisiZamanlayici;

  AntrenmanDeposu get _antrenmanDeposu => ref.read(antrenmanDeposuSaglayici);
  EgzersizDeposu get _egzersizDeposu => ref.read(egzersizDeposuSaglayici);
  RutinDeposu get _rutinDeposu => ref.read(rutinDeposuSaglayici);

  @override
  Future<BugunDurumu> build() async {
    _geceYarisiZamanlayicisiniKur();
    ref.onDispose(() {
      _geceYarisiZamanlayici?.cancel();
    });
    return _gunuYukle();
  }

  // Gece yarısı (00:00:00) geçtiğinde uygulama açıkken ekranı otomatik yeni güne geçirir.
  void _geceYarisiZamanlayicisiniKur() {
    _geceYarisiZamanlayici?.cancel();
    final simdi = DateTime.now();
    final yarinGeceYarisi = DateTime(
      simdi.year,
      simdi.month,
      simdi.day + 1,
      0,
      0,
      2,
    );
    final kalanSure = yarinGeceYarisi.difference(simdi);

    _geceYarisiZamanlayici = Timer(kalanSure, () async {
      MerkeziKaydedici.bilgiYaz(
        'Gece yarısı geçildi, Bugün ekranı yeni güne geçiriliyor.',
      );
      await bugunuYenile();
      _geceYarisiZamanlayicisiniKur();
    });
  }

  // Bugünün planlı rutinlerini, yaklaşan saati ve görev kayıtlarını yükler.
  Future<BugunDurumu> _gunuYukle() async {
    final simdi = DateTime.now();
    final tarih = TarihYardimcisi.tarihiFormatla(simdi);
    final haftaninGunu = simdi.weekday;

    final detay = await _antrenmanDeposu.gunlukAntrenmanOlusturVeyaGetir(
      tarih: tarih,
      haftaninGunu: haftaninGunu,
    );

    final tumEgzersizler = await _egzersizDeposu.tumEgzersizleriGetir();
    final harita = <int, EgzersizlerData>{
      for (final e in tumEgzersizler) e.id: e,
    };

    final tumRutinler = await _rutinDeposu.tumRutinleriGetir();
    final buguneAitRutinler = tumRutinler.where((r) {
      if (r.sadeceTarih != null) return r.sadeceTarih == tarih;
      final gunler = r.haftaninGunleri
          .split(',')
          .map((e) => int.tryParse(e.trim()))
          .whereType<int>()
          .toSet();
      return gunler.contains(haftaninGunu);
    }).toList();

    final simdiDakika = simdi.hour * 60 + simdi.minute;
    final ozetler = <BugunRutinOzeti>[];

    for (final r in buguneAitRutinler) {
      final saatler = TarihYardimcisi.alarmSaatleriniCoz(
        alarmSaatleriMetni: r.alarmSaatleri,
        varsayilanSaat: r.alarmSaati,
        varsayilanDakika: r.alarmDakikasi,
      );
      final ilkSaatStr =
          '${saatler.first.$1.toString().padLeft(2, '0')}:${saatler.first.$2.toString().padLeft(2, '0')}';

      final seanslar = <BugunSeansOzeti>[];
      final tumRutinKayitlari = <EgzersizKayitlariData>[];

      for (final (saat, dakika) in saatler) {
        final saatStr =
            '${saat.toString().padLeft(2, '0')}:${dakika.toString().padLeft(2, '0')}';
        final seansKayitlari = detay.egzersizKayitlari
            .where(
              (k) =>
                  k.rutinId == r.id &&
                  (k.seansSaati == saatStr ||
                      (k.seansSaati.isEmpty && saatStr == ilkSaatStr)),
            )
            .toList();
        tumRutinKayitlari.addAll(seansKayitlari);

        final alarmDakika = (saat * 60) + dakika;
        final bekliyorVar = seansKayitlari.any((k) => k.durum == 'bekliyor');
        final suresiGecti = bekliyorVar && simdiDakika > alarmDakika;

        seanslar.add(
          BugunSeansOzeti(
            seansSaati: saatStr,
            gorevKayitlari: seansKayitlari,
            suresiGectiMi: suresiGecti,
          ),
        );
      }

      // Sıradaki veya en son aktif seansı belirle (üst özet kartı için)
      final bekleyenSeanslar = seanslar.where((s) => !s.tamamlandiMi).toList();
      final yaklasanSeans = bekleyenSeanslar
          .where((s) => s.seansDakika >= simdiDakika)
          .firstOrNull;
      final hedefSeans =
          yaklasanSeans ??
          (bekleyenSeanslar.isNotEmpty ? bekleyenSeanslar.first : seanslar.first);

      ozetler.add(
        BugunRutinOzeti(
          rutin: r,
          gorevKayitlari: tumRutinKayitlari,
          suresiGectiMi: hedefSeans.suresiGectiMi,
          seansSaati: hedefSeans.seansSaati,
          seanslar: seanslar,
        ),
      );
    }

    // Rutinleri hedef seans saatine göre sırala
    ozetler.sort((a, b) => a.seansDakika.compareTo(b.seansDakika));

    // Yaklaşan sıradaki rutin: tamamlanmamış ve saati henüz gelmemiş en yakın seansa sahip rutin;
    // yoksa tamamlanmamış ilk rutin.
    BugunRutinOzeti? siradaki;
    final yaklasanlar = ozetler
        .where((o) => !o.tamamlandiMi && o.seansDakika >= simdiDakika)
        .toList();

    if (yaklasanlar.isNotEmpty) {
      siradaki = yaklasanlar.first;
    } else {
      final bekleyenler = ozetler.where((o) => !o.tamamlandiMi).toList();
      if (bekleyenler.isNotEmpty) {
        siradaki = bekleyenler.first;
      }
    }

    return BugunDurumu(
      tarih: tarih,
      haftaninGunu: haftaninGunu,
      antrenmanDetayi: detay,
      egzersizDetayHaritasi: harita,
      bugunRutinleri: ozetler,
      siradakiRutin: siradaki,
      aktifRutinAdi: buguneAitRutinler.isNotEmpty
          ? buguneAitRutinler.first.ad
          : null,
    );
  }

  // Uygulama ön plana geldiğinde veya rutin değiştiğinde bugünün verisini tazeler.
  Future<void> bugunuYenile() async {
    try {
      final yeniDurum = await _gunuYukle();
      state = AsyncData(yeniDurum);
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz('Bugün ekranı yenilenemedi', hata: hata, yiginIzi: iz);
    }
  }

  // Görev durumunu değiştirir; aynı duruma tekrar basılırsa 'bekliyor' durumuna geri alır.
  Future<void> hareketDurumunuDegistir({
    required EgzersizKayitlariData kayit,
    required String hedefDurum,
  }) async {
    try {
      final yeniDurum = kayit.durum == hedefDurum ? 'bekliyor' : hedefDurum;
      await _antrenmanDeposu.egzersizDurumunuGuncelle(
        egzersizKaydiId: kayit.id,
        durum: yeniDurum,
      );
      await bugunuYenile();
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz('Görev durumu güncellenemedi', hata: hata, yiginIzi: iz);
      rethrow;
    }
  }

  // Görev için opsiyonel not kaydeder veya günceller.
  Future<void> hareketNotunuKaydet({
    required EgzersizKayitlariData kayit,
    required String notMetni,
  }) async {
    try {
      await _antrenmanDeposu.egzersizDurumunuGuncelle(
        egzersizKaydiId: kayit.id,
        durum: kayit.durum,
        notMetni: notMetni.trim(),
      );
      await bugunuYenile();
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz('Görev notu kaydedilemedi', hata: hata, yiginIzi: iz);
      rethrow;
    }
  }

  // Mevcut bir görevi bugüne tek seferlik ekler.
  Future<void> hizliMevcutEgzersizEkle({
    required EgzersizlerData egzersiz,
    String? notMetni,
  }) async {
    final mevcutDurum = state.value;
    if (mevcutDurum == null) return;

    try {
      await _antrenmanDeposu.gunlukHizliEgzersizEkle(
        antrenmanKaydiId: mevcutDurum.antrenmanDetayi.antrenmanKaydi.id,
        egzersizId: egzersiz.id,
        egzersizAdiKopyasi: egzersiz.ad,
        notMetni: notMetni?.trim().isEmpty == true ? null : notMetni?.trim(),
      );
      await bugunuYenile();
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz('Hızlı görev eklenemedi', hata: hata, yiginIzi: iz);
      rethrow;
    }
  }

  // Yeni bir görev oluşturup aynı anda bugüne ekler.
  Future<void> hizliYeniEgzersizOlusturVeEkle({
    required String ad,
    required String tur,
    int? sureSaniye,
    int? setSayisi,
    int? tekrarSayisi,
    required String kategori,
    String? notMetni,
  }) async {
    final mevcutDurum = state.value;
    if (mevcutDurum == null) return;

    try {
      final yeniEgzersizId = await _egzersizDeposu.egzersizEkle(
        ad: ad.trim(),
        aciklama: '',
        tur: tur,
        sureSaniye: sureSaniye,
        setSayisi: setSayisi,
        tekrarSayisi: tekrarSayisi,
        kategori: kategori,
      );
      ref.invalidate(egzersizKontrolcusuSaglayici);

      await _antrenmanDeposu.gunlukHizliEgzersizEkle(
        antrenmanKaydiId: mevcutDurum.antrenmanDetayi.antrenmanKaydi.id,
        egzersizId: yeniEgzersizId,
        egzersizAdiKopyasi: ad.trim(),
        notMetni: notMetni?.trim().isEmpty == true ? null : notMetni?.trim(),
      );
      await bugunuYenile();
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz('Yeni görev oluşturulamadı', hata: hata, yiginIzi: iz);
      rethrow;
    }
  }

  // Bugünün tüm bekleyen görevlerini tek dokunuşla yapıldı olarak işaretler.
  Future<void> tumunuYapildiIsaretle() async {
    final mevcutDurum = state.value;
    if (mevcutDurum == null) return;
    try {
      await _antrenmanDeposu.gununTumHareketleriniYapildiIsaretle(
        tarih: mevcutDurum.tarih,
        haftaninGunu: mevcutDurum.haftaninGunu,
      );
      await bugunuYenile();
    } catch (hata, iz) {
      MerkeziKaydedici.hataYaz('Tüm görevler yapıldı işaretlenemedi', hata: hata, yiginIzi: iz);
      rethrow;
    }
  }
}
