// lib/ozellikler/rapor/sunum/rapor_kontrolcusu.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cekirdek/veritabani/uygulama_veritabani.dart';
import '../../../cekirdek/yardimcilar/tarih_yardimcisi.dart';
import '../../bugun/alan/antrenman_deposu.dart';
import '../../bugun/sunum/bugun_kontrolcusu.dart';
import '../../bugun/veri/antrenman_deposu_uygulamasi.dart';
import '../../rutinler/alan/rutin_deposu.dart';
import '../../rutinler/sunum/rutin_kontrolcusu.dart';
import '../../rutinler/veri/rutin_deposu_uygulamasi.dart';
import '../alan/rapor_olusturucu.dart';
import '../veri/pdf_disa_aktarma_servisi.dart';

// Rapor ekranındaki tarih aralığı seçeneklerini belirten sabit listesi.
enum RaporAralikTuru { son7Gun, son30Gun, ozel }

// Rapor ekranının seçili tarih aralığı ve hesaplanan rapor tablosunu tutan durum sınıfı.
class RaporDurumu {
  final RaporAralikTuru aralikTuru;
  final DateTime baslangic;
  final DateTime bitis;
  final RaporTablosu tablo;

  const RaporDurumu({
    required this.aralikTuru,
    required this.baslangic,
    required this.bitis,
    required this.tablo,
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

    late DateTime adayBaslangic;
    late DateTime bitis;

    if (_seciliTur == RaporAralikTuru.son7Gun) {
      bitis = temizBugun;
      adayBaslangic = temizBugun.subtract(const Duration(days: 6));
    } else if (_seciliTur == RaporAralikTuru.son30Gun) {
      bitis = temizBugun;
      adayBaslangic = temizBugun.subtract(const Duration(days: 29));
    } else {
      adayBaslangic =
          _ozelBaslangic ?? temizBugun.subtract(const Duration(days: 6));
      bitis = _ozelBitis ?? temizBugun;
    }

    final aktifRutin = await _rutinDeposu.aktifRutiniGetir();
    Set<int> planliGunler = <int>{};
    List<EgzersizlerData> rutinEgzersizleri = const [];

    if (aktifRutin != null) {
      planliGunler = aktifRutin.haftaninGunleri
          .split(',')
          .map((e) => int.tryParse(e.trim()))
          .whereType<int>()
          .toSet();
      final detaylar = await _rutinDeposu.rutinEgzersizleriniGetir(
        aktifRutin.id,
      );
      rutinEgzersizleri = detaylar.map((d) => d.egzersiz).toList();
    }

    var kayitlar = await _antrenmanDeposu.tarihAraligindakiAntrenmanlariGetir(
      baslangicTarihi: TarihYardimcisi.tarihiFormatla(adayBaslangic),
      bitisTarihi: TarihYardimcisi.tarihiFormatla(bitis),
    );

    // Kullanıcı rutini yeni başlattıysa (örn. bugün), otomatik "Son 7/30 Gün"
    // görünümünde rutinin başlamadığı geçmiş günleri (09/11 vb.) tabloya dahil etme.
    DateTime baslangic = adayBaslangic;
    if (_seciliTur != RaporAralikTuru.ozel) {
      final ilgiliKayitlar = aktifRutin != null
          ? kayitlar
                .where((k) => k.antrenmanKaydi.rutinId == aktifRutin.id)
                .toList()
          : kayitlar;

      final referansListe = ilgiliKayitlar.isNotEmpty
          ? ilgiliKayitlar
          : kayitlar;

      if (referansListe.isEmpty) {
        baslangic = temizBugun;
      } else {
        final ilkKayitTarihi = TarihYardimcisi.metindenTarihe(
          referansListe.first.antrenmanKaydi.tarih,
        );
        if (ilkKayitTarihi.isAfter(adayBaslangic)) {
          baslangic = ilkKayitTarihi;
          kayitlar = kayitlar
              .where(
                (k) => !TarihYardimcisi.metindenTarihe(
                  k.antrenmanKaydi.tarih,
                ).isBefore(baslangic),
              )
              .toList();
        }
      }
    }

    final tablo = RaporOlusturucu.olustur(
      baslangic: baslangic,
      bitis: bitis,
      antrenmanKayitlari: kayitlar,
      planliHaftaninGunleri: planliGunler,
      rutinEgzersizleri: rutinEgzersizleri,
    );

    return RaporDurumu(
      aralikTuru: _seciliTur,
      baslangic: baslangic,
      bitis: bitis,
      tablo: tablo,
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
