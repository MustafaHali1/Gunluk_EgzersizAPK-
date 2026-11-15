// lib/ozellikler/yedekleme/sunum/yedekleme_ayar_karti.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cekirdek/sabitler/uygulama_sabitleri.dart';
import 'yedekleme_kontrolcusu.dart';

// Ayarlar ekranında yedekleme, geri yükleme ve çift onaylı veri silme işlemlerini sunan kart.
class YedeklemeAyarKarti extends ConsumerWidget {
  const YedeklemeAyarKarti({super.key});

  Future<void> _disaAktar(BuildContext context, WidgetRef ref) async {
    final kontrolcu = ref.read(yedeklemeKontrolcusuSaglayici.notifier);
    final hata = await kontrolcu.verileriDisaAktar();
    if (hata != null && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(hata)),
      );
    }
  }

  Future<void> _iceAktar(BuildContext context, WidgetRef ref) async {
    final kontrolcu = ref.read(yedeklemeKontrolcusuSaglayici.notifier);
    String? jsonMetni;
    try {
      jsonMetni = await kontrolcu.yedekDosyasiSec();
    } catch (hata) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(hata.toString())),
        );
      }
      return;
    }

    if (jsonMetni == null || !context.mounted) return;

    final onaylandi = await showDialog<bool>(
      context: context,
      builder: (baglam) => AlertDialog(
        title: const Text('Yedeği Geri Yükle'),
        content: const Text(
          'Seçtiğiniz yedek dosyası yüklendiğinde mevcut tüm egzersiz, rutin ve antrenman kayıtlarınız yedekteki verilerle değiştirilecektir. Onaylıyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(baglam).pop(false),
            child: const Text(UygulamaMetinleri.iptal),
          ),
          FilledButton(
            onPressed: () => Navigator.of(baglam).pop(true),
            child: const Text('Geri Yükle'),
          ),
        ],
      ),
    );

    if (onaylandi != true || !context.mounted) return;

    final hata = await kontrolcu.yedektenGeriYukle(jsonMetni);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            hata ?? 'Verileriniz başarıyla yedekten geri yüklendi!',
          ),
        ),
      );
    }
  }

  Future<void> _ciftOnaylaTumVerileriSil(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final ilkOnay = await showDialog<bool>(
      context: context,
      builder: (baglam) => AlertDialog(
        title: const Text('Tüm Verileri Sil (1/2)'),
        content: const Text(
          'Cihazınızdaki tüm egzersizler, rutinler ve geçmiş antrenman kayıtlarınız silinecektir. Devam etmek istiyor musunuz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(baglam).pop(false),
            child: const Text(UygulamaMetinleri.iptal),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: UygulamaRenkleri.uyariTuruncusu,
            ),
            onPressed: () => Navigator.of(baglam).pop(true),
            child: const Text('Devam Et'),
          ),
        ],
      ),
    );

    if (ilkOnay != true || !context.mounted) return;

    final ikinciOnay = await showDialog<bool>(
      context: context,
      builder: (baglam) => AlertDialog(
        title: const Text('Son Onay: Kalıcı Silme (2/2)'),
        content: const Text(
          'Bu işlem GERİ ALINAMAZ! Yedek almadıysanız tüm verileriniz kalıcı olarak kaybolacaktır. Silmek istediğinize emin misiniz?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(baglam).pop(false),
            child: const Text(UygulamaMetinleri.iptal),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: UygulamaRenkleri.hataKirmizisi,
            ),
            onPressed: () => Navigator.of(baglam).pop(true),
            child: const Text('Kalıcı Olarak Sil'),
          ),
        ],
      ),
    );

    if (ikinciOnay != true || !context.mounted) return;

    final hata = await ref
        .read(yedeklemeKontrolcusuSaglayici.notifier)
        .tumVerileriSil();
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            hata ?? 'Tüm veriler silindi ve uygulama sıfırlandı.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final islemDurumu = ref.watch(yedeklemeKontrolcusuSaglayici);
    final yukleniyor = islemDurumu.isLoading;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Veri Yedekleme ve Sıfırlama',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilledButton.tonalIcon(
                  onPressed: yukleniyor ? null : () => _disaAktar(context, ref),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('JSON Yedekle / Paylaş'),
                ),
                OutlinedButton.icon(
                  onPressed: yukleniyor ? null : () => _iceAktar(context, ref),
                  icon: const Icon(Icons.download),
                  label: const Text('Yedekten Geri Yükle'),
                ),
              ],
            ),
            const Divider(height: 24),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: UygulamaRenkleri.hataKirmizisi,
                  side: const BorderSide(color: UygulamaRenkleri.hataKirmizisi),
                ),
                onPressed: yukleniyor
                    ? null
                    : () => _ciftOnaylaTumVerileriSil(context, ref),
                icon: const Icon(Icons.delete_forever),
                label: const Text('Tüm Verileri Sil (Çift Onaylı)'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
