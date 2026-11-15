// test/seri_hesaplayici_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:gunluk_egzersiz/cekirdek/veritabani/uygulama_veritabani.dart';
import 'package:gunluk_egzersiz/ozellikler/bugun/veri/antrenman_dao.dart';
import 'package:gunluk_egzersiz/ozellikler/gecmis/alan/seri_hesaplayici.dart';

GunlukAntrenmanDetayi _ornekGunOlustur({
  required int id,
  required String tarih,
  required List<String> durumlar,
}) {
  return GunlukAntrenmanDetayi(
    antrenmanKaydi: AntrenmanKayitlariData(id: id, tarih: tarih, rutinId: 1),
    egzersizKayitlari: List.generate(
      durumlar.length,
      (i) => EgzersizKayitlariData(
        id: id * 10 + i,
        antrenmanKaydiId: id,
        egzersizId: i + 1,
        egzersizAdiKopyasi: 'Hareket ${i + 1}',
        durum: durumlar[i],
        notMetni: null,
      ),
    ),
  );
}

void main() {
  test('Planlı olmayan günler seriyi bozmaz', () {
    // 2026-11-09 Pazartesi (1), 2026-11-10 Salı (2 - planlı değil), 2026-11-11 Çarşamba (3)
    final kayitlar = <String, GunlukAntrenmanDetayi>{
      '2026-11-09': _ornekGunOlustur(
        id: 1,
        tarih: '2026-11-09',
        durumlar: ['yapildi', 'yapildi'],
      ),
      '2026-11-11': _ornekGunOlustur(
        id: 2,
        tarih: '2026-11-11',
        durumlar: ['yapildi'],
      ),
    };

    final sonuc = SeriHesaplayici.hesapla(
      gunlukKayitlar: kayitlar,
      planliHaftaninGunleri: {1, 3, 5}, // Pzt, Çar, Cum planlı; Salı izin günü
      referansBugun: DateTime(2026, 11, 11),
    );

    expect(sonuc.mevcutSeri, 2);
    expect(sonuc.enUzunSeri, 2);
  });

  test('Planlı bir gün kaçırıldığında mevcut seri sıfırlanır ama en uzun seri korunur', () {
    // 09 Pzt (yapıldı), 10 Sal (yapıldı), 11 Çar (atlandı), 12 Per (yapıldı)
    final kayitlar = <String, GunlukAntrenmanDetayi>{
      '2026-11-09': _ornekGunOlustur(
        id: 1,
        tarih: '2026-11-09',
        durumlar: ['yapildi'],
      ),
      '2026-11-10': _ornekGunOlustur(
        id: 2,
        tarih: '2026-11-10',
        durumlar: ['yapildi'],
      ),
      '2026-11-11': _ornekGunOlustur(
        id: 3,
        tarih: '2026-11-11',
        durumlar: ['atlandi'],
      ),
      '2026-11-12': _ornekGunOlustur(
        id: 4,
        tarih: '2026-11-12',
        durumlar: ['yapildi'],
      ),
    };

    final sonuc = SeriHesaplayici.hesapla(
      gunlukKayitlar: kayitlar,
      planliHaftaninGunleri: {1, 2, 3, 4, 5, 6, 7},
      referansBugun: DateTime(2026, 11, 12),
    );

    expect(sonuc.mevcutSeri, 1);
    expect(sonuc.enUzunSeri, 2);
  });
}
