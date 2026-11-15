// lib/ozellikler/gecmis/sunum/gecmis_kontrolcusu.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cekirdek/yardimcilar/tarih_yardimcisi.dart';
import '../../bugun/alan/antrenman_deposu.dart';
import '../../bugun/sunum/bugun_kontrolcusu.dart';
import '../../bugun/veri/antrenman_dao.dart';
import '../../bugun/veri/antrenman_deposu_uygulamasi.dart';
import '../../rutinler/alan/rutin_deposu.dart';
import '../../rutinler/sunum/rutin_kontrolcusu.dart';
import '../../rutinler/veri/rutin_deposu_uygulamasi.dart';
import '../alan/seri_hesaplayici.dart';

// Geçmiş ekranının takvim, seçili gün ve seri bilgilerini tutan durum sınıfı.
class GecmisDurumu {
  final DateTime goruntulenenAy;
  final String seciliTarih;
  final Map<String, GunlukAntrenmanDetayi> gunlukKayitlar;
  final Set<int> planliGunler;
  final SeriSonucu seriSonucu;

  const GecmisDurumu({
    required this.goruntulenenAy,
    required this.seciliTarih,
    required this.gunlukKayitlar,
    required this.planliGunler,
    required this.seriSonucu,
  });

  GunlukAntrenmanDetayi? get seciliGunDetayi => gunlukKayitlar[seciliTarih];

  bool get hicKayitYokMu =>
      gunlukKayitlar.values.every((d) => d.egzersizKayitlari.isEmpty);

  GecmisDurumu kopyala({
    DateTime? goruntulenenAy,
    String? seciliTarih,
    Map<String, GunlukAntrenmanDetayi>? gunlukKayitlar,
    Set<int>? planliGunler,
    SeriSonucu? seriSonucu,
  }) {
    return GecmisDurumu(
      goruntulenenAy: goruntulenenAy ?? this.goruntulenenAy,
      seciliTarih: seciliTarih ?? this.seciliTarih,
      gunlukKayitlar: gunlukKayitlar ?? this.gunlukKayitlar,
      planliGunler: planliGunler ?? this.planliGunler,
      seriSonucu: seriSonucu ?? this.seriSonucu,
    );
  }
}

// Geçmiş ekranı verilerini ve takvim etkileşimlerini yöneten kontrolcü.
class GecmisKontrolcusu extends AsyncNotifier<GecmisDurumu> {
  AntrenmanDeposu get _antrenmanDeposu => ref.read(antrenmanDeposuSaglayici);
  RutinDeposu get _rutinDeposu => ref.read(rutinDeposuSaglayici);

  @override
  Future<GecmisDurumu> build() async {
    ref.watch(bugunKontrolcusuSaglayici);
    ref.watch(tumRutinlerAkisSaglayici);
    return _verileriYukle();
  }

  Future<GecmisDurumu> _verileriYukle({
    DateTime? korunanAy,
    String? korunanSeciliTarih,
  }) async {
    final simdi = DateTime.now();
    final bugunMetni = TarihYardimcisi.tarihiFormatla(simdi);

    final kayitListesi = await _antrenmanDeposu
        .tarihAraligindakiAntrenmanlariGetir(
          baslangicTarihi: '2020-01-01',
          bitisTarihi: bugunMetni,
        );

    final harita = <String, GunlukAntrenmanDetayi>{
      for (final d in kayitListesi) d.antrenmanKaydi.tarih: d,
    };

    final aktifRutin = await _rutinDeposu.aktifRutiniGetir();
    final planliGunler = aktifRutin != null
        ? aktifRutin.haftaninGunleri
              .split(',')
              .map((e) => int.tryParse(e.trim()))
              .whereType<int>()
              .toSet()
        : <int>{1, 2, 3, 4, 5, 6, 7};

    final seri = SeriHesaplayici.hesapla(
      gunlukKayitlar: harita,
      planliHaftaninGunleri: planliGunler,
      referansBugun: simdi,
    );

    return GecmisDurumu(
      goruntulenenAy: korunanAy ?? DateTime(simdi.year, simdi.month, 1),
      seciliTarih: korunanSeciliTarih ?? bugunMetni,
      gunlukKayitlar: harita,
      planliGunler: planliGunler,
      seriSonucu: seri,
    );
  }

  void oncekiAyaGec() {
    final mevcut = state.value;
    if (mevcut == null) return;
    final yeniAy = DateTime(
      mevcut.goruntulenenAy.year,
      mevcut.goruntulenenAy.month - 1,
      1,
    );
    state = AsyncData(mevcut.kopyala(goruntulenenAy: yeniAy));
  }

  void sonrakiAyaGec() {
    final mevcut = state.value;
    if (mevcut == null) return;
    final yeniAy = DateTime(
      mevcut.goruntulenenAy.year,
      mevcut.goruntulenenAy.month + 1,
      1,
    );
    state = AsyncData(mevcut.kopyala(goruntulenenAy: yeniAy));
  }

  void gunSec(String tarih) {
    final mevcut = state.value;
    if (mevcut == null) return;
    state = AsyncData(mevcut.kopyala(seciliTarih: tarih));
  }
}

// GecmisKontrolcusu sağlayıcısı.
final gecmisKontrolcusuSaglayici =
    AsyncNotifierProvider<GecmisKontrolcusu, GecmisDurumu>(
      GecmisKontrolcusu.new,
    );
