// lib/ozellikler/tanitim/sunum/tanitim_ekrani.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../cekirdek/sabitler/uygulama_sabitleri.dart';
import 'tanitim_kontrolcusu.dart';

// İlk açılışta gösterilen sade hoş geldiniz ve başlangıç ekranı.
class TanitimEkrani extends ConsumerWidget {
  const TanitimEkrani({super.key});

  Future<void> _basla(BuildContext context, WidgetRef ref) async {
    final basarili = await ref
        .read(tanitimKontrolcusuSaglayici.notifier)
        .tanitimiTamamla();
    if (basarili && context.mounted) {
      context.go(UygulamaSabitleri.rotaRutinler);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final islemDurumu = ref.watch(tanitimKontrolcusuSaglayici);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Icon(
                Icons.checklist_rtl,
                size: 88,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                'Günlük Rutin\'e Hoş Geldiniz',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Fizyoterapi hareketleriniz, ilaçlarınız, günlük alışkanlıklarınız veya çalışmalarınız için kendi rutinlerinizi oluşturun.\n\nHer rutine özel saat ve müzikli alarm kurabilir, yaptıklarınızı "Yaptım" / "Yapmadım" işaretleyip PDF rapor alabilirsiniz.',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
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
              const Spacer(),
              SizedBox(
                height: UygulamaBoyutlari.dokunmaHedefiMin,
                child: FilledButton.icon(
                  onPressed: islemDurumu.isLoading
                      ? null
                      : () => _basla(context, ref),
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Hemen Başla'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
