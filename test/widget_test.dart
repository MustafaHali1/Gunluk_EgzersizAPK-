// test/widget_test.dart

import 'package:drift/native.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunluk_egzersiz/cekirdek/sabitler/uygulama_sabitleri.dart';
import 'package:gunluk_egzersiz/cekirdek/veritabani/uygulama_veritabani.dart';
import 'package:gunluk_egzersiz/main.dart';

void main() {
  testWidgets('Ana iskelet ve alt sekmeler ekranda görünür', (
    WidgetTester testci,
  ) async {
    final testVeritabani = UygulamaVeritabani(NativeDatabase.memory());

    await testci.pumpWidget(
      ProviderScope(
        overrides: [
          veritabaniSaglayici.overrideWithValue(testVeritabani),
        ],
        child: const GunlukEgzersizUygulamasi(),
      ),
    );
    await testci.pump();
    await testci.pump(const Duration(milliseconds: 100));

    expect(find.text(UygulamaSabitleri.sekmeBugun), findsWidgets);
    expect(find.text(UygulamaSabitleri.sekmeEgzersizler), findsOneWidget);
    expect(find.text(UygulamaSabitleri.sekmeRutinler), findsWidgets);
    expect(find.text(UygulamaSabitleri.sekmeGecmis), findsOneWidget);
    expect(find.text(UygulamaSabitleri.sekmeRapor), findsOneWidget);
    expect(find.text(UygulamaSabitleri.sekmeAyarlar), findsOneWidget);

    await testci.pumpWidget(const SizedBox.shrink());
    await testVeritabani.close();
  });
}
