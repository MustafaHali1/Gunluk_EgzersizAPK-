// lib/ozellikler/rutinler/sunum/rutin_form_ekrani.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cekirdek/veritabani/uygulama_veritabani.dart';
import '../../../cekirdek/yardimcilar/tarih_yardimcisi.dart';
import '../../egzersizler/sunum/egzersiz_kontrolcusu.dart';
import '../veri/rutin_deposu_uygulamasi.dart';
import 'rutin_kontrolcusu.dart';

// Rutin oluşturma, gün seçme, hareket ekleme ve sürükleyerek sıralama ekranı.
class RutinFormEkrani extends ConsumerStatefulWidget {
  final RutinlerData? duzenlenecekRutin;

  const RutinFormEkrani({
    super.key,
    this.duzenlenecekRutin,
  });

  @override
  ConsumerState<RutinFormEkrani> createState() => _RutinFormEkraniState();
}

class _RutinFormEkraniState extends ConsumerState<RutinFormEkrani> {
  final _formAnahtari = GlobalKey<FormState>();
  late final TextEditingController _adDenetleyici;
  final Set<int> _seciliGunler = {1, 2, 3, 4, 5, 6, 7};
  final List<EgzersizlerData> _seciliEgzersizler = [];
  bool _aktifMi = true;
  bool _yukleniyor = false;

  @override
  void initState() {
    super.initState();
    final r = widget.duzenlenecekRutin;
    _adDenetleyici = TextEditingController(text: r?.ad ?? '');
    if (r != null) {
      _aktifMi = r.aktifMi;
      _seciliGunler
        ..clear()
        ..addAll(
          r.haftaninGunleri
              .split(',')
              .map((e) => int.tryParse(e.trim()))
              .whereType<int>(),
        );
      _mevcutRutinEgzersizleriniYukle(r.id);
    }
  }

  Future<void> _mevcutRutinEgzersizleriniYukle(int rutinId) async {
    setState(() => _yukleniyor = true);
    try {
      final detaylar = await ref
          .read(rutinDeposuSaglayici)
          .rutinEgzersizleriniGetir(rutinId);
      if (mounted) {
        setState(() {
          _seciliEgzersizler
            ..clear()
            ..addAll(detaylar.map((d) => d.egzersiz));
        });
      }
    } finally {
      if (mounted) {
        setState(() => _yukleniyor = false);
      }
    }
  }

  @override
  void dispose() {
    _adDenetleyici.dispose();
    super.dispose();
  }

  void _hareketSeciciAc(List<EgzersizlerData> tumAktifEgzersizler) {
    showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      builder: (altContext) {
        return StatefulBuilder(
          builder: (context, altSetState) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tumAktifEgzersizler.length,
              itemBuilder: (context, indeks) {
                final egz = tumAktifEgzersizler[indeks];
                final seciliMi = _seciliEgzersizler.any((e) => e.id == egz.id);
                return CheckboxListTile(
                  value: seciliMi,
                  title: Text(egz.ad),
                  subtitle: Text(egz.kategori),
                  onChanged: (deger) {
                    setState(() {
                      if (deger == true) {
                        _seciliEgzersizler.add(egz);
                      } else {
                        _seciliEgzersizler.removeWhere((e) => e.id == egz.id);
                      }
                    });
                    altSetState(() {});
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Future<void> _kaydet() async {
    if (!_formAnahtari.currentState!.validate()) return;
    if (_seciliGunler.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen en az bir gün seçin.')),
      );
      return;
    }
    if (_seciliEgzersizler.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen rutine en az bir egzersiz ekleyin.')),
      );
      return;
    }

    final basarili = await ref
        .read(rutinKontrolcusuSaglayici.notifier)
        .rutinKaydet(
          rutinId: widget.duzenlenecekRutin?.id,
          ad: _adDenetleyici.text,
          seciliGunler: _seciliGunler.toList(),
          aktifMi: _aktifMi,
          egzersizIdListesi: _seciliEgzersizler.map((e) => e.id).toList(),
        );

    if (!mounted) return;
    if (basarili) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Rutin kaydedilirken bir hata oluştu.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final aktifEgzersizlerDurumu = ref.watch(aktifEgzersizlerAkisSaglayici);
    final duzenlemeMi = widget.duzenlenecekRutin != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(duzenlemeMi ? 'Rutini Düzenle' : 'Yeni Rutin Oluştur'),
        actions: [
          TextButton.icon(
            onPressed: _kaydet,
            icon: const Icon(Icons.check),
            label: const Text('Kaydet'),
          ),
        ],
      ),
      body: _yukleniyor
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formAnahtari,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormField(
                          controller: _adDenetleyici,
                          decoration: const InputDecoration(
                            labelText: 'Rutin Adı (örn. Sabah Esneme Rutini) *',
                            border: OutlineInputBorder(),
                          ),
                          validator: (deger) =>
                              (deger == null || deger.trim().isEmpty)
                                  ? 'Lütfen rutin adını girin'
                                  : null,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Yapılacak Günler',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          children: List.generate(7, (indeks) {
                            final gunNo = indeks + 1;
                            final secili = _seciliGunler.contains(gunNo);
                            return FilterChip(
                              label: Text(TarihYardimcisi.gunKisaAdi(gunNo)),
                              selected: secili,
                              onSelected: (deger) {
                                setState(() {
                                  if (deger) {
                                    _seciliGunler.add(gunNo);
                                  } else {
                                    _seciliGunler.remove(gunNo);
                                  }
                                });
                              },
                            );
                          }),
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Aktif Rutin Olarak Belirle'),
                          subtitle: const Text(
                            'Bugün ekranında bu rutinin hareketleri gösterilir',
                          ),
                          value: _aktifMi,
                          onChanged: (deger) =>
                              setState(() => _aktifMi = deger),
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Hareketler (${_seciliEgzersizler.length}) — Sürükleyerek Sırala',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            aktifEgzersizlerDurumu.maybeWhen(
                              data: (liste) => TextButton.icon(
                                onPressed: liste.isEmpty
                                    ? null
                                    : () => _hareketSeciciAc(liste),
                                icon: const Icon(Icons.add),
                                label: const Text('Hareket Seç'),
                              ),
                              orElse: () => const SizedBox.shrink(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _seciliEgzersizler.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'Henüz hareket seçilmedi. "Hareket Seç" butonuna dokunarak rutine egzersiz ekleyin.',
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : ReorderableListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _seciliEgzersizler.length,
                            onReorderItem: (eskiIndeks, yeniIndeks) {
                              setState(() {
                                final oge = _seciliEgzersizler.removeAt(
                                  eskiIndeks,
                                );
                                _seciliEgzersizler.insert(yeniIndeks, oge);
                              });
                            },
                            itemBuilder: (context, indeks) {
                              final egz = _seciliEgzersizler[indeks];
                              return Card(
                                key: ValueKey(egz.id),
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Text('${indeks + 1}'),
                                  ),
                                  title: Text(egz.ad),
                                  subtitle: Text(egz.kategori),
                                  trailing: const Icon(Icons.drag_handle),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
