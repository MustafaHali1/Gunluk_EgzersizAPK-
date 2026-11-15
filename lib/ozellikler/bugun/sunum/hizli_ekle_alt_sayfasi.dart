// lib/ozellikler/bugun/sunum/hizli_ekle_alt_sayfasi.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cekirdek/sabitler/uygulama_sabitleri.dart';
import '../../../cekirdek/veritabani/uygulama_veritabani.dart';
import '../../egzersizler/alan/hazir_egzersiz_sablonu.dart';
import '../../egzersizler/sunum/egzersiz_kontrolcusu.dart';
import 'bugun_kontrolcusu.dart';

// Bugüne tek seferlik hızlı hareket eklemek için kullanılan alt sayfa (BottomSheet).
class HizliEkleAltSayfasi extends ConsumerStatefulWidget {
  const HizliEkleAltSayfasi({super.key});

  @override
  ConsumerState<HizliEkleAltSayfasi> createState() =>
      _HizliEkleAltSayfasiDurumu();
}

class _HizliEkleAltSayfasiDurumu extends ConsumerState<HizliEkleAltSayfasi> {
  bool _yeniEgzersizModu = false;
  final _adYazici = TextEditingController();
  final _notYazici = TextEditingController();
  String _tur = 'tekrarli';
  String _kategori = varsayilanEgzersizKategorileri.first;

  @override
  void dispose() {
    _adYazici.dispose();
    _notYazici.dispose();
    super.dispose();
  }

  Future<void> _mevcutEgzersiziBuguneEkle(EgzersizlerData egzersiz) async {
    await ref
        .read(bugunKontrolcusuSaglayici.notifier)
        .hizliMevcutEgzersizEkle(
          egzersiz: egzersiz,
          notMetni: _notYazici.text,
        );
    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${egzersiz.ad} bugüne eklendi.')),
      );
    }
  }

  Future<void> _yeniOlusturVeBuguneEkle() async {
    final ad = _adYazici.text.trim();
    if (ad.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen hareket adını girin.')),
      );
      return;
    }

    await ref
        .read(bugunKontrolcusuSaglayici.notifier)
        .hizliYeniEgzersizOlusturVeEkle(
          ad: ad,
          tur: _tur,
          sureSaniye: _tur == 'sureli' ? 30 : null,
          setSayisi: _tur == 'tekrarli' ? 3 : null,
          tekrarSayisi: _tur == 'tekrarli' ? 10 : null,
          kategori: _kategori,
          notMetni: _notYazici.text,
        );

    if (mounted) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$ad oluşturuldu ve bugüne eklendi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final aktifEgzersizlerDurumu = ref.watch(aktifEgzersizlerAkisSaglayici);
    final altKlavyeBoslugu = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, altKlavyeBoslugu + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bugüne Hızlı Hareket Ekle',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() => _yeniEgzersizModu = !_yeniEgzersizModu);
                },
                icon: Icon(_yeniEgzersizModu ? Icons.list : Icons.add),
                label: Text(_yeniEgzersizModu ? 'Listeden Seç' : 'Yeni Oluştur'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notYazici,
            decoration: const InputDecoration(
              labelText: 'Opsiyonel Günlük Not',
              hintText: 'Örn: Akşam yürüyüşü sonrası ek set',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          if (_yeniEgzersizModu)
            _YeniHizliEgzersizFormu(
              adYazici: _adYazici,
              tur: _tur,
              kategori: _kategori,
              turDegistiginde: (deger) => setState(() => _tur = deger),
              kategoriDegistiginde: (deger) => setState(() => _kategori = deger),
              kaydetTiklandiginda: _yeniOlusturVeBuguneEkle,
            )
          else
            SizedBox(
              height: 260,
              child: aktifEgzersizlerDurumu.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (h, _) => Center(child: Text('Hata: $h')),
                data: (egzersizler) {
                  if (egzersizler.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('Kayıtlı egzersiz bulunamadı.'),
                          const SizedBox(height: 8),
                          FilledButton(
                            onPressed: () {
                              setState(() => _yeniEgzersizModu = true);
                            },
                            child: const Text('Yeni Hareket Oluştur ve Ekle'),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    itemCount: egzersizler.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, indeks) {
                      final egz = egzersizler[indeks];
                      return ListTile(
                        title: Text(egz.ad),
                        subtitle: Text(egz.kategori),
                        trailing: FilledButton.tonalIcon(
                          onPressed: () => _mevcutEgzersiziBuguneEkle(egz),
                          icon: const Icon(Icons.add),
                          label: const Text('Ekle'),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

// Hızlı ekle penceresinde yeni egzersiz oluşturma alanlarını gösteren alt bileşen.
class _YeniHizliEgzersizFormu extends StatelessWidget {
  final TextEditingController adYazici;
  final String tur;
  final String kategori;
  final ValueChanged<String> turDegistiginde;
  final ValueChanged<String> kategoriDegistiginde;
  final VoidCallback kaydetTiklandiginda;

  const _YeniHizliEgzersizFormu({
    required this.adYazici,
    required this.tur,
    required this.kategori,
    required this.turDegistiginde,
    required this.kategoriDegistiginde,
    required this.kaydetTiklandiginda,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: adYazici,
          decoration: const InputDecoration(
            labelText: 'Yeni Hareket Adı *',
            hintText: 'Örn: Köprü (Glute Bridge)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        SegmentedButton<String>(
          segments: const [
            ButtonSegment(value: 'tekrarli', label: Text('Tekrarlı (3×10)')),
            ButtonSegment(value: 'sureli', label: Text('Süreli (30 sn)')),
          ],
          selected: {tur},
          onSelectionChanged: (secim) => turDegistiginde(secim.first),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: kategori,
          decoration: const InputDecoration(
            labelText: 'Kategori',
            border: OutlineInputBorder(),
          ),
          items: varsayilanEgzersizKategorileri
              .map((k) => DropdownMenuItem(value: k, child: Text(k)))
              .toList(),
          onChanged: (deger) {
            if (deger != null) kategoriDegistiginde(deger);
          },
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: UygulamaBoyutlari.dokunmaHedefiMin,
          child: FilledButton.icon(
            onPressed: kaydetTiklandiginda,
            icon: const Icon(Icons.add_task),
            label: const Text('Oluştur ve Bugüne Ekle'),
          ),
        ),
      ],
    );
  }
}
