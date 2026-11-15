// lib/ozellikler/gecmis/alan/seri_hesaplayici.dart

import '../../../cekirdek/yardimcilar/tarih_yardimcisi.dart';
import '../../bugun/veri/antrenman_dao.dart';

// Mevcut seri ve en uzun seri sayılarını bir arada tutan değer sınıfı.
class SeriSonucu {
  final int mevcutSeri;
  final int enUzunSeri;

  const SeriSonucu({
    required this.mevcutSeri,
    required this.enUzunSeri,
  });
}

// Planlı olmayan günlerin seriyi bozmadığı kuralına göre seri (streak) hesaplayan sınıf.
class SeriHesaplayici {
  const SeriHesaplayici._();

  // Belirli bir günün antrenman kaydının tam olarak tamamlanıp tamamlanmadığını döndürür.
  static bool gunTamamlandiMi(GunlukAntrenmanDetayi? detay) {
    if (detay == null || detay.egzersizKayitlari.isEmpty) return false;
    return detay.egzersizKayitlari.every((k) => k.durum == 'yapildi');
  }

  // Verilen günlük antrenman haritası ve planlı günlere göre mevcut ve en uzun seriyi hesaplar.
  static SeriSonucu hesapla({
    required Map<String, GunlukAntrenmanDetayi> gunlukKayitlar,
    required Set<int> planliHaftaninGunleri,
    required DateTime referansBugun,
  }) {
    if (gunlukKayitlar.isEmpty) {
      return const SeriSonucu(mevcutSeri: 0, enUzunSeri: 0);
    }

    final bugunTemiz = DateTime(
      referansBugun.year,
      referansBugun.month,
      referansBugun.day,
    );

    // En eski kayıt tarihini bul
    DateTime enEskiTarih = bugunTemiz;
    for (final tarihMetni in gunlukKayitlar.keys) {
      final t = TarihYardimcisi.metindenTarihe(tarihMetni);
      if (t.isBefore(enEskiTarih)) {
        enEskiTarih = t;
      }
    }

    int enUzun = 0;
    int geciciSeri = 0;

    // En eski tarihten bugüne kadar ilerleyerek en uzun seriyi hesapla
    var imlec = enEskiTarih;
    while (!imlec.isAfter(bugunTemiz)) {
      final anahtar = TarihYardimcisi.tarihiFormatla(imlec);
      final detay = gunlukKayitlar[anahtar];
      final tamamlandi = gunTamamlandiMi(detay);
      final planliMi = planliHaftaninGunleri.contains(imlec.weekday);
      final bugunMu = imlec.year == bugunTemiz.year &&
          imlec.month == bugunTemiz.month &&
          imlec.day == bugunTemiz.day;

      if (tamamlandi) {
        geciciSeri += 1;
        if (geciciSeri > enUzun) {
          enUzun = geciciSeri;
        }
      } else if (!planliMi) {
        // Planlı olmayan günler seriyi bozmaz, mevcut seri korunur.
      } else if (bugunMu) {
        // Bugün henüz bitmediyse geçmişten gelen seriyi sıfırlama.
      } else {
        geciciSeri = 0;
      }

      imlec = DateTime(imlec.year, imlec.month, imlec.day + 1);
    }

    return SeriSonucu(
      mevcutSeri: geciciSeri,
      enUzunSeri: enUzun,
    );
  }
}
