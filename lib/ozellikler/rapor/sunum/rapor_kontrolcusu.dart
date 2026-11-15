// lib/ozellikler/rapor/sunum/rapor_kontrolcusu.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cekirdek/veritabani/uygulama_veritabani.dart';
import '../../../cekirdek/yardimcilar/tarih_yardimcisi.dart';
import '../../bugun/alan/antrenman_deposu.dart';
import '../../bugun/sunum/bugun_kontrolcusu.dart';
import '../../bugun/veri/antrenman_dao.dart';
import '../../bugun/veri/antrenman_deposu_uygulamasi.dart';
import '../../rutinler/alan/rutin_deposu.dart';
import '../../rutinler/sunum/rutin_kontrolcusu.dart';
import '../../rutinler/veri/rutin_deposu_uygulamasi.dart';
import '../alan/rapor_olusturucu.dart';
import '../veri/pdf_disa_aktarma_servisi.dart';

// Rapor ekranındaki tarih aralığı seçeneklerini belirten sabit listesi.
enum RaporAralikTuru { son7Gun, son30Gun, ozel }

// Tek bir rutine ait ayrı rapor tablosunu tutan sınıf.
class RutinRaporGrubu {
  final int rutinId;
  final String rutinAdi;
  final RaporTablosu tablo;

  const RutinRaporGrubu({
    required this.rutinId,
    required this.rutinAdi,
    required this.tablo,
  });
}

// Rapor ekranının seçili tarih aralığı, rutin bazlı grupları ve genel PDF tablosunu tutan durum sınıfı.
class RaporDurumu {
  final RaporAralikTuru aralikTuru;
  final DateTime baslangic;
  final DateTime bitis;
  final RaporTablosu tablo;
  final List<RutinRaporGrubu> rutinGruplari;

  const RaporDurumu({
    required this.aralikTuru,
    required this.baslangic,
    required this.bitis,
    required this.tablo,
    this.rutinGruplari = const [],
  });
}

// Rapor oluşturma, tarih aralığı değiştirme ve PDF paylaşma işlemlerini yöneten kontrolcü.
class RaporKontrolcusu extends AsyncNotifier<RaporDurumu> {
  RaporAralikTuru _seciliTur = RaporAralikTuru.son7Gun;
  DateTime? _ozelBaslangic;
  DateTime? _ozelBitis;

  AntrenmanDeposu get _antrenmanDeposu => ref.read(antrenmanDeposuSaglayici);
  RutinDeposu get _rutinDeposu => ref.read(rutinDeposuSaglayici);
  PdfDisaAktarmaServisi get _pdfServisi =>
      ref.read(pdfDisaAktarmaServisiSaglayici);

  @override
  Future<RaporDurumu> build() async {
    ref.watch(bugunKontrolcusuSaglayici);
    ref.watch(tumRutinlerAkisSaglayici);
    return _raporuHesapla();
  }

  Future<RaporDurumu> _raporuHesapla() async {
    final bugun = DateTime.now();
    final temizBugun = DateTime(bugun.year, bugun.month, bugun.day);

    final tumRutinler = await _rutinDeposu.tumRutinleriGetir();
    final gecmisKayitlar = await _antrenmanDeposu
        .tarihAraligindakiAntrenmanlariGetir(
          baslangicTarihi: '2024-01-01',
          bitisTarihi: TarihYardimcisi.tarihiFormatla(temizBugun),
        );

    final ilkBaslangicGunu = gecmisKayitlar.isNotEmpty
        ? TarihYardimcisi.metindenTarihe(
            gecmisKayitlar.first.antrenmanKaydi.tarih,
          )
        : temizBugun;

    late final DateTime baslangic;
    late final DateTime bitis;

    if (_seciliTur == RaporAralikTuru.son7Gun) {
      final gecenGun = temizBugun.difference(ilkBaslangicGunu).inDays;
      final blokIndeksi = gecenGun >= 0 ? (gecenGun ~/ 7) : 0;
      baslangic = DateTime(
        ilkBaslangicGunu.year,
        ilkBaslangicGunu.month,
        ilkBaslangicGunu.day + (blokIndeksi * 7),
      );
      bitis = DateTime(
        baslangic.year,
        baslangic.month,
        baslangic.day + 6,
      );
    } else if (_seciliTur == RaporAralikTuru.son30Gun) {
      final gecenGun = temizBugun.difference(ilkBaslangicGunu).inDays;
      final blokIndeksi = gecenGun >= 0 ? (gecenGun ~/ 30) : 0;
      baslangic = DateTime(
        ilkBaslangicGunu.year,
        ilkBaslangicGunu.month,
        ilkBaslangicGunu.day + (blokIndeksi * 30),
      );
      bitis = DateTime(
        baslangic.year,
        baslangic.month,
        baslangic.day + 29,
      );
    } else {
      baslangic = _ozelBaslangic ?? ilkBaslangicGunu;
      bitis =
          _ozelBitis ??
          DateTime(baslangic.year, baslangic.month, baslangic.day + 6);
    }

    final aralikKayitlari = await _antrenmanDeposu
        .tarihAraligindakiAntrenmanlariGetir(
          baslangicTarihi: TarihYardimcisi.tarihiFormatla(baslangic),
          bitisTarihi: TarihYardimcisi.tarihiFormatla(bitis),
        );

    final tumPlanliGunler = <int>{};
    final tumGorevHaritasi = <int, EgzersizlerData>{};
    final rutinGruplari = <RutinRaporGrubu>[];

    for (final rutin in tumRutinler) {
      final rutinGunleri = <int>{};
      if (rutin.sadeceTarih == null) {
        rutinGunleri.addAll(
          rutin.haftaninGunleri
              .split(',')
              .map((e) => int.tryParse(e.trim()))
              .whereType<int>(),
        );
      } else {
        rutinGunleri.add(
          TarihYardimcisi.metindenTarihe(rutin.sadeceTarih!).weekday,
        );
      }
      tumPlanliGunler.addAll(rutinGunleri);

      final detaylar = await _rutinDeposu.rutinEgzersizleriniGetir(rutin.id);
      final rutinGorevleri = detaylar.map((d) => d.egzersiz).toList();
      for (final g in rutinGorevleri) {
        tumGorevHaritasi[g.id] = g;
      }

      // Yalnızca bu rutine ait günlük kayıtları filtrele ki rutinler birbirine karışmasın
      final rutineOzelKayitlar = aralikKayitlari
          .map(
            (detay) => GunlukAntrenmanDetayi(
              antrenmanKaydi: detay.antrenmanKaydi,
              egzersizKayitlari: detay.egzersizKayitlari
                  .where((k) => k.rutinId == rutin.id)
                  .toList(),
            ),
          )
          .toList();

      final rutinTablosu = RaporOlusturucu.olustur(
        baslangic: baslangic,
        bitis: bitis,
        antrenmanKayitlari: rutineOzelKayitlar,
        planliHaftaninGunleri: rutinGunleri,
        rutinEgzersizleri: rutinGorevleri,
        bugunReferansi: temizBugun,
      );

      rutinGruplari.add(
        RutinRaporGrubu(
          rutinId: rutin.id,
          rutinAdi: rutin.ad,
          tablo: rutinTablosu,
        ),
      );
    }

    final genelTablo = RaporOlusturucu.olustur(
      baslangic: baslangic,
      bitis: bitis,
      antrenmanKayitlari: aralikKayitlari,
      planliHaftaninGunleri: tumPlanliGunler,
      rutinEgzersizleri: tumGorevHaritasi.values.toList(),
      bugunReferansi: temizBugun,
    );

    return RaporDurumu(
      aralikTuru: _seciliTur,
      baslangic: baslangic,
      bitis: bitis,
      tablo: genelTablo,
      rutinGruplari: rutinGruplari,
    );
  }

  Future<void> aralikTuruSec(RaporAralikTuru yeniTur) async {
    _seciliTur = yeniTur;
    state = const AsyncLoading();
    state = await AsyncValue.guard(_raporuHesapla);
  }

  Future<void> ozelTarihAraligiSec(
    DateTime baslangic,
    DateTime bitis,
  ) async {
    _seciliTur = RaporAralikTuru.ozel;
    _ozelBaslangic = baslangic;
    _ozelBitis = bitis;
    state = const AsyncLoading();
    state = await AsyncValue.guard(_raporuHesapla);
  }

  Future<bool> pdfOlarakPaylas() async {
    final mevcut = state.value;
    if (mevcut == null) return false;
    try {
      await _pdfServisi.raporuPdfOlarakPaylas(mevcut.tablo);
      return true;
    } catch (_) {
      return false;
    }
  }
}

// RaporKontrolcusu sağlayıcısı.
final raporKontrolcusuSaglayici =
    AsyncNotifierProvider<RaporKontrolcusu, RaporDurumu>(RaporKontrolcusu.new);
