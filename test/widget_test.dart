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

    // Rutin kartına basınca rutin içi açılır
    await testci.tap(find.text('Sabah Rutinim'));
    await testci.pump();
    await testci.pump(const Duration(milliseconds: 300));

    expect(find.text('Boyun Esnetme'), findsOneWidget);
    expect(find.text('Yaptım'), findsOneWidget);

    // "Yaptım" butonuna dokun
    await testci.tap(find.text('Yaptım'));
    await testci.pump();
    await testci.pump(const Duration(milliseconds: 200));

    expect(find.text('Yapıldı (Geri Al)'), findsOneWidget);
    expect(find.text('%100'), findsOneWidget);

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
