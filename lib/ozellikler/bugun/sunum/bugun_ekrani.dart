// lib/ozellikler/bugun/sunum/bugun_ekrani.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../cekirdek/sabitler/uygulama_sabitleri.dart';
import '../../../cekirdek/yardimcilar/tarih_yardimcisi.dart';
import '../alan/bugun_durumu.dart';
import 'bugun_hareket_karti.dart';
import 'bugun_kontrolcusu.dart';
import 'hizli_ekle_alt_sayfasi.dart';

// Kullanıcının günlük egzersizlerini işaretlediği, ilerlemesini gördüğü ana ekran.
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

  void _hizliEkleAc() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => const HizliEkleAltSayfasi(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bugunDurumu = ref.watch(bugunKontrolcusuSaglayici);

    return Scaffold(
      appBar: AppBar(
        title: const Text(UygulamaMetinleri.sekmeBugun),
        actions: [
          TextButton.icon(
            onPressed: () => context.go(RotaAdlari.rutinler),
            icon: const Icon(Icons.playlist_add_check),
            label: const Text('Rutinim'),
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
        data: (durum) => _BugunIcerigi(
          durum: durum,
          hizliEkleTiklandiginda: _hizliEkleAc,
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _hizliEkleAc,
        icon: const Icon(Icons.add),
        label: const Text(UygulamaMetinleri.hizliEkle),
      ),
    );
  }
}

// Bugün ekranının ilerleme özeti ve hareket listesini barındıran gövde bileşeni.
class _BugunIcerigi extends ConsumerWidget {
  final BugunDurumu durum;
  final VoidCallback hizliEkleTiklandiginda;

  const _BugunIcerigi({
    required this.durum,
    required this.hizliEkleTiklandiginda,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kontrolcu = ref.read(bugunKontrolcusuSaglayici.notifier);

    return RefreshIndicator(
      onRefresh: () => kontrolcu.bugunuYenile(),
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          _GunlukIlerlemeKarti(
            durum: durum,
            tumunuYapildiTiklandiginda: () => kontrolcu.tumunuYapildiIsaretle(),
          ),
          const SizedBox(height: 16),
          if (durum.hareketler.isEmpty)
            _BugunBosDurum(hizliEkleTiklandiginda: hizliEkleTiklandiginda)
          else
            ...durum.hareketler.map(
              (kayit) => BugunHareketKarti(
                kayit: kayit,
                egzersizDetayi: durum.egzersizDetayHaritasi[kayit.egzersizId],
                durumDegistirildiginde: (hedefDurum) =>
                    kontrolcu.hareketDurumunuDegistir(
                      kayit: kayit,
                      hedefDurum: hedefDurum,
                    ),
                notKaydedildiginde: (notMetni) => kontrolcu.hareketNotunuKaydet(
                  kayit: kayit,
                  notMetni: notMetni,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Tarih, aktif rutin adı ve günlük tamamlanma yüzdesini gösteren üst özet kartı.
class _GunlukIlerlemeKarti extends StatelessWidget {
  final BugunDurumu durum;
  final VoidCallback tumunuYapildiTiklandiginda;

  const _GunlukIlerlemeKarti({
    required this.durum,
    required this.tumunuYapildiTiklandiginda,
  });

  @override
  Widget build(BuildContext context) {
    final tarihMetni = TarihYardimcisi.okunabilirTarih(
      TarihYardimcisi.metindenTarihe(durum.tarih),
    );
    final gunAdi = TarihYardimcisi.gunAdi(durum.haftaninGunu);

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
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
            const SizedBox(height: 4),
            Text(
              durum.aktifRutinAdi != null
                  ? 'Aktif Rutin: ${durum.aktifRutinAdi}'
                  : 'Aktif rutin seçilmedi',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: durum.tamamlanmaOrani,
                minHeight: 10,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${durum.yapilanHareketSayisi}/${durum.toplamHareketSayisi} yapıldı • ${durum.atlananHareketSayisi} yapılmadı',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                if (durum.bekleyenHareketSayisi > 0)
                  TextButton.icon(
                    onPressed: tumunuYapildiTiklandiginda,
                    icon: const Icon(Icons.done_all, size: 18),
                    label: const Text('Tümünü Yaptım'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Bugün için planlı hareket olmadığında kullanıcıyı yönlendiren boş durum bileşeni.
class _BugunBosDurum extends StatelessWidget {
  final VoidCallback hizliEkleTiklandiginda;

  const _BugunBosDurum({required this.hizliEkleTiklandiginda});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.self_improvement,
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              UygulamaMetinleri.bosBugunBaslik,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              UygulamaMetinleri.bosBugunAciklama,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 12,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: () => context.go(RotaAdlari.rutinler),
                  icon: const Icon(Icons.calendar_today),
                  label: const Text('Rutin Oluştur / Seç'),
                ),
                OutlinedButton.icon(
                  onPressed: hizliEkleTiklandiginda,
                  icon: const Icon(Icons.add),
                  label: const Text('Bugüne Hızlı Ekle'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
