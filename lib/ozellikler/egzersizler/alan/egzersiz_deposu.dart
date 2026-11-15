// lib/ozellikler/egzersizler/alan/egzersiz_deposu.dart

import '../../../cekirdek/veritabani/uygulama_veritabani.dart';

// Egzersiz işlemlerini tanımlayan soyut depo arayüzü.
abstract class EgzersizDeposu {
  Stream<List<EgzersizlerData>> aktifEgzersizleriIzle();
  Future<List<EgzersizlerData>> aktifEgzersizleriGetir();
  Future<List<EgzersizlerData>> tumEgzersizleriGetir();
  Future<EgzersizlerData?> idIleEgzersizGetir(int id);
  Future<int> egzersizEkle({
    required String ad,
    required String aciklama,
    required String tur,
    int? sureSaniye,
    int? setSayisi,
    int? tekrarSayisi,
    required String kategori,
  });
  Future<bool> egzersizGuncelle({
    required int id,
    required String ad,
    required String aciklama,
    required String tur,
    int? sureSaniye,
    int? setSayisi,
    int? tekrarSayisi,
    required String kategori,
    bool arsivlendiMi = false,
  });
  Future<void> egzersizArsivle(int id, {bool arsivlendiMi = true});
}
