// lib/ozellikler/ayarlar/sunum/ayarlar_ekrani.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cekirdek/ayarlar/uygulama_tercihleri_servisi.dart';
import '../../../cekirdek/sabitler/uygulama_sabitleri.dart';
import '../../yedekleme/sunum/yedekleme_ayar_karti.dart';
import 'ayarlar_kontrolcusu.dart';
import 'hatirlatici_ayar_karti.dart';

// Sadeleştirilmiş Ayarlar ekranı: Hatırlatıcı/Alarm (ve Müzik Seçimi), Tema ve Veri Yedekleme.
class AyarlarEkrani extends ConsumerWidget {
  const AyarlarEkrani({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final istiyorMuDurumu = ref.watch(hatirlaticiIstiyorMuSaglayici);
    final muzikAdiDurumu = ref.watch(alarmMuzikAdiSaglayici);
    final hatirlaticilarDurumu = ref.watch(hatirlaticilarAkisSaglayici);
    final temaModu = ref.watch(temaModuKontrolcusuSaglayici);
    final kontrolcu = ref.read(ayarlarKontrolcusuSaglayici.notifier);
    final alarmAcikMi = istiyorMuDurumu.value ?? true;
    final muzikAdi = muzikAdiDurumu.value ?? 'Varsayılan Sistem Alarmı';

    return Scaffold(
      appBar: AppBar(title: const Text(UygulamaSabitleri.sekmeAyarlar)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _AlarmVeMuzikKarti(
            alarmAcikMi: alarmAcikMi,
            muzikAdi: muzikAdi,
            alarmAcikDegistiginde: (deger) {
              kontrolcu.hatirlaticiKullaniminiDegistir(deger);
            },
            muzikSecTiklandiginda: () async {
              final secildi = await kontrolcu.telefondanAlarmMuzigiSec();
              if (secildi && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Alarm müziği güncellendi!'),
                  ),
                );
              }
            },
            varsayilanSesTiklandiginda: () {
              kontrolcu.varsayilanAlarmSesineDon();
            },
            alarmTestTiklandiginda: () async {
              await kontrolcu.testBildirimiGonder();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Alarm çalıyor! Susturmak için bildirime dokunun veya "Sesi Durdur"a basın.',
                    ),
                  ),
                );
              }
            },
            alarmSusturTiklandiginda: () {
              kontrolcu.alarmiSustur();
            },
          ),
          if (alarmAcikMi) ...[
            const SizedBox(height: 12),
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
          ],
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
          Center(
            child: Text(
              'Günlük Egzersiz v${UygulamaSabitleri.uygulamaSurumu} • Verileriniz yalnızca cihazınızda saklanır.',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

// Hatırlatıcı/Alarm ana şalterini, MP3 müzik seçimini ve alarm testini barındıran kart.
class _AlarmVeMuzikKarti extends StatelessWidget {
  final bool alarmAcikMi;
  final String muzikAdi;
  final ValueChanged<bool> alarmAcikDegistiginde;
  final VoidCallback muzikSecTiklandiginda;
  final VoidCallback varsayilanSesTiklandiginda;
  final VoidCallback alarmTestTiklandiginda;
  final VoidCallback alarmSusturTiklandiginda;

  const _AlarmVeMuzikKarti({
    required this.alarmAcikMi,
    required this.muzikAdi,
    required this.alarmAcikDegistiginde,
    required this.muzikSecTiklandiginda,
    required this.varsayilanSesTiklandiginda,
    required this.alarmTestTiklandiginda,
    required this.alarmSusturTiklandiginda,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Icon(
                alarmAcikMi ? Icons.alarm_on : Icons.notifications_off_outlined,
                color: alarmAcikMi
                    ? Theme.of(context).colorScheme.primary
                    : null,
              ),
              title: const Text(
                'Hatırlatıcı / Uyandırma Alarmı Kullan',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                alarmAcikMi
                    ? 'Seçtiğiniz saatte çalar, bildirime dokunduğunuzda egzersiz ekranı açılır.'
                    : 'Bildirim ve alarm kapalı. İstediğiniz zaman uygulamaya girip işaretleyebilirsiniz.',
              ),
              value: alarmAcikMi,
              onChanged: alarmAcikDegistiginde,
            ),
            if (alarmAcikMi) ...[
              const Divider(),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.music_note),
                title: const Text('Alarm Sesi / Müzik'),
                subtitle: Text(muzikAdi),
                trailing: FilledButton.tonalIcon(
                  onPressed: muzikSecTiklandiginda,
                  icon: const Icon(Icons.folder_open, size: 18),
                  label: const Text('Müzik Seç'),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (muzikAdi != 'Varsayılan Sistem Alarmı')
                    TextButton.icon(
                      onPressed: varsayilanSesTiklandiginda,
                      icon: const Icon(Icons.restore, size: 18),
                      label: const Text('Varsayılan Sese Dön'),
                    ),
                  OutlinedButton.icon(
                    onPressed: alarmTestTiklandiginda,
                    icon: const Icon(Icons.volume_up, size: 18),
                    label: const Text('Alarmı Test Et'),
                  ),
                  TextButton.icon(
                    onPressed: alarmSusturTiklandiginda,
                    icon: const Icon(Icons.volume_off, size: 18),
                    label: const Text('Sesi Durdur'),
                  ),
                ],
              ),
            ],
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
