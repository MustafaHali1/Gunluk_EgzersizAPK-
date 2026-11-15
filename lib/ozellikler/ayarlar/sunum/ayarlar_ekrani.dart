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
    final ertelemeDk = ref.watch(ertelemeSuresiKontrolcusuSaglayici);

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
          _ErtelemeSuresiKarti(
            seciliDakika: ertelemeDk,
            degistiginde: (dk) {
              ref
                  .read(ertelemeSuresiKontrolcusuSaglayici.notifier)
                  .ertelemeSuresiniDegistir(dk);
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

// Varsayılan alarm erteleme süresini (5 dk, 15 dk, 30 dk, 1 saat, 2 saat veya özel) ayarlayan kart.
class _ErtelemeSuresiKarti extends StatelessWidget {
  final int seciliDakika;
  final ValueChanged<int> degistiginde;

  const _ErtelemeSuresiKarti({
    required this.seciliDakika,
    required this.degistiginde,
  });

  static const _secenekler = <(int, String)>[
    (5, '5 dk'),
    (15, '15 dk'),
    (30, '30 dk'),
    (60, '1 saat'),
    (120, '2 saat'),
  ];

  Future<void> _ozelSureSor(BuildContext context) async {
    final kontrol = TextEditingController(text: seciliDakika.toString());
    final sonuc = await showDialog<int>(
      context: context,
      builder: (baglam) => AlertDialog(
        title: const Text('Özel Erteleme Süresi'),
        content: TextField(
          controller: kontrol,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Dakika (1 - 720)',
            hintText: 'Örn: 45',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(baglam).pop(),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () {
              final dk = int.tryParse(kontrol.text.trim());
              if (dk != null && dk >= 1 && dk <= 720) {
                Navigator.of(baglam).pop(dk);
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
    if (sonuc != null) {
      degistiginde(sonuc);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hazirSecenekMi = _secenekler.any((s) => s.$1 == seciliDakika);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alarm Erteleme Ayarı',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              'Bildirimdeki hızlı erteleme butonunun süresini belirleyin. Alarm çaldığında açılan ekrandan gün bitene (23:59) kadar istediğiniz süreye de erteleyebilirsiniz.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ..._secenekler.map(
                  (secenek) => ChoiceChip(
                    label: Text(secenek.$2),
                    selected: seciliDakika == secenek.$1,
                    onSelected: (_) => degistiginde(secenek.$1),
                  ),
                ),
                ChoiceChip(
                  label: Text(
                    hazirSecenekMi ? 'Özel' : 'Özel ($seciliDakika dk)',
                  ),
                  selected: !hazirSecenekMi,
                  onSelected: (_) => _ozelSureSor(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
