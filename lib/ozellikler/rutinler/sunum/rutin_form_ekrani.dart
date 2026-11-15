// lib/ozellikler/rutinler/sunum/rutin_form_ekrani.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cekirdek/veritabani/uygulama_veritabani.dart';
import '../../../cekirdek/yardimcilar/tarih_yardimcisi.dart';
import '../../egzersizler/alan/hazir_egzersiz_sablonu.dart';
import '../../egzersizler/sunum/egzersiz_kontrolcusu.dart';
import '../../egzersizler/veri/egzersiz_deposu_uygulamasi.dart';
import '../veri/rutin_deposu_uygulamasi.dart';
import 'rutin_kontrolcusu.dart';

// Rutin oluşturma, gün seçme, doğrudan hareket yazma/seçme ve sıralama ekranı.
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
    _adDenetleyici = TextEditingController(
      text: r?.ad ?? 'Günlük Fizyoterapi / Sağlık Rutinim',
    );
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

  Future<void> _yeniHareketYazPenceresiAc() async {
    final adYazici = TextEditingController();
    final tarifYazici = TextEditingController(text: '3 set × 10 tekrar');

    final eklensinMi = await showDialog<bool>(
      context: context,
      builder: (baglam) => AlertDialog(
        title: const Text('Rutine Yeni Hareket Yaz'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: adYazici,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Hareket Adı *',
                hintText: 'Örn: Havlu ile Diz Bastırma',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: tarifYazici,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Tarif / Tekrar Bilgisi (Opsiyonel)',
                hintText: 'Örn: 10 tekrar, her seferinde 5 sn basılı tut',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(baglam).pop(false),
            child: const Text('İptal'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(baglam).pop(true),
            icon: const Icon(Icons.add),
            label: const Text('Rutine Ekle'),
          ),
        ],
      ),
    );

    final ad = adYazici.text.trim();
    final tarif = tarifYazici.text.trim();
    adYazici.dispose();
    tarifYazici.dispose();

    if (eklensinMi != true || ad.isEmpty) return;

    final egzDepo = ref.read(egzersizDeposuSaglayici);
    final yeniId = await egzDepo.egzersizEkle(
      ad: ad,
      aciklama: tarif,
      tur: 'tekrarli',
      setSayisi: 3,
      tekrarSayisi: 10,
      kategori: 'Fizyoterapi / Günlük',
    );
    final yeniKayit = await egzDepo.idIleEgzersizGetir(yeniId);
    ref.invalidate(aktifEgzersizlerAkisSaglayici);
    if (yeniKayit != null && mounted) {
      setState(() {
        _seciliEgzersizler.add(yeniKayit);
      });
    }
  }

  Future<void> _hazirListedenSecAc() async {
    final egzDepo = ref.read(egzersizDeposuSaglayici);
    final kayitliListe = await egzDepo.aktifEgzersizleriGetir();
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      builder: (altContext) {
        return StatefulBuilder(
          builder: (context, altSetState) {
            return DraggableScrollableSheet(
              expand: false,
              initialChildSize: 0.75,
              maxChildSize: 0.92,
              builder: (context, kaydirmaDenetleyicisi) {
                return ListView(
                  controller: kaydirmaDenetleyicisi,
                  padding: const EdgeInsets.all(16),
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Hazır Fizyoterapi & Sağlık Hareketleri',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        TextButton(
                          onPressed: () => Navigator.of(altContext).pop(),
                          child: const Text('Tamam'),
                        ),
                      ],
                    ),
                    const Text(
                      'İstediğiniz hareketlere dokunarak rutininize ekleyin:',
                    ),
                    const SizedBox(height: 8),
                    ...hazirEgzersizSablonlari.map((sablon) {
                      final zatenSecili = _seciliEgzersizler.any(
                        (e) => e.ad.toLowerCase() == sablon.ad.toLowerCase(),
                      );
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(sablon.ad),
                          subtitle: Text('${sablon.kategori} • ${sablon.aciklama}'),
                          trailing: zatenSecili
                              ? const Chip(label: Text('Eklendi'))
                              : FilledButton.tonalIcon(
                                  onPressed: () async {
                                    var mevcut = kayitliListe
                                        .where(
                                          (k) =>
                                              k.ad.toLowerCase() ==
                                              sablon.ad.toLowerCase(),
                                        )
                                        .firstOrNull;
                                    if (mevcut == null) {
                                      final id = await egzDepo.egzersizEkle(
                                        ad: sablon.ad,
                                        aciklama: sablon.aciklama,
                                        tur: sablon.tur,
                                        sureSaniye: sablon.sureSaniye,
                                        setSayisi: sablon.setSayisi,
                                        tekrarSayisi: sablon.tekrarSayisi,
                                        kategori: sablon.kategori,
                                      );
                                      mevcut = await egzDepo.idIleEgzersizGetir(id);
                                      if (mevcut != null) {
                                        kayitliListe.add(mevcut);
                                      }
                                      ref.invalidate(aktifEgzersizlerAkisSaglayici);
                                    }
                                    if (mevcut != null && mounted) {
                                      final eklenecek = mevcut;
                                      setState(() {
                                        _seciliEgzersizler.add(eklenecek);
                                      });
                                      altSetState(() {});
                                    }
                                  },
                                  icon: const Icon(Icons.add),
                                  label: const Text('Ekle'),
                                ),
                        ),
                      );
                    }),
                  ],
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
        const SnackBar(content: Text('Lütfen rutine en az bir hareket ekleyin.')),
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
    final duzenlemeMi = widget.duzenlenecekRutin != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(duzenlemeMi ? 'Rutini Düzenle' : 'Yeni Rutin Oluştur'),
        actions: [
          FilledButton.icon(
            onPressed: _kaydet,
            icon: const Icon(Icons.check),
            label: const Text('Kaydet'),
          ),
          const SizedBox(width: 12),
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
                            labelText: 'Rutin Adı *',
                            hintText: 'Örn: Fizyoterapi Egzersizlerim',
                            border: OutlineInputBorder(),
                          ),
                          validator: (deger) =>
                              (deger == null || deger.trim().isEmpty)
                                  ? 'Lütfen rutin adını girin'
                                  : null,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Hangi Günler Yapılacak?',
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
                        const Divider(height: 20),
                        Text(
                          'Rutindeki Hareketler (${_seciliEgzersizler.length})',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _yeniHareketYazPenceresiAc,
                                icon: const Icon(Icons.edit),
                                label: const Text('Yeni Hareket Yaz'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _hazirListedenSecAc,
                                icon: const Icon(Icons.medical_services_outlined),
                                label: const Text('Hazır Listeden Seç'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _seciliEgzersizler.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(24),
                              child: Text(
                                'Henüz hareket eklenmedi.\nYukarıdaki "Yeni Hareket Yaz" veya "Hazır Listeden Seç" butonuna dokunarak egzersizlerinizi ekleyin.',
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
                                key: ValueKey('${egz.id}_$indeks'),
                                margin: const EdgeInsets.only(bottom: 8),
                                child: ListTile(
                                  leading: CircleAvatar(
                                    child: Text('${indeks + 1}'),
                                  ),
                                  title: Text(egz.ad),
                                  subtitle: Text(
                                    egz.aciklama.isNotEmpty
                                        ? egz.aciklama
                                        : egz.kategori,
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        tooltip: 'Rutinden Çıkar',
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _seciliEgzersizler.removeAt(indeks);
                                          });
                                        },
                                      ),
                                      const Icon(Icons.drag_handle),
                                    ],
                                  ),
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
