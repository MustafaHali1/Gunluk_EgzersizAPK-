// lib/ozellikler/bugun/alan/bugun_durumu.dart

import '../../../cekirdek/veritabani/uygulama_veritabani.dart';
import '../veri/antrenman_dao.dart';

// Bugün ekranının anlık verilerini ve hesaplanan yüzdelerini tutan durum sınıfı.
class BugunDurumu {
  final String tarih;
  final int haftaninGunu;
  final GunlukAntrenmanDetayi antrenmanDetayi;
  final Map<int, EgzersizlerData> egzersizDetayHaritasi;
  final String? aktifRutinAdi;

  const BugunDurumu({
    required this.tarih,
    required this.haftaninGunu,
    required this.antrenmanDetayi,
    required this.egzersizDetayHaritasi,
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
