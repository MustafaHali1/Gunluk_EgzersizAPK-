// lib/ozellikler/toplu_rutinler/sunum/ekranlar/rutin_detay_merkezi_ekrani.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../cekirdek/tema/uygulama_renkleri.dart';
import '../../alan/toplu_rutin_modeli.dart';
import '../kontrolculer/grup_kontrolcusu.dart';
import 'rutin_gorevler_ekrani.dart';
import 'rutin_kanitlar_ekrani.dart';
import 'rutin_sohbet_ekrani.dart';
import 'rutin_liderlik_ekrani.dart';
import 'rutin_ayarlari_ekrani.dart';

/// Toplu Rutin içi 4 bağımsız ekranı (Görevler, Kanıtlar, Sohbet, Liderlik)
/// koordine eden modern ve canlı senkronize (Thin UI) ana merkez ekranı.
class RutinDetayMerkeziEkrani extends ConsumerStatefulWidget {
  final TopluRutinModeli rutin;

  const RutinDetayMerkeziEkrani({
    super.key,
    required this.rutin,
  });

  @override
  ConsumerState<RutinDetayMerkeziEkrani> createState() => _RutinDetayMerkeziEkraniState();
}

class _RutinDetayMerkeziEkraniState extends ConsumerState<RutinDetayMerkeziEkrani>
    with SingleTickerProviderStateMixin {
  late final TabController _sekmeDenetleyici;
  late TopluRutinModeli _aktifRutin;

  @override
  void initState() {
    super.initState();
    _aktifRutin = widget.rutin;
    _sekmeDenetleyici = TabController(length: 4, vsync: this);
    _yerelOnbellekYukle();
  }

  Future<void> _yerelOnbellekYukle() async {
    final servis = ref.read(firestoreGrupServisiSaglayici);
    final yerel = await servis.yerelRutinOnbellegiGetir(widget.rutin.id);
    if (yerel != null && mounted) {
      setState(() => _aktifRutin = yerel);
    }
  }

  @override
  void dispose() {
    _sekmeDenetleyici.dispose();
    super.dispose();
  }

  Future<void> _ayarlariAc(TopluRutinModeli mevcutRutin) async {
    final guncel = await Navigator.push<TopluRutinModeli>(
      context,
      MaterialPageRoute(
        builder: (_) => RutinAyarlariEkrani(rutin: mevcutRutin),
      ),
    );
    if (guncel != null && mounted) {
      setState(() => _aktifRutin = guncel);
    }
  }

  @override
  Widget build(BuildContext context) {
    final seciliRutin = ref.watch(seciliTopluRutinSaglayici);
    if (seciliRutin != null && seciliRutin.id == _aktifRutin.id) {
      _aktifRutin = seciliRutin;
    }

    final birincil = UygulamaRenkleri.birincil(context);
    final metinBirincil = UygulamaRenkleri.metinBirincil(context);
    final metinIkincil = UygulamaRenkleri.metinIkincil(context);
    final kenarlik = UygulamaRenkleri.kenarlik(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _aktifRutin.baslik,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: metinBirincil,
              ),
            ),
            Text(
              'Kod: ${_aktifRutin.davetKodu} • ${_aktifRutin.uyeIdleri.length} Üye',
              style: TextStyle(fontSize: 11, color: metinIkincil),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share_outlined, color: metinBirincil),
            tooltip: 'Kodu Kopyala',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _aktifRutin.davetKodu));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Davet kodu kopyalandı: ${_aktifRutin.davetKodu} 📋'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.settings_outlined, color: metinBirincil),
            tooltip: 'Rutin Bilgisi ve İzinler',
            onPressed: () => _ayarlariAc(_aktifRutin),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(62),
          child: Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: kenarlik, width: 1)),
            ),
            child: TabBar(
              controller: _sekmeDenetleyici,
              isScrollable: false,
              indicatorColor: birincil,
              indicatorWeight: 3,
              dividerColor: Colors.transparent,
              labelColor: birincil,
              unselectedLabelColor: metinIkincil,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12.5),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12.5),
              tabs: const [
                Tab(text: 'Görevler', icon: Icon(Icons.fitness_center, size: 19)),
                Tab(text: 'Kanıtlar', icon: Icon(Icons.photo_library_outlined, size: 19)),
                Tab(text: 'Sohbet', icon: Icon(Icons.chat_outlined, size: 19)),
                Tab(text: 'Liderlik', icon: Icon(Icons.leaderboard_outlined, size: 19)),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _sekmeDenetleyici,
        children: [
          // 1. AYRI EKRAN: GÖREVLER
          RutinGorevlerEkrani(rutin: _aktifRutin),

          // 2. AYRI EKRAN: KANITLAR
          RutinKanitlarEkrani(rutin: _aktifRutin),

          // 3. AYRI EKRAN: SOHBET
          RutinSohbetEkrani(rutin: _aktifRutin),

          // 4. AYRI EKRAN: LİDERLİK
          RutinLiderlikEkrani(rutin: _aktifRutin),
        ],
      ),
    );
  }
}
