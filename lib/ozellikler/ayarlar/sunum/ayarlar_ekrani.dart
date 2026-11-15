// lib/ozellikler/ayarlar/sunum/ayarlar_ekrani.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cekirdek/ayarlar/uygulama_tercihleri_servisi.dart';
import '../../../cekirdek/sabitler/uygulama_sabitleri.dart';
import '../../yedekleme/sunum/yedekleme_ayar_karti.dart';
import 'ayarlar_kontrolcusu.dart';
import 'hatirlatici_ayar_karti.dart';

// Bildirim saatleri, izin durumu, tema, gizlilik ve uygulama bilgilerini sunan ekran.
class AyarlarEkrani extends ConsumerWidget {
  const AyarlarEkrani({super.key});

  void _sistemAyarlariBilgisiGoster(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (baglam) => AlertDialog(
        title: const Text('Bildirim İzni ve Pil Optimizasyonu'),
        content: const Text(
          '1. Bildirim izni reddedildiyse: Telefonunuzun Ayarlar > Uygulamalar > Günlük Egzersiz > Bildirimler bölümünden bildirimlere izin verin.\n\n'
          '2. Zamanında hatırlatma için (Android): Ayarlar > Uygulamalar > Günlük Egzersiz > Pil bölümünden "Kısıtlanmamış" (Pil optimizasyonunu kapat) seçeneğini işaretleyin.',
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(baglam).pop(),
            child: const Text('Anladım'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hatirlaticilarDurumu = ref.watch(hatirlaticilarAkisSaglayici);
    final izinDurumu = ref.watch(bildirimIzinDurumuSaglayici);
    final temaModu = ref.watch(temaModuKontrolcusuSaglayici);
    final kontrolcu = ref.read(ayarlarKontrolcusuSaglayici.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text(UygulamaSabitleri.sekmeAyarlar)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _BildirimIzinDurumKarti(
            izinDurumu: izinDurumu,
            izinIsteTiklandiginda: () async {
              final verildi = await kontrolcu.bildirimIzniIste();
              if (!verildi && context.mounted) {
                _sistemAyarlariBilgisiGoster(context);
              }
            },
            testBildirimiTiklandiginda: () async {
              final basarili = await kontrolcu.testBildirimiGonder();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      basarili
                          ? 'Test bildirimi gönderildi!'
                          : 'Test bildirimi gönderilemedi.',
                    ),
                  ),
                );
              }
            },
            rehberTiklandiginda: () => _sistemAyarlariBilgisiGoster(context),
          ),
          const SizedBox(height: 16),
          Text(
            'Hatırlatıcı Saatleri',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 8),
          hatirlaticilarDurumu.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (h, _) => Text('Hatırlatıcılar yüklenemedi: $h'),
            data: (liste) => Column(
              children: liste
                  .map(
                    (hatirlatici) => HatirlaticiAyarKarti(
                      hatirlatici: hatirlatici,
                      degistiginde: ({
                        required saat,
                        required dakika,
                        required seciliGunler,
                        required etkinMi,
                      }) {
                        kontrolcu.hatirlaticiKaydet(
                          etiket: hatirlatici.etiket,
                          saat: saat,
                          dakika: dakika,
                          seciliGunler: seciliGunler,
                          etkinMi: etkinMi,
                        );
                      },
                    ),
                  )
                  .toList(),
            ),
          ),
          const SizedBox(height: 16),
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
          const _BilgiVeSurumKarti(),
        ],
      ),
    );
  }
}

// Bildirim izin durumunu, pil optimizasyonu notunu ve test bildirimi butonunu gösteren kart.
class _BildirimIzinDurumKarti extends StatelessWidget {
  final AsyncValue<bool> izinDurumu;
  final VoidCallback izinIsteTiklandiginda;
  final VoidCallback testBildirimiTiklandiginda;
  final VoidCallback rehberTiklandiginda;

  const _BildirimIzinDurumKarti({
    required this.izinDurumu,
    required this.izinIsteTiklandiginda,
    required this.testBildirimiTiklandiginda,
    required this.rehberTiklandiginda,
  });

  @override
  Widget build(BuildContext context) {
    final izinVarMi = izinDurumu.value ?? false;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  izinVarMi ? Icons.notifications_active : Icons.notifications_off,
                  color: izinVarMi
                      ? UygulamaRenkleri.basariYesili
                      : UygulamaRenkleri.uyariTuruncusu,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    izinVarMi
                        ? 'Bildirim İzni: Verildi'
                        : 'Bildirim İzni: Kapalı veya Bekliyor',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Android cihazlarda bildirimlerin gecikmemesi için pil optimizasyonunu kapatmanız önerilir.',
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (!izinVarMi)
                  FilledButton.icon(
                    onPressed: izinIsteTiklandiginda,
                    icon: const Icon(Icons.security),
                    label: const Text('Bildirim İzni Ver'),
                  ),
                OutlinedButton.icon(
                  onPressed: testBildirimiTiklandiginda,
                  icon: const Icon(Icons.send),
                  label: const Text('Test Bildirimi Gönder'),
                ),
                TextButton.icon(
                  onPressed: rehberTiklandiginda,
                  icon: const Icon(Icons.battery_saver),
                  label: const Text('Pil & Sistem Ayarları Notu'),
                ),
              ],
            ),
          ],
        ),
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

// Gizlilik notu, sağlık uyarısı ve sürüm bilgisini gösteren kart bileşeni.
class _BilgiVeSurumKarti extends StatelessWidget {
  const _BilgiVeSurumKarti();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Gizlilik ve Sağlık Uyarısı',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.lock_outline),
              title: Text('Yerel Veri Gizliliği'),
              subtitle: Text(UygulamaMetinleri.gizlilikNotu),
            ),
            const ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.health_and_safety_outlined),
              title: Text('Tıbbi Uyarı'),
              subtitle: Text(UygulamaMetinleri.tibbiUyariNotu),
            ),
            const Divider(),
            Text(
              'Uygulama Sürümü: ${UygulamaSabitleri.uygulamaSurumu}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
