// test/widget_test.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gunluk_egzersiz/cekirdek/sabitler/uygulama_sabitleri.dart';
import 'package:gunluk_egzersiz/main.dart';

void main() {
  testWidgets('Ana iskelet ve alt sekmeler ekranda görünür', (
    WidgetTester testci,
  ) async {
    await testci.pumpWidget(
      const ProviderScope(child: GunlukEgzersizUygulamasi()),
    );
    await testci.pumpAndSettle();

    expect(find.text(UygulamaSabitleri.sekmeBugun), findsWidgets);
    expect(find.text(UygulamaSabitleri.sekmeEgzersizler), findsOneWidget);
    expect(find.text(UygulamaSabitleri.sekmeRutinler), findsOneWidget);
    expect(find.text(UygulamaSabitleri.sekmeGecmis), findsOneWidget);
    expect(find.text(UygulamaSabitleri.sekmeRapor), findsOneWidget);
    expect(find.text(UygulamaSabitleri.sekmeAyarlar), findsOneWidget);
  });
}
