// lib/cekirdek/sabitler/uygulama_sabitleri.dart

import 'package:flutter/material.dart';

// Uygulama genelindeki metin, kimlik ve rota sabitlerini tutan sınıf.
class UygulamaSabitleri {
  UygulamaSabitleri._();

  static const String uygulamaAdi = 'Günlük Rutin';
  static const String paketKimligi = 'com.mustafahali.gunlukegzersiz';
  static const String uygulamaSurumu = '1.2.0+7';

  // Rota yolları
  static const String rotaTanitim = '/tanitim';
  static const String rotaBugun = '/bugun';
  static const String rotaEgzersizler = '/egzersizler';
  static const String rotaRutinler = '/rutinler';
  static const String rotaGecmis = '/gecmis';
  static const String rotaRapor = '/rapor';
  static const String rotaAyarlar = '/ayarlar';
  static const String rotaTopluRutinler = '/toplu-rutinler';

  // Sekme başlıkları
  static const String sekmeBugun = 'Bugün';
  static const String sekmeEgzersizler = 'Görevler';
  static const String sekmeRutinler = 'Rutinlerim';
  static const String sekmeTopluRutinler = 'Gruplar';
  static const String sekmeGecmis = 'Geçmiş';
  static const String sekmeRapor = 'Rapor';
  static const String sekmeAyarlar = 'Ayarlar';

  // Hata mesajları
  static const String genelHataMesaji =
      'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.';
}

// Uygulama genelindeki semantik durum ve vurgu renklerini tutan sınıf.
class UygulamaRenkleri {
  UygulamaRenkleri._();

  static const Color basariYesili = Color(0xFF16A34A);
  static const Color uyariTuruncusu = Color(0xFFDC2626);
  static const Color hataKirmizisi = Color(0xFFDC2626);
}

// Uygulama genelindeki standart boşluk, yarıçap ve minimum dokunma boyutu sabitleri.
class UygulamaBoyutlari {
  UygulamaBoyutlari._();

  static const double kartYaricapi = 12.0;
  static const double kartIcBosluk = 14.0;
  static const double altBosluk = 12.0;
  static const double dokunmaHedefiMin = 48.0;
}

// Uygulama içi yönlendirme adlarına kısa erişim sağlayan sabit sınıfı.
class RotaAdlari {
  RotaAdlari._();

  static const String tanitim = UygulamaSabitleri.rotaTanitim;
  static const String bugun = UygulamaSabitleri.rotaBugun;
  static const String egzersizler = UygulamaSabitleri.rotaEgzersizler;
  static const String rutinler = UygulamaSabitleri.rotaRutinler;
  static const String gecmis = UygulamaSabitleri.rotaGecmis;
  static const String rapor = UygulamaSabitleri.rotaRapor;
  static const String ayarlar = UygulamaSabitleri.rotaAyarlar;
}

// Ekranlarda tekrarlayan ortak buton, boş durum ve uyarı metinlerini tutan sınıf.
class UygulamaMetinleri {
  UygulamaMetinleri._();

  static const String sekmeBugun = UygulamaSabitleri.sekmeBugun;
  static const String kaydet = 'Kaydet';
  static const String iptal = 'İptal';
  static const String yaptim = 'Yaptım';
  static const String atladim = 'Yapmadım';
  static const String hizliEkle = 'Hareket Ekle';

  static const String bosBugunBaslik = 'Bugün İçin Rutin Hareketi Yok';
  static const String bosBugunAciklama =
      'Henüz bir rutin oluşturmadınız veya bugün için seçili hareket yok. "Rutinim" sekmesinden fizyoterapi / günlük hareketlerinizi ekleyebilirsiniz.';

  static const String tibbiUyariNotu =
      'Bu rapor tıbbi tavsiye değildir, kullanıcının kendi kaydıdır';
  static const String gizlilikNotu =
      'Tüm egzersiz ve takip verileriniz yalnızca kendi cihazınızda yerel olarak saklanır; hiçbir sunucuya gönderilmez.';
}
