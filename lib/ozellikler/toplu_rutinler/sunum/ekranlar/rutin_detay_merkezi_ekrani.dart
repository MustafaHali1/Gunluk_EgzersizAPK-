// lib/ozellikler/toplu_rutinler/sunum/ekranlar/rutin_detay_merkezi_ekrani.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../alan/toplu_rutin_modeli.dart';
import 'rutin_gorevler_ekrani.dart';
import 'rutin_kanitlar_ekrani.dart';
import 'rutin_sohbet_ekrani.dart';
import 'rutin_liderlik_ekrani.dart';
import 'rutin_ayarlari_ekrani.dart';

/// Toplu Rutin içi 4 bağımsız ekranı (Görevler, Kanıtlar, Sohbet, Liderlik)
/// koordine eden modern ve hafif (Thin UI) ana merkez ekranı.
class RutinDetayMerkeziEkrani extends StatefulWidget {
  final TopluRutinModeli rutin;

  const RutinDetayMerkeziEkrani({
    super.key,
    required this.rutin,
  });

  @override
  State<RutinDetayMerkeziEkrani> createState() => _RutinDetayMerkeziEkraniState();
}

class _RutinDetayMerkeziEkraniState extends State<RutinDetayMerkeziEkrani>
    with SingleTickerProviderStateMixin {
  late final TabController _sekmeDenetleyici;

  @override
  void initState() {
    super.initState();
    _sekmeDenetleyici = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _sekmeDenetleyici.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.rutin.baslik,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              'Kod: ${widget.rutin.davetKodu} • ${widget.rutin.uyeIdleri.length} Üye',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Kodu Kopyala',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.rutin.davetKodu));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Davet kodu kopyalandı: ${widget.rutin.davetKodu} 📋'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Rutin Bilgisi ve İzinler',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RutinAyarlariEkrani(rutin: widget.rutin),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _sekmeDenetleyici,
          isScrollable: false,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: const [
            Tab(text: 'Görevler', icon: Icon(Icons.fitness_center, size: 20)),
            Tab(text: 'Kanıtlar', icon: Icon(Icons.photo_library_outlined, size: 20)),
            Tab(text: 'Sohbet', icon: Icon(Icons.chat_outlined, size: 20)),
            Tab(text: 'Liderlik', icon: Icon(Icons.leaderboard_outlined, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _sekmeDenetleyici,
        children: [
          // 1. AYRI EKRAN: GÖREVLER
          RutinGorevlerEkrani(rutin: widget.rutin),

          // 2. AYRI EKRAN: KANITLAR
          RutinKanitlarEkrani(rutin: widget.rutin),

          // 3. AYRI EKRAN: SOHBET
          RutinSohbetEkrani(rutin: widget.rutin),

          // 4. AYRI EKRAN: LİDERLİK
          RutinLiderlikEkrani(rutin: widget.rutin),
        ],
      ),
    );
  }
}
