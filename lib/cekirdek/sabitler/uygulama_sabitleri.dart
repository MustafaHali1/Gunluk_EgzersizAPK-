// lib/cekirdek/sabitler/uygulama_sabitleri.dart

// Uygulama genelindeki metin, kimlik ve rota sabitlerini tutan sınıf.
class UygulamaSabitleri {
  UygulamaSabitleri._();

  static const String uygulamaAdi = 'Günlük Egzersiz';
  static const String paketKimligi = 'com.mustafahali.gunlukegzersiz';
  static const String uygulamaSurumu = '0.1.0+1';

  // Rota yolları
  static const String rotaTanitim = '/tanitim';
  static const String rotaBugun = '/bugun';
  static const String rotaEgzersizler = '/egzersizler';
  static const String rotaRutinler = '/rutinler';
  static const String rotaGecmis = '/gecmis';
  static const String rotaRapor = '/rapor';
  static const String rotaAyarlar = '/ayarlar';

  // Sekme başlıkları
  static const String sekmeBugun = 'Bugün';
  static const String sekmeEgzersizler = 'Egzersizler';
  static const String sekmeRutinler = 'Rutinler';
  static const String sekmeGecmis = 'Geçmiş';
  static const String sekmeRapor = 'Rapor';
  static const String sekmeAyarlar = 'Ayarlar';

  // Hata mesajları
  static const String genelHataMesaji =
      'Beklenmeyen bir hata oluştu. Lütfen tekrar deneyin.';
}
