// lib/main.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'cekirdek/ayarlar/uygulama_tercihleri_servisi.dart';
import 'cekirdek/hatalar/merkezi_kaydedici.dart';
import 'cekirdek/sabitler/uygulama_sabitleri.dart';
import 'cekirdek/tema/uygulama_temasi.dart';
import 'cekirdek/yonlendirme/uygulama_rotasi.dart';
import 'ozellikler/ayarlar/sunum/ayarlar_kontrolcusu.dart';
import 'ozellikler/tanitim/sunum/tanitim_kontrolcusu.dart';

Future<void> main() async {
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

  final tercihServisi = UygulamaTercihleriServisi();
  final tanitimTamamlandi = await tercihServisi.tanitimTamamlandiMiGetir();

  runApp(
    ProviderScope(
      overrides: [
        tanitimDurumuSaglayici.overrideWith(
          () => TanitimDurumuKontrolcusu(tanitimTamamlandi),
        ),
      ],
      child: const GunlukEgzersizUygulamasi(),
    ),
  );
}

// Uygulamanın kök widget sınıfı; açılışta bildirim/saat dilimi eşitlemesini ve tema modunu yönetir.
class GunlukEgzersizUygulamasi extends ConsumerStatefulWidget {
  final bool bildirimEsitlemesiniCalistir;

  const GunlukEgzersizUygulamasi({
    super.key,
    this.bildirimEsitlemesiniCalistir = true,
  });

  @override
  ConsumerState<GunlukEgzersizUygulamasi> createState() =>
      _GunlukEgzersizUygulamasiDurumu();
}

class _GunlukEgzersizUygulamasiDurumu
    extends ConsumerState<GunlukEgzersizUygulamasi> {
  @override
  void initState() {
    super.initState();
    if (widget.bildirimEsitlemesiniCalistir) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ref
              .read(ayarlarKontrolcusuSaglayici.notifier)
              .uygulamaAcilisindaBildirimleriEsitle();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final rota = ref.watch(uygulamaRotasiSaglayici);
    final temaModu = ref.watch(temaModuKontrolcusuSaglayici);

    return MaterialApp.router(
      title: UygulamaSabitleri.uygulamaAdi,
      debugShowCheckedModeBanner: false,
      theme: UygulamaTemasi.acikTema,
      darkTheme: UygulamaTemasi.koyuTema,
      themeMode: temaModu,
      routerConfig: rota,
    );
  }
}
