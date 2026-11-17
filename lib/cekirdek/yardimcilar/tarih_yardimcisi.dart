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

  // "09:00,13:30,21:00" metnini sıralı (saat, dakika) listesine çözer; boşsa varsayılan saati döndürür.
  static List<(int, int)> alarmSaatleriniCoz({
    required String alarmSaatleriMetni,
    required int varsayilanSaat,
    required int varsayilanDakika,
  }) {
    final benzersiz = <int, (int, int)>{};
    for (final parca in alarmSaatleriMetni.split(',')) {
      final temiz = parca.trim();
      if (temiz.isEmpty) continue;
      final ikiNokta = temiz.split(':');
      if (ikiNokta.length != 2) continue;
      final s = int.tryParse(ikiNokta[0].trim());
      final d = int.tryParse(ikiNokta[1].trim());
      if (s != null && d != null && s >= 0 && s <= 23 && d >= 0 && d <= 59) {
        benzersiz[(s * 60) + d] = (s, d);
      }
    }
    if (benzersiz.isEmpty) {
      return [(varsayilanSaat, varsayilanDakika)];
    }
    final siraliAnahtarlar = benzersiz.keys.toList()..sort();
    return [for (final k in siraliAnahtarlar) benzersiz[k]!];
  }

  // (saat, dakika) listesini sıralı "09:00,13:30" metnine dönüştürür.
  static String alarmSaatleriniMetneCevir(List<(int, int)> saatler) {
    final benzersiz = <int, (int, int)>{};
    for (final (s, d) in saatler) {
      benzersiz[(s * 60) + d] = (s, d);
    }
    final siraliAnahtarlar = benzersiz.keys.toList()..sort();
    return siraliAnahtarlar
        .map((k) {
          final (s, d) = benzersiz[k]!;
          return '${s.toString().padLeft(2, '0')}:${d.toString().padLeft(2, '0')}';
        })
        .join(',');
  }
}
