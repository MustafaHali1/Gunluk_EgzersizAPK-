// lib/ozellikler/bugun/alan/bugun_durumu.dart

import '../../../cekirdek/veritabani/uygulama_veritabani.dart';
import '../veri/antrenman_dao.dart';

// Bir rutinin gün içindeki tek bir alarm seansına (örn. "12:12") ait özet model.
class BugunSeansOzeti {
  final String seansSaati;
  final List<EgzersizKayitlariData> gorevKayitlari;
  final bool suresiGectiMi;

  const BugunSeansOzeti({
    required this.seansSaati,
    required this.gorevKayitlari,
    required this.suresiGectiMi,
  });

  int get seansDakika {
    final parcalar = seansSaati.split(':');
    if (parcalar.length == 2) {
      final s = int.tryParse(parcalar[0]);
      final d = int.tryParse(parcalar[1]);
      if (s != null && d != null) return (s * 60) + d;
    }
    return 0;
  }

  int get toplamSayisi => gorevKayitlari.length;

  int get yapilanSayisi =>
      gorevKayitlari.where((k) => k.durum == 'yapildi').length;

  int get bekleyenSayisi =>
      gorevKayitlari.where((k) => k.durum == 'bekliyor').length;

  bool get tamamlandiMi => toplamSayisi > 0 && bekleyenSayisi == 0;
}

// Bugün ekranındaki her bir rutinin (tüm alarm seanslarıyla birlikte) anlık ilerleme ve saat bilgisini tutan model.
class BugunRutinOzeti {
  final RutinlerData rutin;
  final List<EgzersizKayitlariData> gorevKayitlari;
  final bool suresiGectiMi;
  final String seansSaati;
  final List<BugunSeansOzeti> seanslar;

  const BugunRutinOzeti({
    required this.rutin,
    required this.gorevKayitlari,
    required this.suresiGectiMi,
    this.seansSaati = '',
    this.seanslar = const [],
  });

  // Seans saatini günün toplam dakikasına çevirir (sıralama ve yaklaşan kontrolü için).
  int get seansDakika {
    final parcalar = seansSaati.split(':');
    if (parcalar.length == 2) {
      final s = int.tryParse(parcalar[0]);
      final d = int.tryParse(parcalar[1]);
      if (s != null && d != null) return (s * 60) + d;
    }
    return (rutin.alarmSaati * 60) + rutin.alarmDakikasi;
  }

  int get toplamSayisi => gorevKayitlari.length;

  int get yapilanSayisi =>
      gorevKayitlari.where((k) => k.durum == 'yapildi').length;

  int get yapilmayanSayisi =>
      gorevKayitlari.where((k) => k.durum == 'atlandi').length;

  int get bekleyenSayisi =>
      gorevKayitlari.where((k) => k.durum == 'bekliyor').length;

  bool get tamamlandiMi => toplamSayisi > 0 && bekleyenSayisi == 0;

  double get oran => toplamSayisi == 0 ? 0.0 : yapilanSayisi / toplamSayisi;
}

// Bugün ekranının anlık rutin özetlerini, yaklaşan rutini ve hesaplanan yüzdelerini tutan durum sınıfı.
class BugunDurumu {
  final String tarih;
  final int haftaninGunu;
  final GunlukAntrenmanDetayi antrenmanDetayi;
  final Map<int, EgzersizlerData> egzersizDetayHaritasi;
  final List<BugunRutinOzeti> bugunRutinleri;
  final BugunRutinOzeti? siradakiRutin;
  final String? aktifRutinAdi;

  const BugunDurumu({
    required this.tarih,
    required this.haftaninGunu,
    required this.antrenmanDetayi,
    required this.egzersizDetayHaritasi,
    this.bugunRutinleri = const [],
    this.siradakiRutin,
    this.aktifRutinAdi,
  });

  List<EgzersizKayitlariData> get hareketler =>
      antrenmanDetayi.egzersizKayitlari;

  int get toplamHareketSayisi => hareketler.length;

  int get yapilanHareketSayisi =>
      hareketler.where((h) => h.durum == 'yapildi').length;

  int get atlananHareketSayisi =>
      hareketler.where((h) => h.durum == 'atlandi').length;

  int get bekleyenHareketSayisi =>
      hareketler.where((h) => h.durum == 'bekliyor').length;

  double get tamamlanmaOrani =>
      toplamHareketSayisi == 0 ? 0.0 : yapilanHareketSayisi / toplamHareketSayisi;

  int get tamamlanmaYuzdesi => (tamamlanmaOrani * 100).round();
}
