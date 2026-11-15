// lib/ozellikler/rapor/alan/rapor_olusturucu.dart

import '../../../cekirdek/veritabani/uygulama_veritabani.dart';
import '../../../cekirdek/yardimcilar/tarih_yardimcisi.dart';
import '../../bugun/veri/antrenman_dao.dart';
import '../../gecmis/alan/seri_hesaplayici.dart';

// Rapor tablosundaki her bir hücrenin durumunu temsil eden sabit listesi.
enum RaporHucreDurumu {
  yapildi('✅', 'YAPILDI'),
  yapilmadi('❌', 'YAPILMADI'),
  planliDegil('➖', '-');

  final String sembol;
  final String kisaMetin;
  const RaporHucreDurumu(this.sembol, this.kisaMetin);
}

// Rapor tablosundaki tek bir egzersiz satırını ve istatistiklerini tutan sınıf.
class RaporSatiri {
  final int egzersizId;
  final String egzersizAdi;
  final Map<String, RaporHucreDurumu> gunlukDurumlar;
  final int yapilanSayisi;
  final int planlananSayisi;
  final int tamamlanmaYuzdesi;

  const RaporSatiri({
    required this.egzersizId,
    required this.egzersizAdi,
    required this.gunlukDurumlar,
    required this.yapilanSayisi,
    required this.planlananSayisi,
    required this.tamamlanmaYuzdesi,
  });
}

// Belirli bir tarih aralığı için oluşturulan tüm rapor matrisini ve özetini tutan sınıf.
class RaporTablosu {
  final String baslangicTarihi;
  final String bitisTarihi;
  final List<String> gunler;
  final List<RaporSatiri> satirlar;
  final int genelTamamlanmaYuzdesi;
  final int mevcutSeri;
  final int enUzunSeri;

  const RaporTablosu({
    required this.baslangicTarihi,
    required this.bitisTarihi,
    required this.gunler,
    required this.satirlar,
    required this.genelTamamlanmaYuzdesi,
    required this.mevcutSeri,
    required this.enUzunSeri,
  });
}

// Antrenman kayıtlarından ve aktif rutinden doktor raporu tablosu üreten sınıf.
class RaporOlusturucu {
  const RaporOlusturucu._();

  static RaporTablosu olustur({
    required DateTime baslangic,
    required DateTime bitis,
    required List<GunlukAntrenmanDetayi> antrenmanKayitlari,
    required Set<int> planliHaftaninGunleri,
    required List<EgzersizlerData> rutinEgzersizleri,
    DateTime? bugunReferansi,
  }) {
    final temizBaslangic = DateTime(
      baslangic.year,
      baslangic.month,
      baslangic.day,
    );
    final temizBitis = DateTime(bitis.year, bitis.month, bitis.day);
    final temizBugun = bugunReferansi != null
        ? DateTime(
            bugunReferansi.year,
            bugunReferansi.month,
            bugunReferansi.day,
          )
        : null;

    final gunler = <String>[];
    var imlec = temizBaslangic;
    while (!imlec.isAfter(temizBitis)) {
      gunler.add(TarihYardimcisi.tarihiFormatla(imlec));
      imlec = DateTime(imlec.year, imlec.month, imlec.day + 1);
    }

    final gunlukKayitHaritasi = <String, GunlukAntrenmanDetayi>{
      for (final d in antrenmanKayitlari) d.antrenmanKaydi.tarih: d,
    };

    // Egzersiz kimliği -> Görünen Ad (geçmiş kayıtlardaki egzersizAdiKopyasi önceliklidir)
    final egzersizAdHaritasi = <int, String>{};
    final rutinEgzersizIdSeti = <int>{};

    for (final egz in rutinEgzersizleri) {
      egzersizAdHaritasi[egz.id] = egz.ad;
      rutinEgzersizIdSeti.add(egz.id);
    }

    for (final detay in antrenmanKayitlari) {
      for (final kayit in detay.egzersizKayitlari) {
        egzersizAdHaritasi[kayit.egzersizId] = kayit.egzersizAdiKopyasi;
      }
    }

    final satirlar = <RaporSatiri>[];
    int toplamYapilan = 0;
    int toplamPlanlanan = 0;

    for (final giris in egzersizAdHaritasi.entries) {
      final egzId = giris.key;
      final egzAdi = giris.value;
      final hucreler = <String, RaporHucreDurumu>{};
      int satirYapilan = 0;
      int satirPlanlanan = 0;

      for (final gunMetni in gunler) {
        final gunTarihi = TarihYardimcisi.metindenTarihe(gunMetni);
        // Gelecek günler henüz gelmediği için 'planliDegil' (➖) olarak gösterilir
        if (temizBugun != null && gunTarihi.isAfter(temizBugun)) {
          hucreler[gunMetni] = RaporHucreDurumu.planliDegil;
          continue;
        }

        final gunDetayi = gunlukKayitHaritasi[gunMetni];
        EgzersizKayitlariData? ilgiliKayit;
        if (gunDetayi != null) {
          for (final k in gunDetayi.egzersizKayitlari) {
            if (k.egzersizId == egzId) {
              ilgiliKayit = k;
              break;
            }
          }
        }

        if (ilgiliKayit != null) {
          satirPlanlanan += 1;
          if (ilgiliKayit.durum == 'yapildi') {
            hucreler[gunMetni] = RaporHucreDurumu.yapildi;
            satirYapilan += 1;
          } else {
            hucreler[gunMetni] = RaporHucreDurumu.yapilmadi;
          }
        } else {
          final buGunPlanliMi =
              planliHaftaninGunleri.contains(gunTarihi.weekday) &&
              rutinEgzersizIdSeti.contains(egzId);
          if (buGunPlanliMi) {
            satirPlanlanan += 1;
            hucreler[gunMetni] = RaporHucreDurumu.yapilmadi;
          } else {
            hucreler[gunMetni] = RaporHucreDurumu.planliDegil;
          }
        }
      }

      toplamYapilan += satirYapilan;
      toplamPlanlanan += satirPlanlanan;
      final yuzde = satirPlanlanan == 0
          ? 0
          : ((satirYapilan / satirPlanlanan) * 100).round();

      satirlar.add(
        RaporSatiri(
          egzersizId: egzId,
          egzersizAdi: egzAdi,
          gunlukDurumlar: hucreler,
          yapilanSayisi: satirYapilan,
          planlananSayisi: satirPlanlanan,
          tamamlanmaYuzdesi: yuzde,
        ),
      );
    }

    final genelYuzde = toplamPlanlanan == 0
        ? 0
        : ((toplamYapilan / toplamPlanlanan) * 100).round();

    final seri = SeriHesaplayici.hesapla(
      gunlukKayitlar: gunlukKayitHaritasi,
      planliHaftaninGunleri: planliHaftaninGunleri,
      referansBugun: temizBugun ?? temizBitis,
    );

    return RaporTablosu(
      baslangicTarihi: TarihYardimcisi.tarihiFormatla(temizBaslangic),
      bitisTarihi: TarihYardimcisi.tarihiFormatla(temizBitis),
      gunler: gunler,
      satirlar: satirlar,
      genelTamamlanmaYuzdesi: genelYuzde,
      mevcutSeri: seri.mevcutSeri,
      enUzunSeri: seri.enUzunSeri,
    );
  }
}
