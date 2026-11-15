// lib/ozellikler/tanitim/sunum/tanitim_ekrani.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../cekirdek/sabitler/uygulama_sabitleri.dart';
import '../../egzersizler/alan/hazir_egzersiz_sablonu.dart';
import 'tanitim_kontrolcusu.dart';

// İlk açılışta gösterilen 3 adımlı tanıtım, alarm tercihi ve başlangıç rutini kurulum ekranı.
class TanitimEkrani extends ConsumerStatefulWidget {
  const TanitimEkrani({super.key});

  @override
  ConsumerState<TanitimEkrani> createState() => _TanitimEkraniDurumu();
}

class _TanitimEkraniDurumu extends ConsumerState<TanitimEkrani> {
  final _sayfaDenetleyicisi = PageController();
  int _aktifSayfa = 0;
  bool _hatirlaticiIstiyorMu = true;
  TimeOfDay _sabahSaati = const TimeOfDay(hour: 8, minute: 30);
  TimeOfDay _aksamSaati = const TimeOfDay(hour: 20, minute: 0);
  late final Set<int> _secilenSablonIndeksleri;

  @override
  void initState() {
    super.initState();
    _secilenSablonIndeksleri = {0, 1, 2};
  }

  @override
  void dispose() {
    _sayfaDenetleyicisi.dispose();
    super.dispose();
  }

  String _saatBicimlendir(TimeOfDay saat) {
    final s = saat.hour.toString().padLeft(2, '0');
    final d = saat.minute.toString().padLeft(2, '0');
    return '$s:$d';
  }

  Future<void> _tamamlaVeBasla() async {
    final secilenler = _secilenSablonIndeksleri
        .map((i) => hazirEgzersizSablonlari[i])
        .toList();

    final basarili = await ref
        .read(tanitimKontrolcusuSaglayici.notifier)
        .tanitimiTamamla(
          hatirlaticiIstiyorMu: _hatirlaticiIstiyorMu,
          sabahSaati: _sabahSaati,
          aksamSaati: _aksamSaati,
          secilenSablonlar: secilenler,
        );

    if (basarili && mounted) {
      context.go(UygulamaSabitleri.rotaBugun);
    }
  }

  @override
  Widget build(BuildContext context) {
    final islemDurumu = ref.watch(tanitimKontrolcusuSaglayici);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _sayfaDenetleyicisi,
                onPageChanged: (indeks) => setState(() => _aktifSayfa = indeks),
                children: [
                  const _TanitimHosGeldinizSayfasi(),
                  _TanitimBildirimSayfasi(
                    hatirlaticiIstiyorMu: _hatirlaticiIstiyorMu,
                    sabahSaatiMetni: _saatBicimlendir(_sabahSaati),
                    aksamSaatiMetni: _saatBicimlendir(_aksamSaati),
                    tercihDegistiginde: (deger) async {
                      setState(() => _hatirlaticiIstiyorMu = deger);
                      if (deger) {
                        await ref
                            .read(tanitimKontrolcusuSaglayici.notifier)
                            .bildirimIzniIste();
                      }
                    },
                    sabahSecTiklandiginda: () async {
                      final secilen = await showTimePicker(
                        context: context,
                        initialTime: _sabahSaati,
                      );
                      if (secilen != null) {
                        setState(() => _sabahSaati = secilen);
                      }
                    },
                    aksamSecTiklandiginda: () async {
                      final secilen = await showTimePicker(
                        context: context,
                        initialTime: _aksamSaati,
                      );
                      if (secilen != null) {
                        setState(() => _aksamSaati = secilen);
                      }
                    },
                  ),
                  _TanitimRutinOlusturmaSayfasi(
                    secilenIndeksler: _secilenSablonIndeksleri,
                    degistiginde: (indeks, seciliMi) {
                      setState(() {
                        if (seciliMi) {
                          _secilenSablonIndeksleri.add(indeks);
                        } else {
                          _secilenSablonIndeksleri.remove(indeks);
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(3, (i) {
                      final aktif = i == _aktifSayfa;
                      return Container(
                        margin: const EdgeInsets.only(right: 6),
                        width: aktif ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          color: aktif
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.outlineVariant,
                        ),
                      );
                    }),
                  ),
                  if (_aktifSayfa < 2)
                    FilledButton.icon(
                      onPressed: () {
                        _sayfaDenetleyicisi.nextPage(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOut,
                        );
                      },
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('İleri'),
                    )
                  else
                    FilledButton.icon(
                      onPressed: islemDurumu.isLoading ? null : _tamamlaVeBasla,
                      icon: const Icon(Icons.check),
                      label: const Text('Rutinimi Kur ve Başla'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TanitimHosGeldinizSayfasi extends StatelessWidget {
  const _TanitimHosGeldinizSayfasi();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.healing_outlined,
            size: 84,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Günlük Egzersiz\'e Hoş Geldiniz',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Fizyoterapistinizin verdiği hareketleri veya günlük sağlık rutininizi kolayca oluşturun. Her gün yaptıklarınızı "Yaptım", yapamadıklarınızı "Yapmadım" olarak işaretleyin ve doktorunuz için PDF rapor alın.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                UygulamaMetinleri.gizlilikNotu,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TanitimBildirimSayfasi extends StatelessWidget {
  final bool hatirlaticiIstiyorMu;
  final String sabahSaatiMetni;
  final String aksamSaatiMetni;
  final ValueChanged<bool> tercihDegistiginde;
  final VoidCallback sabahSecTiklandiginda;
  final VoidCallback aksamSecTiklandiginda;

  const _TanitimBildirimSayfasi({
    required this.hatirlaticiIstiyorMu,
    required this.sabahSaatiMetni,
    required this.aksamSaatiMetni,
    required this.tercihDegistiginde,
    required this.sabahSecTiklandiginda,
    required this.aksamSecTiklandiginda,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            hatirlaticiIstiyorMu
                ? Icons.alarm_on_outlined
                : Icons.notifications_off_outlined,
            size: 72,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 20),
          Text(
            'Hatırlatıcı / Uyandırma Alarmı',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          const Text(
            'İsterseniz sabah/akşam saatlerinde uyandırma alarmı gibi çalmasını sağlayabilir (Ayarlar\'dan kendi müziğinizi de seçebilirsiniz) veya bildirimleri tamamen kapatabilirsiniz.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Card(
            child: SwitchListTile(
              title: const Text(
                'Hatırlatıcı / Alarm Kullanmak İstiyorum',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                hatirlaticiIstiyorMu
                    ? 'Seçtiğiniz saatlerde alarm çalar ve tıklayınca egzersiz ekranı açılır.'
                    : 'Bildirim gönderilmez, istediğiniz zaman kendiniz girip işaretlersiniz.',
              ),
              value: hatirlaticiIstiyorMu,
              onChanged: tercihDegistiginde,
            ),
          ),
          if (hatirlaticiIstiyorMu) ...[
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                leading: const Icon(Icons.wb_sunny_outlined),
                title: const Text('Sabah Alarm Saati'),
                trailing: OutlinedButton(
                  onPressed: sabahSecTiklandiginda,
                  child: Text(sabahSaatiMetni),
                ),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.nights_stay_outlined),
                title: const Text('Akşam Alarm Saati'),
                trailing: OutlinedButton(
                  onPressed: aksamSecTiklandiginda,
                  child: Text(aksamSaatiMetni),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TanitimRutinOlusturmaSayfasi extends StatelessWidget {
  final Set<int> secilenIndeksler;
  final void Function(int indeks, bool seciliMi) degistiginde;

  const _TanitimRutinOlusturmaSayfasi({
    required this.secilenIndeksler,
    required this.degistiginde,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Fizyoterapi & Sağlık Rutininizi Seçin',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 6),
          const Text(
            'İlk rutininize eklemek istediğiniz hareketleri işaretleyin (daha sonra Rutinim sekmesinden istediğiniz hareketi kendiniz de yazabilirsiniz):',
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: hazirEgzersizSablonlari.length,
              itemBuilder: (context, indeks) {
                final sablon = hazirEgzersizSablonlari[indeks];
                final secili = secilenIndeksler.contains(indeks);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: CheckboxListTile(
                    value: secili,
                    title: Text(sablon.ad),
                    subtitle: Text('${sablon.kategori} • ${sablon.aciklama}'),
                    onChanged: (deger) {
                      degistiginde(indeks, deger ?? false);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
