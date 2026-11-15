// lib/ozellikler/egzersizler/sunum/egzersizler_ekrani.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cekirdek/veritabani/uygulama_veritabani.dart';
import '../alan/hazir_egzersiz_sablonu.dart';
import 'egzersiz_form_alt_sayfasi.dart';
import 'egzersiz_kontrolcusu.dart';

// Kullanıcının egzersizlerini listelediği, eklediği, düzenlediği ve arşivlediği ekran.
class EgzersizlerEkrani extends ConsumerWidget {
  const EgzersizlerEkrani({super.key});

  Future<void> _formAc(
    BuildContext context, {
    EgzersizlerData? egzersiz,
  }) async {
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => EgzersizFormAltSayfasi(duzenlenecekEgzersiz: egzersiz),
    );
  }

  Future<void> _hazirSablonSeciciAc(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (altContext) {
        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: hazirEgzersizSablonlari.length + 1,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, indeks) {
            if (indeks == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Hazır Örnek Hareketlerden Ekle',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              );
            }
            final sablon = hazirEgzersizSablonlari[indeks - 1];
            final hedefBilgisi = sablon.tur == 'sureli'
                ? '${sablon.sureSaniye} sn'
                : '${sablon.setSayisi} set × ${sablon.tekrarSayisi} tekrar';
            return ListTile(
              title: Text(sablon.ad),
              subtitle: Text('${sablon.kategori} • $hedefBilgisi'),
              trailing: const Icon(Icons.add_circle_outline),
              onTap: () async {
                Navigator.of(altContext).pop();
                final eklendi = await ref
                    .read(egzersizKontrolcusuSaglayici.notifier)
                    .sablondanEgzersizEkle(sablon);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        eklendi
                            ? '${sablon.ad} eklendi.'
                            : 'Egzersiz eklenemedi.',
                      ),
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final egzersizlerDurumu = ref.watch(aktifEgzersizlerAkisSaglayici);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Egzersizler'),
        actions: [
          TextButton.icon(
            onPressed: () => _hazirSablonSeciciAc(context, ref),
            icon: const Icon(Icons.playlist_add),
            label: const Text('Hazır Liste'),
          ),
        ],
      ),
      body: egzersizlerDurumu.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (hata, _) => Center(child: Text(hata.toString())),
        data: (liste) {
          if (liste.isEmpty) {
            return _BosEgzersizDurumu(
              yeniEkleTiklandi: () => _formAc(context),
              hazirListeTiklandi: () => _hazirSablonSeciciAc(context, ref),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 88),
            itemCount: liste.length,
            itemBuilder: (context, indeks) {
              final e = liste[indeks];
              final olcuMetni = e.tur == 'sureli'
                  ? '${e.sureSaniye ?? 0} saniye'
                  : '${e.setSayisi ?? 1} set × ${e.tekrarSayisi ?? 1} tekrar';
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Icon(
                      e.tur == 'sureli' ? Icons.timer_outlined : Icons.repeat,
                    ),
                  ),
                  title: Text(e.ad),
                  subtitle: Text(
                    '${e.kategori} • $olcuMetni'
                    '${e.aciklama.isNotEmpty ? '\n${e.aciklama}' : ''}',
                  ),
                  isThreeLine: e.aciklama.isNotEmpty,
                  trailing: PopupMenuButton<String>(
                    onSelected: (secim) async {
                      if (secim == 'duzenle') {
                        await _formAc(context, egzersiz: e);
                      } else if (secim == 'arsivle') {
                        await ref
                            .read(egzersizKontrolcusuSaglayici.notifier)
                            .egzersizArsivle(e.id);
                      }
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                        value: 'duzenle',
                        child: Text('Düzenle'),
                      ),
                      PopupMenuItem(
                        value: 'arsivle',
                        child: Text('Arşivle (Gizle)'),
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
        onPressed: () => _formAc(context),
        icon: const Icon(Icons.add),
        label: const Text('Egzersiz Ekle'),
      ),
    );
  }
}

// Henüz egzersiz eklenmediğinde kullanıcıyı yönlendiren boş durum bileşeni.
class _BosEgzersizDurumu extends StatelessWidget {
  final VoidCallback yeniEkleTiklandi;
  final VoidCallback hazirListeTiklandi;

  const _BosEgzersizDurumu({
    required this.yeniEkleTiklandi,
    required this.hazirListeTiklandi,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.fitness_center_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Henüz egzersiz eklenmedi',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Kendi egzersizinizi oluşturabilir veya hazır örnek listeden hızlıca seçebilirsiniz.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: yeniEkleTiklandi,
                  icon: const Icon(Icons.add),
                  label: const Text('Yeni Egzersiz'),
                ),
                OutlinedButton.icon(
                  onPressed: hazirListeTiklandi,
                  icon: const Icon(Icons.playlist_add),
                  label: const Text('Örnek Listeden Seç'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
