// test/yedekleme_servisi_test.dart

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunluk_egzersiz/cekirdek/hatalar/merkezi_kaydedici.dart';
import 'package:gunluk_egzersiz/cekirdek/veritabani/uygulama_veritabani.dart';
import 'package:gunluk_egzersiz/ozellikler/yedekleme/veri/yedekleme_servisi.dart';

void main() {
  late UygulamaVeritabani veritabani;
  late YedeklemeServisi yedeklemeServisi;

  setUp(() {
    veritabani = UygulamaVeritabani(NativeDatabase.memory());
    yedeklemeServisi = YedeklemeServisi(veritabani);
  });

  tearDown(() async {
    await veritabani.close();
  });

  test('JSON dışa aktarma, sıfırlama ve içe aktarma sonrası tüm veriler birebir korunur', () async {
    final egzId = await veritabani.egzersizDao.egzersizEkle(
      EgzersizlerCompanion.insert(
        ad: 'Test Squat',
        tur: 'tekrarli',
        kategori: const Value('Alt Vücut'),
      ),
    );

    final rutinId = await veritabani.rutinDao.rutinOlusturVeEgzersizleriKaydet(
      ad: 'Sabah Rutini',
      haftaninGunleri: '1,3,5',
      aktifMi: true,
      egzersizIdListesi: [egzId],
    );

    await veritabani.antrenmanDao.gunlukAntrenmanOlusturVeyaGetir(
      tarih: '2026-11-15',
      haftaninGunu: 1,
    );

    final jsonYedek = await yedeklemeServisi.verileriJsonMetnineDonustur();

    // Tüm verileri sil
    await yedeklemeServisi.tumVerileriSil();
    expect((await veritabani.egzersizDao.tumEgzersizleriGetir()).isEmpty, true);
    expect((await veritabani.rutinDao.tumRutinleriGetir()).isEmpty, true);

    // Yedekten geri yükle
    await yedeklemeServisi.jsonMetnindenGeriYukle(jsonYedek);

    final geriYuklenenEgzersizler =
        await veritabani.egzersizDao.tumEgzersizleriGetir();
    final geriYuklenenRutinler = await veritabani.rutinDao.tumRutinleriGetir();
    final geriYuklenenAntrenman =
        await veritabani.antrenmanDao.gunlukAntrenmanDetayiGetir('2026-11-15');

    expect(geriYuklenenEgzersizler.length, 1);
    expect(geriYuklenenEgzersizler.first.ad, 'Test Squat');
    expect(geriYuklenenRutinler.length, 1);
    expect(geriYuklenenRutinler.first.id, rutinId);
    expect(geriYuklenenAntrenman?.egzersizKayitlari.length, 1);
    expect(
      geriYuklenenAntrenman?.egzersizKayitlari.first.egzersizAdiKopyasi,
      'Test Squat',
    );
  });

  test('Bozuk JSON veya uyumsuz şema sürümünde anlaşılır UygulamaHatasi fırlatılır', () async {
    expect(
      () => yedeklemeServisi.jsonMetnindenGeriYukle('{bozuk_json'),
      throwsA(isA<UygulamaHatasi>()),
    );

    expect(
      () => yedeklemeServisi.jsonMetnindenGeriYukle('{"semaSurumu": 999}'),
      throwsA(isA<UygulamaHatasi>()),
    );
  });
}
