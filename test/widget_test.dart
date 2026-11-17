// test/widget_test.dart

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunluk_egzersiz/cekirdek/sabitler/uygulama_sabitleri.dart';
import 'package:gunluk_egzersiz/cekirdek/veritabani/uygulama_veritabani.dart';
import 'package:gunluk_egzersiz/main.dart';
import 'package:gunluk_egzersiz/ozellikler/egzersizler/sunum/egzersiz_form_alt_sayfasi.dart';
import 'package:gunluk_egzersiz/ozellikler/rutinler/sunum/rutin_detay_ekrani.dart';

void main() {
  testWidgets('Ana iskelet ve 4 alt sekme ekranda görünür', (
    WidgetTester testci,
  ) async {
    final testVeritabani = UygulamaVeritabani(NativeDatabase.memory());

    await testci.pumpWidget(
      ProviderScope(
        overrides: [
          veritabaniSaglayici.overrideWithValue(testVeritabani),
        ],
        child: const GunlukEgzersizUygulamasi(
          bildirimEsitlemesiniCalistir: false,
        ),
      ),
    );
    await testci.pump();
    await testci.pump(const Duration(milliseconds: 100));

    expect(find.text(UygulamaSabitleri.sekmeBugun), findsWidgets);
    expect(find.text(UygulamaSabitleri.sekmeRutinler), findsWidgets);
    expect(find.text(UygulamaSabitleri.sekmeRapor), findsOneWidget);
    expect(find.text(UygulamaSabitleri.sekmeAyarlar), findsOneWidget);

    await testci.pumpWidget(const SizedBox.shrink());
    await testVeritabani.close();
  });

  testWidgets('Bugün ekranında rutin kartına basınca rutin içi açılır ve Yaptım çalışır', (
    WidgetTester testci,
  ) async {
    final testVeritabani = UygulamaVeritabani(NativeDatabase.memory());
    final egzId = await testVeritabani.egzersizDao.egzersizEkle(
      EgzersizlerCompanion.insert(
        ad: 'Boyun Esnetme',
        tur: 'tekrarli',
        kategori: const Value('Genel'),
      ),
    );
    await testVeritabani.rutinDao.rutinOlusturVeEgzersizleriKaydet(
      ad: 'Sabah Rutinim',
      haftaninGunleri: '1,2,3,4,5,6,7',
      aktifMi: true,
      egzersizIdListesi: [egzId],
    );

    await testci.pumpWidget(
      ProviderScope(
        overrides: [
          veritabaniSaglayici.overrideWithValue(testVeritabani),
        ],
        child: const GunlukEgzersizUygulamasi(
          bildirimEsitlemesiniCalistir: false,
        ),
      ),
    );
    await testci.pump();
    await testci.pump(const Duration(milliseconds: 200));

    expect(find.text('Sabah Rutinim'), findsOneWidget);

    // Rutin kartına basınca rutin içi görüntüleme (kilitli) modunda açılır
    await testci.tap(find.text('Sabah Rutinim'));
    await testci.pump();
    await testci.pump(const Duration(milliseconds: 300));

    expect(find.text('Boyun Esnetme'), findsOneWidget);
    expect(find.text('Yaptım'), findsOneWidget);
    expect(find.text('Bildirim gelene kadar kilitli'), findsOneWidget);

    // Bildirim gelmeden önce Yaptım butonu kilitli olduğu için durum değişmez
    await testci.tap(find.text('Yaptım'));
    await testci.pump();
    await testci.pump(const Duration(milliseconds: 200));
    expect(find.text('%0'), findsOneWidget);

    await testci.pumpWidget(const SizedBox.shrink());
    await testVeritabani.close();
  });

  testWidgets('Bildirimden açılan rutinde Yapıldı kilitlenir, Yapılmadı açık kalır', (
    WidgetTester testci,
  ) async {
    final testVeritabani = UygulamaVeritabani(NativeDatabase.memory());
    final egzId1 = await testVeritabani.egzersizDao.egzersizEkle(
      EgzersizlerCompanion.insert(
        ad: 'Sabah İlaci',
        tur: 'tekrarli',
        kategori: const Value('Sağlık'),
      ),
    );
    final egzId2 = await testVeritabani.egzersizDao.egzersizEkle(
      EgzersizlerCompanion.insert(
        ad: 'Esneme',
        tur: 'tekrarli',
        kategori: const Value('Spor'),
      ),
    );
    final rutinId = await testVeritabani.rutinDao.rutinOlusturVeEgzersizleriKaydet(
      ad: 'Sağlık Rutini',
      haftaninGunleri: '1,2,3,4,5,6,7',
      aktifMi: true,
      alarmAcikMi: true,
      egzersizIdListesi: [egzId1, egzId2],
    );

    final gecerliTetik = DateTime.now().millisecondsSinceEpoch;
    await testci.pumpWidget(
      ProviderScope(
        overrides: [
          veritabaniSaglayici.overrideWithValue(testVeritabani),
        ],
        child: MaterialApp(
          home: RutinDetayEkrani(
            rutinId: rutinId,
            bildirimdenGeldi: true,
            bildirimTetikMilis: gecerliTetik,
          ),
        ),
      ),
    );
    await testci.pump();
    await testci.pump(const Duration(milliseconds: 300));

    // İlk görevi Yaptım işaretle -> önce onay penceresi açılır
    await testci.tap(find.text('Yaptım').first);
    await testci.pump();
    await testci.pump(const Duration(milliseconds: 200));

    expect(find.text('Yapıldı Olarak Onayla'), findsOneWidget);
    await testci.tap(find.text('Evet, Kilitle'));
    await testci.pump();
    await testci.pump(const Duration(milliseconds: 200));

    expect(find.text('Yapıldı (Kilitli)'), findsOneWidget);

    // İkinci görevi Yapmadım işaretle -> kilitlenmez, Yaptım butonu kalır
    await testci.tap(find.text('Yapmadım').last);
    await testci.pump();
    await testci.pump(const Duration(milliseconds: 200));

    expect(find.text('Yaptım'), findsOneWidget);

    await testci.pumpWidget(const SizedBox.shrink());
    await testVeritabani.close();
  });

  testWidgets('Görev ekleme formu boş ad doğrulamasını çalıştırır', (
    WidgetTester testci,
  ) async {
    final testVeritabani = UygulamaVeritabani(NativeDatabase.memory());

    await testci.pumpWidget(
      ProviderScope(
        overrides: [
          veritabaniSaglayici.overrideWithValue(testVeritabani),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: EgzersizFormAltSayfasi(),
          ),
        ),
      ),
    );
    await testci.pump();

    await testci.tap(find.text('Kaydet'));
    await testci.pump();

    expect(find.text('Lütfen egzersiz adını girin'), findsOneWidget);

    await testci.pumpWidget(const SizedBox.shrink());
    await testVeritabani.close();
  });
}
