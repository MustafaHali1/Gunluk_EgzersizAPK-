// lib/main.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'cekirdek/hatalar/merkezi_kaydedici.dart';
import 'cekirdek/sabitler/uygulama_sabitleri.dart';
import 'cekirdek/tema/uygulama_temasi.dart';
import 'cekirdek/yonlendirme/uygulama_rotasi.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (FlutterErrorDetails detaylar) {
    MerkeziKaydedici.hataYaz(
      'Yakalanan Flutter Arayüz Hatası',
      hata: detaylar.exception,
      yiginIzi: detaylar.stack,
    );
  };

  PlatformDispatcher.instance.onError = (Object hata, StackTrace yiginIzi) {
    MerkeziKaydedici.hataYaz(
      'Yakalanan Asenkron Platform Hatası',
      hata: hata,
      yiginIzi: yiginIzi,
    );
    return true;
  };

  runApp(const ProviderScope(child: GunlukEgzersizUygulamasi()));
}

// Uygulamanın kök widget sınıfı.
class GunlukEgzersizUygulamasi extends ConsumerWidget {
  const GunlukEgzersizUygulamasi({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rota = ref.watch(uygulamaRotasiSaglayici);

    return MaterialApp.router(
      title: UygulamaSabitleri.uygulamaAdi,
      debugShowCheckedModeBanner: false,
      theme: UygulamaTemasi.acikTema,
      darkTheme: UygulamaTemasi.koyuTema,
      themeMode: ThemeMode.system,
      routerConfig: rota,
    );
  }
}
