// test/toplu_rutinler_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:gunluk_egzersiz/ozellikler/toplu_rutinler/alan/kanit_jesti.dart';
import 'package:gunluk_egzersiz/ozellikler/toplu_rutinler/alan/kullanici_profili_modeli.dart';
import 'package:gunluk_egzersiz/ozellikler/toplu_rutinler/alan/rutin_hareketi_modeli.dart';
import 'package:gunluk_egzersiz/ozellikler/toplu_rutinler/alan/toplu_rutin_modeli.dart';
import 'package:gunluk_egzersiz/ozellikler/toplu_rutinler/alan/grup_mesaj_modeli.dart';

void main() {
  group('Toplu Rutinler V2 Alan Modelleri Testleri', () {
    test('JestHavuzu rastgele geçerli bir jest dönmelidir', () {
      final jest = JestHavuzu.rastgeleJestSec();
      expect(jest.id.isNotEmpty, true);
      expect(jest.emoji.isNotEmpty, true);
      expect(jest.talimat.isNotEmpty, true);
      expect(JestHavuzu.jestler.contains(jest), true);
    });

    test('KullaniciProfiliModeli doğru serileştirilip geri çözülmelidir', () {
      final profil = KullaniciProfiliModeli(
        kullaniciId: 'test_uid_123',
        kullaniciAdi: 'zeynep',
        kazanilanKupaSayisi: 3,
        kayitTarihi: DateTime(2026, 11, 20),
      );

      final harita = profil.haritaya();
      expect(harita['kullaniciAdi'], 'zeynep');
      expect(harita['kazanilanKupaSayisi'], 3);

      final cozulmus = KullaniciProfiliModeli.haritadan(harita, 'test_uid_123');
      expect(cozulmus.kullaniciId, 'test_uid_123');
      expect(cozulmus.kullaniciAdi, 'zeynep');
      expect(cozulmus.kazanilanKupaSayisi, 3);
    });

    test('TopluRutinModeli açılışından beri geçen gün ve hareketleri doğru yönetmelidir', () {
      final acilis = DateTime.now().subtract(const Duration(days: 9));
      final hareket = const RutinHareketiModeli(
        id: 'h1',
        baslik: '20 Squat',
        tur: 'tekrarli',
        hedefDeger: 20,
        puan: 20,
        nesneGerektirirMi: false,
      );

      final rutin = TopluRutinModeli(
        id: 'rutin_1',
        baslik: 'Sabah Canlanma',
        davetKodu: 'SNAV26',
        kurucuKullaniciId: 'uid_1',
        hareketler: [hareket],
        olusturulmaTarihi: acilis,
      );

      expect(rutin.acilisindanBeriGecenGun >= 10, true);
      expect(rutin.hareketler.length, 1);
      expect(rutin.hareketler.first.baslik, '20 Squat');
    });

    test('GrupMesajModeli WhatsApp tik durumlarını ve pin durumunu korumalıdır', () {
      final mesaj = GrupMesajModeli(
        id: 'm1',
        grupId: 'r1',
        gonderenId: 'u1',
        gonderenAdi: 'Mustafa',
        tur: 'metin',
        metin: 'Bugün harikaydık!',
        tarih: DateTime.now(),
        durum: MesajGonderimDurumu.iletildi,
        sabitlendiMi: true,
      );

      final harita = mesaj.haritaya();
      expect(harita['durum'], 'iletildi');
      expect(harita['sabitlendiMi'], true);

      final cozulmus = GrupMesajModeli.haritadan(harita, 'm1');
      expect(cozulmus.durum, MesajGonderimDurumu.iletildi);
      expect(cozulmus.sabitlendiMi, true);
    });
  });
}
