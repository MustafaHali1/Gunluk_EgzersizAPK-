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

  (DateTime, DateTime) _aralikHesapla(
    DateTime ilkBaslangicGunu,
    DateTime temizBugun,
  ) {
    if (_seciliTur == RaporAralikTuru.son7Gun) {
      final gecenGun = temizBugun.difference(ilkBaslangicGunu).inDays;
      final blokIndeksi = gecenGun >= 0 ? (gecenGun ~/ 7) : 0;
      final b = DateTime(
        ilkBaslangicGunu.year,
        ilkBaslangicGunu.month,
        ilkBaslangicGunu.day + (blokIndeksi * 7),
      );
      return (b, DateTime(b.year, b.month, b.day + 6));
    } else if (_seciliTur == RaporAralikTuru.son30Gun) {
      final gecenGun = temizBugun.difference(ilkBaslangicGunu).inDays;
      final blokIndeksi = gecenGun >= 0 ? (gecenGun ~/ 30) : 0;
      final b = DateTime(
        ilkBaslangicGunu.year,
        ilkBaslangicGunu.month,
        ilkBaslangicGunu.day + (blokIndeksi * 30),
      );
      return (b, DateTime(b.year, b.month, b.day + 29));
    } else {
      final b = _ozelBaslangic ?? ilkBaslangicGunu;
      return (b, _ozelBitis ?? DateTime(b.year, b.month, b.day + 6));
    }
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

    final doluKayitlar = gecmisKayitlar
        .where((d) => d.egzersizKayitlari.isNotEmpty)
        .toList();
    final ilkBaslangicGunu = doluKayitlar.isNotEmpty
        ? TarihYardimcisi.metindenTarihe(
            doluKayitlar.first.antrenmanKaydi.tarih,
          )
        : temizBugun;

    final (baslangic, bitis) = _aralikHesapla(ilkBaslangicGunu, temizBugun);

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

      // Bu rutinin kendi ilk kayıt gününü bul (eski rutinlerin tarihlerinden etkilenmesin)
      final rutinIlkDetay = gecmisKayitlar
          .where((d) => d.egzersizKayitlari.any((k) => k.rutinId == rutin.id))
          .firstOrNull;
      final rutinIlkGunu = rutinIlkDetay != null
          ? TarihYardimcisi.metindenTarihe(rutinIlkDetay.antrenmanKaydi.tarih)
          : temizBugun;
      final (rutinBaslangic, rutinBitis) = _aralikHesapla(
        rutinIlkGunu,
        temizBugun,
      );
      final rutinBaslangicStr = TarihYardimcisi.tarihiFormatla(rutinBaslangic);
      final rutinBitisStr = TarihYardimcisi.tarihiFormatla(rutinBitis);

      // Yalnızca bu rutine ve kendi tarih aralığına ait günlük kayıtları filtrele
      final rutineOzelKayitlar = gecmisKayitlar
          .where(
            (detay) =>
                detay.antrenmanKaydi.tarih.compareTo(rutinBaslangicStr) >= 0 &&
                detay.antrenmanKaydi.tarih.compareTo(rutinBitisStr) <= 0,
          )
          .map(
            (detay) => GunlukAntrenmanDetayi(
              antrenmanKaydi: detay.antrenmanKaydi,
              egzersizKayitlari: detay.egzersizKayitlari
                  .where((k) => k.rutinId == rutin.id)
                  .toList(),
            ),
          )
          .toList();

      final seansSaatleri = TarihYardimcisi.alarmSaatleriniCoz(
        alarmSaatleriMetni: rutin.alarmSaatleri,
        varsayilanSaat: rutin.alarmSaati,
        varsayilanDakika: rutin.alarmDakikasi,
      )
          .map(
            (e) =>
                '${e.$1.toString().padLeft(2, '0')}:${e.$2.toString().padLeft(2, '0')}',
          )
          .toList();

      final rutinTablosu = RaporOlusturucu.olustur(
        baslangic: rutinBaslangic,
        bitis: rutinBitis,
        antrenmanKayitlari: rutineOzelKayitlar,
        planliHaftaninGunleri: rutinGunleri,
        rutinEgzersizleri: rutinGorevleri,
        bugunReferansi: temizBugun,
        seansSaatleri: seansSaatleri,
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

  Future<bool> pdfOlarakPaylas({RutinRaporGrubu? grup}) async {
    final mevcut = state.value;
    if (mevcut == null && grup == null) return false;
    try {
      if (grup != null) {
        await _pdfServisi.raporuPdfOlarakPaylas(
          grup.tablo,
          rutinAdi: grup.rutinAdi,
        );
      } else {
        await _pdfServisi.raporuPdfOlarakPaylas(mevcut!.tablo);
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}

// RaporKontrolcusu sağlayıcısı.
final raporKontrolcusuSaglayici =
    AsyncNotifierProvider<RaporKontrolcusu, RaporDurumu>(RaporKontrolcusu.new);
