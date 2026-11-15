// lib/ozellikler/bugun/alan/antrenman_deposu.dart

import '../veri/antrenman_dao.dart';

// Günlük antrenman ve hareket işaretleme işlemlerini tanımlayan soyut depo arayüzü.
abstract class AntrenmanDeposu {
  Future<GunlukAntrenmanDetayi?> gunlukAntrenmanDetayiGetir(String tarih);
  Future<GunlukAntrenmanDetayi> gunlukAntrenmanOlusturVeyaGetir({
    required String tarih,
    required int haftaninGunu,
  });
  Future<void> egzersizDurumunuGuncelle({
    required int egzersizKaydiId,
    required String durum,
    String? notMetni,
  });
  Future<int> gunlukHizliEgzersizEkle({
    required int antrenmanKaydiId,
    required int egzersizId,
    required String egzersizAdiKopyasi,
    String? notMetni,
  });
  Future<void> gununTumHareketleriniYapildiIsaretle({
    required String tarih,
    required int haftaninGunu,
  });
  Future<List<GunlukAntrenmanDetayi>> tarihAraligindakiAntrenmanlariGetir({
    required String baslangicTarihi,
    required String bitisTarihi,
  });
}
