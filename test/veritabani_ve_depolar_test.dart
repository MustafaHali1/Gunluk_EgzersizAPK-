// test/veritabani_ve_depolar_test.dart

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunluk_egzersiz/cekirdek/veritabani/uygulama_veritabani.dart';
import 'package:gunluk_egzersiz/ozellikler/ayarlar/veri/hatirlatici_deposu_uygulamasi.dart';
import 'package:gunluk_egzersiz/ozellikler/bugun/veri/antrenman_deposu_uygulamasi.dart';
import 'package:gunluk_egzersiz/ozellikler/egzersizler/veri/egzersiz_deposu_uygulamasi.dart';
import 'package:gunluk_egzersiz/ozellikler/rutinler/veri/rutin_deposu_uygulamasi.dart';

void main() {
  late UygulamaVeritabani veritabani;
  late EgzersizDeposuUygulamasi egzersizDeposu;
  late RutinDeposuUygulamasi rutinDeposu;
  late AntrenmanDeposuUygulamasi antrenmanDeposu;
  late HatirlaticiDeposuUygulamasi hatirlaticiDeposu;

  setUp(() {
    veritabani = UygulamaVeritabani(NativeDatabase.memory());
    egzersizDeposu = EgzersizDeposuUygulamasi(veritabani.egzersizDao);
    rutinDeposu = RutinDeposuUygulamasi(veritabani.rutinDao);
    antrenmanDeposu = AntrenmanDeposuUygulamasi(veritabani.antrenmanDao);
    hatirlaticiDeposu = HatirlaticiDeposuUygulamasi(veritabani.hatirlaticiDao);
  });

  tearDown(() async {
    await veritabani.close();
  });

  test('Egzersiz ekleme, güncelleme ve arşivleme (soft delete) çalışır', () async {
    final squatId = await egzersizDeposu.egzersizEkle(
      ad: 'Squat',
      aciklama: 'Bacak hareketi',
      tur: 'tekrarli',
      setSayisi: 3,
      tekrarSayisi: 15,
      kategori: 'Alt Vücut',
    );

    final plankId = await egzersizDeposu.egzersizEkle(
      ad: 'Plank',
      aciklama: 'Karın hareketi',
      tur: 'sureli',
      sureSaniye: 45,
      kategori: 'Karın',
    );

    var aktifler = await egzersizDeposu.aktifEgzersizleriGetir();
    expect(aktifler.length, 2);

    // Squat'ı arşivle
    await egzersizDeposu.egzersizArsivle(squatId);

    aktifler = await egzersizDeposu.aktifEgzersizleriGetir();
    expect(aktifler.length, 1);
    expect(aktifler.first.id, plankId);

    // Arşivlenen hareket veritabanından silinmemeli (hard delete yok)
    final tumu = await egzersizDeposu.tumEgzersizleriGetir();
    expect(tumu.length, 2);
  });

  test('Rutin oluşturma, sıralama ve aktif rutin belirleme çalışır', () async {
    final e1 = await egzersizDeposu.egzersizEkle(
      ad: 'Şınav',
      aciklama: '',
      tur: 'tekrarli',
      setSayisi: 3,
      tekrarSayisi: 10,
      kategori: 'Üst Vücut',
    );
    final e2 = await egzersizDeposu.egzersizEkle(
      ad: 'Lunge',
      aciklama: '',
      tur: 'tekrarli',
      setSayisi: 3,
      tekrarSayisi: 12,
      kategori: 'Alt Vücut',
    );

    final r1 = await rutinDeposu.rutinOlustur(
      ad: 'Sabah Rutini',
      haftaninGunleri: '1,3,5',
      aktifMi: true,
      egzersizIdListesi: [e2, e1],
    );

    final r2 = await rutinDeposu.rutinOlustur(
      ad: 'Hafta Sonu Rutini',
      haftaninGunleri: '6,7',
      aktifMi: true, // r1 pasif olmalı
      egzersizIdListesi: [e1],
    );

    final aktifRutin = await rutinDeposu.aktifRutiniGetir();
    expect(aktifRutin?.id, r2);

    final r1Hareketler = await rutinDeposu.rutinEgzersizleriniGetir(r1);
    expect(r1Hareketler.length, 2);
    expect(r1Hareketler[0].egzersiz.ad, 'Lunge');
    expect(r1Hareketler[1].egzersiz.ad, 'Şınav');
  });

  test('Günlük antrenman oluşturma, işaretleme, hızlı ekleme ve ad kopyası (snapshot) çalışır', () async {
    final egzId = await egzersizDeposu.egzersizEkle(
      ad: 'Squat',
      aciklama: '',
      tur: 'tekrarli',
      setSayisi: 3,
      tekrarSayisi: 12,
      kategori: 'Bacak',
    );

    await rutinDeposu.rutinOlustur(
      ad: 'Günlük Rutin',
      haftaninGunleri: '1,2,3,4,5,6,7',
      aktifMi: true,
      egzersizIdListesi: [egzId],
    );

    final detay = await antrenmanDeposu.gunlukAntrenmanOlusturVeyaGetir(
      tarih: '2026-11-15',
      haftaninGunu: 7,
    );

    expect(detay.egzersizKayitlari.length, 1);
    final ilkKayit = detay.egzersizKayitlari.first;
    expect(ilkKayit.egzersizAdiKopyasi, 'Squat');
    expect(ilkKayit.durum, 'bekliyor');

    // Egzersiz adı sonradan değişse bile geçmiş kayıttaki kopya (snapshot) bozulmamalı
    await egzersizDeposu.egzersizGuncelle(
      id: egzId,
      ad: 'Sumo Squat',
      aciklama: '',
      tur: 'tekrarli',
      setSayisi: 3,
      tekrarSayisi: 12,
      kategori: 'Bacak',
    );

    // Hareket durumunu 'yapildi' olarak işaretle
    await antrenmanDeposu.egzersizDurumunuGuncelle(
      egzersizKaydiId: ilkKayit.id,
      durum: 'yapildi',
      notMetni: 'Gayet rahat yapıldı',
    );

    final guncelDetay = await antrenmanDeposu.gunlukAntrenmanDetayiGetir('2026-11-15');
    expect(guncelDetay!.egzersizKayitlari.first.durum, 'yapildi');
    expect(guncelDetay.egzersizKayitlari.first.notMetni, 'Gayet rahat yapıldı');
    expect(guncelDetay.egzersizKayitlari.first.egzersizAdiKopyasi, 'Squat');
  });

  test('Varsayılan hatırlatıcılar oluşturulur ve güncellenebilir', () async {
    final hatirlaticilar = await hatirlaticiDeposu.hatirlaticilariGetir();
    expect(hatirlaticilar.length, 2);

    await hatirlaticiDeposu.hatirlaticiGuncelle(
      etiket: 'sabah',
      saat: 7,
      dakika: 45,
      haftaninGunleri: '1,2,3,4,5',
      etkinMi: false,
    );

    final sabah = await hatirlaticiDeposu.etiketeGoreGetir('sabah');
    expect(sabah?.saat, 7);
    expect(sabah?.dakika, 45);
    expect(sabah?.etkinMi, false);
  });
}
