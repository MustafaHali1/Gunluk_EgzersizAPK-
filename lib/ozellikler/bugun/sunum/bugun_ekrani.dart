// lib/ozellikler/bugun/sunum/bugun_ekrani.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../cekirdek/sabitler/uygulama_sabitleri.dart';
import '../../../cekirdek/yardimcilar/tarih_yardimcisi.dart';
import '../../rutinler/sunum/rutin_detay_ekrani.dart';
import '../../rutinler/sunum/rutin_form_ekrani.dart';
import '../alan/bugun_durumu.dart';
import 'bugun_kontrolcusu.dart';

// Bugün yapılması gereken rutinleri ve yaklaşan rutin saatini gösteren ana özet ekranı.
class BugunEkrani extends ConsumerStatefulWidget {
  const BugunEkrani({super.key});

  @override
  ConsumerState<BugunEkrani> createState() => _BugunEkraniDurumu();
}

class _BugunEkraniDurumu extends ConsumerState<BugunEkrani> {
  late final AppLifecycleListener _yasamDongusuDinleyicisi;

  @override
  void initState() {
    super.initState();
    _yasamDongusuDinleyicisi = AppLifecycleListener(
      onResume: () {
        ref.read(bugunKontrolcusuSaglayici.notifier).bugunuYenile();
      },
    );
  }

  @override
  void dispose() {
    _yasamDongusuDinleyicisi.dispose();
    super.dispose();
  }

  void _rutinDetayAc(int rutinId, {String? seansSaati}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RutinDetayEkrani(
          rutinId: rutinId,
          seansSaati: seansSaati,
        ),
      ),
    );
  }

  void _yeniRutinOlusturAc() {
    Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (_) => const RutinFormEkrani(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bugunDurumu = ref.watch(bugunKontrolcusuSaglayici);

    return Scaffold(
      appBar: AppBar(
        title: const Text(UygulamaSabitleri.sekmeBugun),
        actions: [
          TextButton.icon(
            onPressed: () => context.go(UygulamaSabitleri.rotaRutinler),
            icon: const Icon(Icons.playlist_add_check),
            label: const Text(UygulamaSabitleri.sekmeRutinler),
          ),
        ],
      ),
      body: bugunDurumu.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (hata, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text('Bugünün verileri yüklenemedi: $hata'),
          ),
        ),
        data: (durum) => RefreshIndicator(
          onRefresh: () =>
              ref.read(bugunKontrolcusuSaglayici.notifier).bugunuYenile(),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 88),
            children: [
              _BugunUstOzetKarti(
                durum: durum,
                siradakiTiklandiginda: durum.siradakiRutin == null
                    ? null
                    : () => _rutinDetayAc(
                          durum.siradakiRutin!.rutin.id,
                          seansSaati: durum.siradakiRutin!.seansSaati,
                        ),
              ),
              const SizedBox(height: 16),
              if (durum.bugunRutinleri.isEmpty)
                _BugunBosDurum(
                  yeniRutinTiklandiginda: _yeniRutinOlusturAc,
                )
              else ...[
                Text(
                  'Bugünkü Rutinler',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                ...durum.bugunRutinleri.map(
                  (ozet) => _BugunRutinKarti(
                    ozet: ozet,
                    tiklandiginda: () => _rutinDetayAc(
                      ozet.rutin.id,
                      seansSaati: ozet.seansSaati,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Tarih, genel ilerleme ve yaklaşan / sıradaki rutini gösteren üst kart.
class _BugunUstOzetKarti extends StatelessWidget {
  final BugunDurumu durum;
  final VoidCallback? siradakiTiklandiginda;

  const _BugunUstOzetKarti({
    required this.durum,
    required this.siradakiTiklandiginda,
  });

  @override
  Widget build(BuildContext context) {
    final tarihMetni = TarihYardimcisi.okunabilirTarih(
      TarihYardimcisi.metindenTarihe(durum.tarih),
    );
    final gunAdi = TarihYardimcisi.gunAdi(durum.haftaninGunu);
    final siradaki = durum.siradakiRutin;

    String siradakiMetni;
    if (siradaki == null) {
      siradakiMetni = durum.bugunRutinleri.isEmpty
          ? 'Bugün için planlı rutin yok'
          : 'Bugünkü tüm rutinler tamamlandı!';
    } else {
      final saatEtiketi = siradaki.seansSaati.isNotEmpty
          ? siradaki.seansSaati
          : '${siradaki.rutin.alarmSaati.toString().padLeft(2, '0')}:${siradaki.rutin.alarmDakikasi.toString().padLeft(2, '0')}';
      siradakiMetni = siradaki.suresiGectiMi
          ? 'Süresi Geçti: ${siradaki.rutin.ad} ($saatEtiketi)'
          : 'Sıradaki: ${siradaki.rutin.ad} • Saat $saatEtiketi';
    }

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: InkWell(
        onTap: siradakiTiklandiginda,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$tarihMetni • $gunAdi',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    '%${durum.tamamlanmaYuzdesi}',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.schedule, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      siradakiMetni,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ),
                  if (siradakiTiklandiginda != null)
                    const Icon(Icons.chevron_right),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: durum.tamamlanmaOrani,
                  minHeight: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Bugün ekranındaki her bir rutinin açılır-kapanır tırnaklı kartı.
class _BugunRutinKarti extends StatelessWidget {
  final BugunRutinOzeti ozet;
  final VoidCallback tiklandiginda;

  const _BugunRutinKarti({
    required this.ozet,
    required this.tiklandiginda,
  });

  @override
  Widget build(BuildContext context) {
    final r = ozet.rutin;
    final saatBilgisi = ozet.seansSaati.isNotEmpty
        ? '⏰ ${ozet.seansSaati}'
        : '⏰ ${r.alarmSaati.toString().padLeft(2, '0')}:${r.alarmDakikasi.toString().padLeft(2, '0')}';

    if (ozet.gorevKayitlari.isEmpty) {
      return Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          onTap: tiklandiginda,
          leading: CircleAvatar(
            child: Icon(Icons.playlist_play, color: Theme.of(context).colorScheme.primary),
          ),
          title: Text(r.ad, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text('$saatBilgisi • 0 görev'),
          trailing: const Icon(Icons.chevron_right),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: ozet.tamamlandiMi
              ? UygulamaRenkleri.basariYesili.withValues(alpha: 0.15)
              : ozet.suresiGectiMi
                  ? UygulamaRenkleri.hataKirmizisi.withValues(alpha: 0.15)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Icon(
            ozet.tamamlandiMi
                ? Icons.check_circle
                : ozet.suresiGectiMi
                    ? Icons.warning_amber_rounded
                    : Icons.playlist_play,
            color: ozet.tamamlandiMi
                ? UygulamaRenkleri.basariYesili
                : ozet.suresiGectiMi
                    ? UygulamaRenkleri.hataKirmizisi
                    : Theme.of(context).colorScheme.primary,
          ),
        ),
        title: GestureDetector(
          onTap: tiklandiginda,
          child: Text(
            r.ad,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        subtitle: GestureDetector(
          onTap: tiklandiginda,
          child: Text(
            '$saatBilgisi • ${ozet.yapilanSayisi}/${ozet.toplamSayisi} yapıldı'
            '${ozet.suresiGectiMi ? ' • Süresi geçti' : ''}',
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        children: [
          ...ozet.gorevKayitlari.map((k) {
            final ikon = k.durum == 'yapildi'
                ? '✅'
                : k.durum == 'atlandi'
                    ? '❌'
                    : '⏳';
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                children: [
                  Text(ikon),
                  const SizedBox(width: 8),
                  Expanded(child: Text(k.egzersizAdiKopyasi)),
                ],
              ),
            );
          }),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonalIcon(
              onPressed: tiklandiginda,
              icon: const Icon(Icons.visibility_outlined, size: 18),
              label: const Text('Rutini Görüntüle'),
            ),
          ),
        ],
      ),
    );
  }
}

// Bugün için planlı rutin olmadığında kullanıcıyı yönlendiren boş durum bileşeni.
class _BugunBosDurum extends StatelessWidget {
  final VoidCallback yeniRutinTiklandiginda;

  const _BugunBosDurum({required this.yeniRutinTiklandiginda});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.event_available,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Bugün için planlı rutin yok',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Rutinlerim sekmesinden yeni bir rutin oluşturup görevlerinizi ekleyebilirsiniz.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: yeniRutinTiklandiginda,
              icon: const Icon(Icons.add),
              label: const Text('Yeni Rutin Oluştur'),
            ),
          ],
        ),
      ),
    );
  }
}
