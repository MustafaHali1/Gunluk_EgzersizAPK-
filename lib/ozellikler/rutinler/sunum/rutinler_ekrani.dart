// lib/ozellikler/rutinler/sunum/rutinler_ekrani.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cekirdek/veritabani/uygulama_veritabani.dart';
import '../../../cekirdek/yardimcilar/tarih_yardimcisi.dart';
import 'rutin_form_ekrani.dart';
import 'rutin_kontrolcusu.dart';

// Kullanıcının rutinlerini listelediği, aktif rutini seçtiği ve düzenlediği ekran.
class RutinlerEkrani extends ConsumerWidget {
  const RutinlerEkrani({super.key});

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
      appBar: AppBar(title: const Text('Rutinler')),
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
                      Icons.repeat_outlined,
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
                      'Egzersizlerinizi seçip haftanın hangi günleri yapacağınızı belirlemek için yeni bir rutin oluşturun.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    FilledButton.icon(
                      onPressed: () => _rutinFormAc(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Rutin Oluştur'),
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
                  leading: Icon(
                    r.aktifMi
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: r.aktifMi
                        ? Theme.of(context).colorScheme.primary
                        : null,
                  ),
                  title: Row(
                    children: [
                      Expanded(child: Text(r.ad)),
                      if (r.aktifMi)
                        Chip(
                          label: const Text('Aktif'),
                          visualDensity: VisualDensity.compact,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primaryContainer,
                        ),
                    ],
                  ),
                  subtitle: Text('Günler: ${_gunleriFormatla(r.haftaninGunleri)}'),
                  onTap: () => _rutinFormAc(context, rutin: r),
                  trailing: PopupMenuButton<String>(
                    onSelected: (secim) async {
                      if (secim == 'aktif_yap') {
                        await ref
                            .read(rutinKontrolcusuSaglayici.notifier)
                            .aktifRutiniBelirle(r.id);
                      } else if (secim == 'duzenle') {
                        await _rutinFormAc(context, rutin: r);
                      } else if (secim == 'sil') {
                        await ref
                            .read(rutinKontrolcusuSaglayici.notifier)
                            .rutinSil(r.id);
                      }
                    },
                    itemBuilder: (_) => [
                      if (!r.aktifMi)
                        const PopupMenuItem(
                          value: 'aktif_yap',
                          child: Text('Aktif Rutin Yap'),
                        ),
                      const PopupMenuItem(
                        value: 'duzenle',
                        child: Text('Düzenle ve Sırala'),
                      ),
                      const PopupMenuItem(
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
