// lib/ozellikler/ayarlar/alan/hatirlatici_deposu.dart

import '../../../cekirdek/veritabani/uygulama_veritabani.dart';

// Sabah ve akşam bildirim hatırlatıcı ayarlarını yöneten soyut depo arayüzü.
abstract class HatirlaticiDeposu {
  Stream<List<HatirlaticilarData>> hatirlaticilariIzle();
  Future<List<HatirlaticilarData>> hatirlaticilariGetir();
  Future<HatirlaticilarData?> etiketeGoreGetir(String etiket);
  Future<void> hatirlaticiGuncelle({
    required String etiket,
    required int saat,
    required int dakika,
    required String haftaninGunleri,
    required bool etkinMi,
  });
}
