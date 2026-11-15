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

// Bugün ekranının durumunu, gece yarısı geçişini ve işaretlemeleri yöneten kontrolcü sağlayıcısı.
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

  // Bugünün antrenman kaydını oluşturur veya mevcut olanı ilgili egzersiz detaylarıyla yükler.
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

    final aktifRutin = await _rutinDeposu.aktifRutiniGetir();

    return BugunDurumu(
      tarih: tarih,
      haftaninGunu: haftaninGunu,
      antrenmanDetayi: detay,
      egzersizDetayHaritasi: harita,
      aktifRutinAdi: aktifRutin?.ad,
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

  // Hareket durumunu değiştirir; aynı duruma tekrar basılırsa 'bekliyor' durumuna geri alır.
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
      MerkeziKaydedici.hataYaz('Hareket durumu güncellenemedi', hata: hata, yiginIzi: iz);
      rethrow;
    }
  }

  // Hareket için opsiyonel not kaydeder veya günceller.
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
      MerkeziKaydedici.hataYaz('Hareket notu kaydedilemedi', hata: hata, yiginIzi: iz);
      rethrow;
    }
  }

  // Mevcut bir egzersizi bugüne tek seferlik hızlı hareket olarak ekler.
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
      MerkeziKaydedici.hataYaz('Hızlı egzersiz eklenemedi', hata: hata, yiginIzi: iz);
      rethrow;
    }
  }

  // Yeni bir egzersiz oluşturup aynı anda bugüne hızlı hareket olarak ekler.
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
      MerkeziKaydedici.hataYaz('Yeni hızlı egzersiz oluşturulamadı', hata: hata, yiginIzi: iz);
      rethrow;
    }
  }

  // Bugünün tüm bekleyen hareketlerini tek dokunuşla yapıldı olarak işaretler.
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
      MerkeziKaydedici.hataYaz('Tüm hareketler yapıldı işaretlenemedi', hata: hata, yiginIzi: iz);
      rethrow;
    }
  }
}
