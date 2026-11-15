// lib/cekirdek/yonlendirme/uygulama_rotasi.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../ozellikler/ayarlar/sunum/ayarlar_ekrani.dart';
import '../../ozellikler/bugun/sunum/bugun_ekrani.dart';
import '../../ozellikler/egzersizler/sunum/egzersizler_ekrani.dart';
import '../../ozellikler/gecmis/sunum/gecmis_ekrani.dart';
import '../../ozellikler/rapor/sunum/rapor_ekrani.dart';
import '../../ozellikler/rutinler/sunum/rutinler_ekrani.dart';
import '../sabitler/uygulama_sabitleri.dart';
import 'ana_iskelet_ekrani.dart';

// Uygulama içi sayfa yönlendirmelerini yöneten GoRouter sağlayıcısı.
final uygulamaRotasiSaglayici = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: UygulamaSabitleri.rotaBugun,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, durum, navigasyonKabugu) {
          return AnaIskeletEkrani(navigasyonKabugu: navigasyonKabugu);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: UygulamaSabitleri.rotaBugun,
                builder: (context, durum) => const BugunEkrani(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: UygulamaSabitleri.rotaEgzersizler,
                builder: (context, durum) => const EgzersizlerEkrani(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: UygulamaSabitleri.rotaRutinler,
                builder: (context, durum) => const RutinlerEkrani(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: UygulamaSabitleri.rotaGecmis,
                builder: (context, durum) => const GecmisEkrani(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: UygulamaSabitleri.rotaRapor,
                builder: (context, durum) => const RaporEkrani(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: UygulamaSabitleri.rotaAyarlar,
                builder: (context, durum) => const AyarlarEkrani(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
