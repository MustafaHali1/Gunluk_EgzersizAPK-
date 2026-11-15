// lib/cekirdek/hatalar/merkezi_kaydedici.dart

import 'package:flutter/foundation.dart';

// Hata ve bilgi kayıtlarını yöneten merkezi yardımcı sınıf (debug'da konsola, release'de sessiz).
class MerkeziKaydedici {
  MerkeziKaydedici._();

  static void bilgiYaz(String mesaj, {String etiket = 'BILGI'}) {
    if (kDebugMode) {
      debugPrint('[$etiket] $mesaj');
    }
  }

  static void hataYaz(
    String mesaj, {
    Object? hata,
    StackTrace? yiginIzi,
    String etiket = 'HATA',
  }) {
    if (kDebugMode) {
      debugPrint('[$etiket] $mesaj');
      if (hata != null) {
        debugPrint('Hata Detayı: $hata');
      }
      if (yiginIzi != null) {
        debugPrint('Yığın İzi:\n$yiginIzi');
      }
    }
  }
}

// Katmanlar arası kontrollü hata aktarımı için özel uygulama istisnası.
class UygulamaHatasi implements Exception {
  final String kullaniciMesaji;
  final Object? orijinalHata;

  const UygulamaHatasi(this.kullaniciMesaji, {this.orijinalHata});

  @override
  String toString() => kullaniciMesaji;
}
