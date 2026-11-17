// lib/ozellikler/rutinler/sunum/rutinler_ekrani.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cekirdek/veritabani/uygulama_veritabani.dart';
import '../../../cekirdek/yardimcilar/tarih_yardimcisi.dart';
import 'rutin_detay_ekrani.dart';
import 'rutin_form_ekrani.dart';
import 'rutin_kontrolcusu.dart';

// Kullanıcının rutinlerini listelediği, tıklayınca içine girdiği ve (⋮) ile düzenlediği ekran.
class RutinlerEkrani extends ConsumerWidget {
  const RutinlerEkrani({super.key});

  Future<void> _rutinDetayAc(BuildContext context, int rutinId) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RutinDetayEkrani(rutinId: rutinId),
      ),
    );
  }

  Future<void> _rutinFormAc(
    BuildContext context, {
    RutinlerData? rutin,
  }) async {
    await Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (_) => RutinFormEkrani(duzenlenecekRutin: rutin),
      ),
    );
  }

  String _altBilgiOlustur(RutinlerData r) {
    final gunBilgisi = r.sadeceTarih != null
        ? 'Sadece ${r.sadeceTarih}'
        : _gunleriFormatla(r.haftaninGunleri);
    if (!r.alarmAcikMi) return gunBilgisi;
    final saatler = TarihYardimcisi.alarmSaatleriniCoz(
      alarmSaatleriMetni: r.alarmSaatleri,
      varsayilanSaat: r.alarmSaati,
      varsayilanDakika: r.alarmDakikasi,
    );
    final saatMetni = saatler
        .map(
          (e) =>
              '${e.$1.toString().padLeft(2, '0')}:${e.$2.toString().padLeft(2, '0')}',
        )
        .join(', ');
    return '$gunBilgisi • ⏰ $saatMetni';
  }

  String _gunleriFormatla(String haftaninGunleri) {
    final gunNolari = haftaninGunleri
        .split(',')
        .map((e) => int.tryParse(e.trim()))
        .whereType<int>()
        .toList();
    if (gunNolari.length == 7) return 'Her gün';
    return gunNolari.map(TarihYardimcisi.gunKisaAdi).join(', ');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rutinlerDurumu = ref.watch(tumRutinlerAkisSaglayici);

    return Scaffold(
      appBar: AppBar(title: const Text('Rutinlerim')),
      body: rutinlerDurumu.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (hata, _) => Center(child: Text(hata.toString())),
        data: (liste) {
          if (liste.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.checklist_rtl,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Henüz rutin oluşturulmadı',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Kendi görevlerinizi yazıp gün ve alarm saati belirlemek için yeni bir rutin oluşturun.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () => _rutinFormAc(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Yeni Rutin Oluştur'),
                    ),
                  ],
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
            itemCount: liste.length,
            itemBuilder: (context, indeks) {
              final r = liste[indeks];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(
                      r.alarmAcikMi ? Icons.alarm_on : Icons.playlist_add_check,
                    ),
                  ),
                  title: Text(
                    r.ad,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(_altBilgiOlustur(r)),
                  onTap: () => _rutinDetayAc(context, r.id),
                  trailing: PopupMenuButton<String>(
                    tooltip: 'Rutin Ayarları',
                    onSelected: (secim) async {
                      if (secim == 'duzenle') {
                        await _rutinFormAc(context, rutin: r);
                      } else if (secim == 'sil') {
                        await ref
                            .read(rutinKontrolcusuSaglayici.notifier)
                            .rutinSil(r.id);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'duzenle',
                        child: Text('Düzenle (Görevler / Alarm / Günler)'),
                      ),
                      PopupMenuItem(
                        value: 'sil',
                        child: Text('Sil'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _rutinFormAc(context),
        icon: const Icon(Icons.add),
        label: const Text('Yeni Rutin'),
      ),
    );
  }
}
