// lib/ozellikler/rutinler/alan/rutin_deposu.dart

import '../../../cekirdek/veritabani/uygulama_veritabani.dart';
import '../veri/rutin_dao.dart';

// Rutin işlemlerini tanımlayan soyut depo arayüzü.
abstract class RutinDeposu {
  Stream<List<RutinlerData>> tumRutinleriIzle();
  Future<List<RutinlerData>> tumRutinleriGetir();
  Future<RutinlerData?> aktifRutiniGetir();
  Stream<RutinlerData?> aktifRutiniIzle();
  Future<int> rutinOlustur({
    required String ad,
    required String haftaninGunleri,
    required bool aktifMi,
    required List<int> egzersizIdListesi,
  });
  Future<void> rutinGuncelle({
    required int rutinId,
    required String ad,
    required String haftaninGunleri,
    required bool aktifMi,
    required List<int> egzersizIdListesi,
  });
  Future<void> aktifRutiniBelirle(int rutinId);
  Future<void> rutinSil(int rutinId);
  Future<List<RutinEgzersizDetayi>> rutinEgzersizleriniGetir(
    int rutinId, {
    bool arsivlenmisleriDahilEt = false,
  });
}
