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
}
