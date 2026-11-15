// lib/ozellikler/ayarlar/sunum/ayarlar_ekrani.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cekirdek/ayarlar/uygulama_tercihleri_servisi.dart';
import '../../../cekirdek/sabitler/uygulama_sabitleri.dart';
import '../../yedekleme/sunum/yedekleme_ayar_karti.dart';

// Sadeleştirilmiş Ayarlar ekranı: Görünüm Teması ve Veri Yedekleme / Sıfırlama.
class AyarlarEkrani extends ConsumerWidget {
  const AyarlarEkrani({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final temaModu = ref.watch(temaModuKontrolcusuSaglayici);

    return Scaffold(
      appBar: AppBar(title: const Text(UygulamaSabitleri.sekmeAyarlar)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _TemaSecimKarti(
            seciliMod: temaModu,
            degistiginde: (mod) {
              ref
                  .read(temaModuKontrolcusuSaglayici.notifier)
                  .temaModunuDegistir(mod);
            },
          ),
          const SizedBox(height: 16),
          const YedeklemeAyarKarti(),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Günlük Rutin v${UygulamaSabitleri.uygulamaSurumu} • Verileriniz yalnızca cihazınızda saklanır.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// Açık, koyu ve sistem teması seçimi sağlayan kart bileşeni.
class _TemaSecimKarti extends StatelessWidget {
  final ThemeMode seciliMod;
  final ValueChanged<ThemeMode> degistiginde;

  const _TemaSecimKarti({
    required this.seciliMod,
    required this.degistiginde,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Görünüm Teması',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.system,
                    icon: Icon(Icons.brightness_auto),
                    label: Text('Sistem'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: Icon(Icons.light_mode),
                    label: Text('Açık'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: Icon(Icons.dark_mode),
                    label: Text('Koyu'),
                  ),
                ],
                selected: {seciliMod},
                onSelectionChanged: (secim) => degistiginde(secim.first),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
