// lib/cekirdek/yardimcilar/tarih_yardimcisi.dart

// Tarih formatlama (YYYY-MM-DD) ve gün hesaplama işlemlerini sağlayan yardımcı sınıf.
class TarihYardimcisi {
  TarihYardimcisi._();

  // Verilen DateTime nesnesini 'YYYY-MM-DD' metnine dönüştürür.
  static String tarihiFormatla(DateTime tarih) {
    final yil = tarih.year.toString().padLeft(4, '0');
    final ay = tarih.month.toString().padLeft(2, '0');
    final gun = tarih.day.toString().padLeft(2, '0');
    return '$yil-$ay-$gun';
  }

  // Bugünün tarihini 'YYYY-MM-DD' olarak döndürür.
  static String bugununTarihi() {
    return tarihiFormatla(DateTime.now());
  }

  // 'YYYY-MM-DD' formatındaki metni DateTime nesnesine dönüştürür.
  static DateTime metindenTarihe(String tarihMetni) {
    final parcalar = tarihMetni.split('-');
    return DateTime(
      int.parse(parcalar[0]),
      int.parse(parcalar[1]),
      int.parse(parcalar[2]),
    );
  }

  // Haftanın gün numarasını (1=Pzt ... 7=Paz) kısa Türkçe güne çevirir.
  static String gunKisaAdi(int gunNo) {
    const gunler = {
      1: 'Pzt',
      2: 'Sal',
      3: 'Çar',
      4: 'Per',
      5: 'Cum',
      6: 'Cmt',
      7: 'Paz',
    };
    return gunler[gunNo] ?? '';
  }

  // Haftanın gün numarasını (1=Pazartesi ... 7=Pazar) tam Türkçe güne çevirir.
  static String gunAdi(int gunNo) {
    const gunler = {
      1: 'Pazartesi',
      2: 'Salı',
      3: 'Çarşamba',
      4: 'Perşembe',
      5: 'Cuma',
      6: 'Cumartesi',
      7: 'Pazar',
    };
    return gunler[gunNo] ?? '';
  }

  // DateTime nesnesini "15 Kasım 2026" gibi okunabilir Türkçe tarihe çevirir.
  static String okunabilirTarih(DateTime tarih) {
    const aylar = {
      1: 'Ocak',
      2: 'Şubat',
      3: 'Mart',
      4: 'Nisan',
      5: 'Mayıs',
      6: 'Haziran',
      7: 'Temmuz',
      8: 'Ağustos',
      9: 'Eylül',
      10: 'Ekim',
      11: 'Kasım',
      12: 'Aralık',
    };
    return '${tarih.day} ${aylar[tarih.month] ?? ''} ${tarih.year}';
  }
}
