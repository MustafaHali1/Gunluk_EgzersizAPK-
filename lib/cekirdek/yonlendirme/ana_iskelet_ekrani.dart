// lib/cekirdek/yonlendirme/ana_iskelet_ekrani.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../sabitler/uygulama_sabitleri.dart';

// Alt gezinme çubuğunu (NavigationBar) ve aktif sekme görünümünü barındıran ana ekran iskeleti.
class AnaIskeletEkrani extends StatelessWidget {
  final StatefulNavigationShell navigasyonKabugu;

  const AnaIskeletEkrani({
    super.key,
    required this.navigasyonKabugu,
  });

  void _sekmeDegistir(int indeks) {
    navigasyonKabugu.goBranch(
      indeks,
      initialLocation: indeks == navigasyonKabugu.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigasyonKabugu,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigasyonKabugu.currentIndex,
        onDestinationSelected: _sekmeDegistir,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: UygulamaSabitleri.sekmeBugun,
          ),
          NavigationDestination(
            icon: Icon(Icons.playlist_add_check_outlined),
            selectedIcon: Icon(Icons.playlist_add_check),
            label: UygulamaSabitleri.sekmeRutinler,
          ),
          NavigationDestination(
            icon: Icon(Icons.groups_outlined),
            selectedIcon: Icon(Icons.groups),
            label: UygulamaSabitleri.sekmeTopluRutinler,
          ),
          NavigationDestination(
            icon: Icon(Icons.table_chart_outlined),
            selectedIcon: Icon(Icons.table_chart),
            label: UygulamaSabitleri.sekmeRapor,
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: UygulamaSabitleri.sekmeAyarlar,
          ),
        ],
      ),
    );
  }
}
