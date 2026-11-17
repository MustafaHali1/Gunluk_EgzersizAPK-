// lib/ozellikler/rutinler/sunum/rutin_form_ekrani.dart

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cekirdek/bildirimler/bildirim_servisi.dart';
import '../../../cekirdek/veritabani/uygulama_veritabani.dart';
import '../../../cekirdek/yardimcilar/tarih_yardimcisi.dart';
import '../../egzersizler/sunum/egzersiz_kontrolcusu.dart';
import '../../egzersizler/veri/egzersiz_deposu_uygulamasi.dart';
import '../veri/rutin_deposu_uygulamasi.dart';
import 'rutin_kontrolcusu.dart';

// Rutin oluşturma, gün seçimi, rutine özel müzikli alarm ve "+ Görev Ekle" ekranı.
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
  final List<EgzersizlerData> _seciliGorevler = [];
  bool _sadeceBugunMu = false;
  bool _alarmAcikMi = false;
  final List<TimeOfDay> _alarmSaatleri = [const TimeOfDay(hour: 9, minute: 0)];
  String? _alarmMuzikYolu;
  String? _alarmMuzikAdi;
  bool _yukleniyor = false;

  @override
  void initState() {
    super.initState();
    final r = widget.duzenlenecekRutin;
    _adDenetleyici = TextEditingController(text: r?.ad ?? '');
    if (r != null) {
      _sadeceBugunMu = r.sadeceTarih != null;
      _alarmAcikMi = r.alarmAcikMi;
      final cozulen = TarihYardimcisi.alarmSaatleriniCoz(
        alarmSaatleriMetni: r.alarmSaatleri,
        varsayilanSaat: r.alarmSaati,
        varsayilanDakika: r.alarmDakikasi,
      );
      _alarmSaatleri
        ..clear()
        ..addAll(cozulen.map((e) => TimeOfDay(hour: e.$1, minute: e.$2)));
      _alarmMuzikYolu = r.alarmMuzikYolu;
      _alarmMuzikAdi = r.alarmMuzikAdi;
      _seciliGunler
        ..clear()
        ..addAll(
          r.haftaninGunleri
              .split(',')
              .map((e) => int.tryParse(e.trim()))
              .whereType<int>(),
        );
      _mevcutRutinGorevleriniYukle(r.id);
    }
  }

  Future<void> _mevcutRutinGorevleriniYukle(int rutinId) async {
    setState(() => _yukleniyor = true);
    try {
      final detaylar = await ref
          .read(rutinDeposuSaglayici)
          .rutinEgzersizleriniGetir(rutinId);
      if (mounted) {
        setState(() {
          _seciliGorevler
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

  Future<void> _yeniGorevEklePenceresiAc() async {
    final adYazici = TextEditingController();
    final aciklamaYazici = TextEditingController();

    final eklensinMi = await showDialog<bool>(
      context: context,
      builder: (baglam) => AlertDialog(
        title: const Text('Görev Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: adYazici,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Görev Adı *',
                hintText: 'Örn: Boyun esnetme, Vitamin iç, 20 sayfa kitap',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: aciklamaYazici,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Açıklama / Tekrar (Opsiyonel)',
                hintText: 'Örn: 10 tekrar, yemekten sonra...',
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
            label: const Text('Ekle'),
          ),
        ],
      ),
    );

    final ad = adYazici.text.trim();
    final aciklama = aciklamaYazici.text.trim();
    adYazici.dispose();
    aciklamaYazici.dispose();

    if (eklensinMi != true || ad.isEmpty) return;

    final egzDepo = ref.read(egzersizDeposuSaglayici);
    final yeniId = await egzDepo.egzersizEkle(
      ad: ad,
      aciklama: aciklama,
      tur: 'tekrarli',
      setSayisi: 1,
      tekrarSayisi: 1,
      kategori: 'Genel',
    );
    final yeniKayit = await egzDepo.idIleEgzersizGetir(yeniId);
    ref.invalidate(aktifEgzersizlerAkisSaglayici);
    if (yeniKayit != null && mounted) {
      setState(() {
        _seciliGorevler.add(yeniKayit);
      });
    }
  }

  void _saatleriSiralaVeTekillestir() {
    final harita = <int, TimeOfDay>{
      for (final s in _alarmSaatleri) (s.hour * 60) + s.minute: s,
    };
    final anahtarlar = harita.keys.toList()..sort();
    _alarmSaatleri
      ..clear()
      ..addAll(anahtarlar.map((k) => harita[k]!));
  }

  Future<void> _alarmSaatiEkle() async {
    final son = _alarmSaatleri.isNotEmpty
        ? _alarmSaatleri.last
        : const TimeOfDay(hour: 9, minute: 0);
    final secilen = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: (son.hour + 3) % 24, minute: son.minute),
    );
    if (secilen != null) {
      setState(() {
        _alarmSaatleri.add(secilen);
        _saatleriSiralaVeTekillestir();
      });
    }
  }

  Future<void> _alarmSaatiDuzenle(int indeks) async {
    final secilen = await showTimePicker(
      context: context,
      initialTime: _alarmSaatleri[indeks],
    );
    if (secilen != null) {
      setState(() {
        _alarmSaatleri[indeks] = secilen;
        _saatleriSiralaVeTekillestir();
      });
    }
  }

  void _alarmSaatiSil(int indeks) {
    if (_alarmSaatleri.length <= 1) return;
    setState(() {
      _alarmSaatleri.removeAt(indeks);
    });
  }

  Future<void> _telefondanMuzikSec() async {
    final dosyalar = await FilePicker.pickFiles(type: FileType.audio);
    if (dosyalar.isEmpty) return;
    final secilen = dosyalar.first;
    if (secilen.path == null) return;
    setState(() {
      _alarmMuzikYolu = secilen.path;
      _alarmMuzikAdi = secilen.name;
    });
  }

  Future<void> _alarmTestEt() async {
    await ref.read(bildirimServisiSaglayici).izinIste();
    await ref
        .read(bildirimServisiSaglayici)
        .testBildirimiGonder(
          ozelMuzikYolu: _alarmMuzikYolu,
          rutinAdi: _adDenetleyici.text.trim().isEmpty
              ? 'Rutin'
              : _adDenetleyici.text.trim(),
          rutinId: widget.duzenlenecekRutin?.id,
        );
  }

  Future<void> _kaydet() async {
    if (!_formAnahtari.currentState!.validate()) return;
    if (!_sadeceBugunMu && _seciliGunler.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen en az bir gün seçin.')),
      );
      return;
    }
    if (_seciliGorevler.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen en az bir görev ekleyin.')),
      );
      return;
    }

    final bugun = TarihYardimcisi.bugununTarihi();
    final siraliSaatler = _alarmSaatleri
        .map((t) => (t.hour, t.minute))
        .toList();
    final ilkSaat = siraliSaatler.isNotEmpty ? siraliSaatler.first : (9, 0);
    final alarmSaatleriMetni = TarihYardimcisi.alarmSaatleriniMetneCevir(
      siraliSaatler.isNotEmpty ? siraliSaatler : [ilkSaat],
    );

    final basarili = await ref
        .read(rutinKontrolcusuSaglayici.notifier)
        .rutinKaydet(
          rutinId: widget.duzenlenecekRutin?.id,
          ad: _adDenetleyici.text,
          seciliGunler: _sadeceBugunMu
              ? [DateTime.now().weekday]
              : _seciliGunler.toList(),
          aktifMi: true,
          egzersizIdListesi: _seciliGorevler.map((e) => e.id).toList(),
          sadeceTarih: _sadeceBugunMu
              ? (widget.duzenlenecekRutin?.sadeceTarih ?? bugun)
              : null,
          alarmAcikMi: _alarmAcikMi,
          alarmSaati: ilkSaat.$1,
          alarmDakikasi: ilkSaat.$2,
          alarmSaatleri: alarmSaatleriMetni,
          alarmMuzikYolu: _alarmMuzikYolu,
          alarmMuzikAdi: _alarmMuzikAdi,
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
    final saatMetinleri = _alarmSaatleri
        .map(
          (t) =>
              '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}',
        )
        .toList();

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
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TextFormField(
                    controller: _adDenetleyici,
                    decoration: const InputDecoration(
                      labelText: 'Rutin Adı *',
                      hintText: 'Örn: Sabah İlaç, Diz Fizyoterapi, Akşam Okuma',
                      border: OutlineInputBorder(),
                    ),
                    validator: (deger) => (deger == null || deger.trim().isEmpty)
                        ? 'Lütfen rutin adını girin'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Sadece Bugün (Tek Seferlik)'),
                    subtitle: const Text(
                      'Açık olursa sadece bugün için geçerli olur, yarın tekrar çıkmaz.',
                    ),
                    value: _sadeceBugunMu,
                    onChanged: (deger) =>
                        setState(() => _sadeceBugunMu = deger),
                  ),
                  if (!_sadeceBugunMu) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Hangi Günler Tekrarlansın?',
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
                  ],
                  const Divider(height: 24),
                  _RutinAlarmAyarKarti(
                    alarmAcikMi: _alarmAcikMi,
                    saatMetinleri: saatMetinleri,
                    muzikAdi: _alarmMuzikAdi ?? 'Varsayılan Sistem Alarmı',
                    ozelMuzikVarMi: _alarmMuzikYolu != null,
                    alarmAcikDegistiginde: (deger) =>
                        setState(() => _alarmAcikMi = deger),
                    saatEkleTiklandiginda: _alarmSaatiEkle,
                    saatDuzenleTiklandiginda: _alarmSaatiDuzenle,
                    saatSilTiklandiginda: _alarmSaatiSil,
                    muzikSecTiklandiginda: _telefondanMuzikSec,
                    varsayilanMuzikTiklandiginda: () => setState(() {
                      _alarmMuzikYolu = null;
                      _alarmMuzikAdi = null;
                    }),
                    testTiklandiginda: _alarmTestEt,
                    susturTiklandiginda: () => ref
                        .read(bildirimServisiSaglayici)
                        .tumBildirimleriIptalEt(),
                  ),
                  const Divider(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Görevler (${_seciliGorevler.length})',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      FilledButton.icon(
                        onPressed: _yeniGorevEklePenceresiAc,
                        icon: const Icon(Icons.add),
                        label: const Text('+ Görev Ekle'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (_seciliGorevler.isEmpty)
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Henüz görev eklenmedi. "+ Görev Ekle" butonuna basarak bu rutinde yapılacakları yazın.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  else
                    ReorderableListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _seciliGorevler.length,
                      onReorderItem: (eskiIndeks, yeniIndeks) {
                        setState(() {
                          final oge = _seciliGorevler.removeAt(eskiIndeks);
                          _seciliGorevler.insert(yeniIndeks, oge);
                        });
                      },
                      itemBuilder: (context, indeks) {
                        final gorev = _seciliGorevler[indeks];
                        return Card(
                          key: ValueKey('${gorev.id}_$indeks'),
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text('${indeks + 1}'),
                            ),
                            title: Text(gorev.ad),
                            subtitle: gorev.aciklama.isNotEmpty
                                ? Text(gorev.aciklama)
                                : null,
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  tooltip: 'Çıkar',
                                  icon: const Icon(Icons.remove_circle_outline),
                                  onPressed: () {
                                    setState(() {
                                      _seciliGorevler.removeAt(indeks);
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
                ],
              ),
            ),
    );
  }
}

// Rutine özel birden fazla alarm saati, MP3 müzik seçimi ve test kartı.
class _RutinAlarmAyarKarti extends StatelessWidget {
  final bool alarmAcikMi;
  final List<String> saatMetinleri;
  final String muzikAdi;
  final bool ozelMuzikVarMi;
  final ValueChanged<bool> alarmAcikDegistiginde;
  final VoidCallback saatEkleTiklandiginda;
  final ValueChanged<int> saatDuzenleTiklandiginda;
  final ValueChanged<int> saatSilTiklandiginda;
  final VoidCallback muzikSecTiklandiginda;
  final VoidCallback varsayilanMuzikTiklandiginda;
  final VoidCallback testTiklandiginda;
  final VoidCallback susturTiklandiginda;

  const _RutinAlarmAyarKarti({
    required this.alarmAcikMi,
    required this.saatMetinleri,
    required this.muzikAdi,
    required this.ozelMuzikVarMi,
    required this.alarmAcikDegistiginde,
    required this.saatEkleTiklandiginda,
    required this.saatDuzenleTiklandiginda,
    required this.saatSilTiklandiginda,
    required this.muzikSecTiklandiginda,
    required this.varsayilanMuzikTiklandiginda,
    required this.testTiklandiginda,
    required this.susturTiklandiginda,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              secondary: Icon(
                alarmAcikMi ? Icons.alarm_on : Icons.alarm_off_outlined,
              ),
              title: const Text(
                'Bu Rutin İçin Alarm Çalsın',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text(
                'Günde bir veya birden çok saat ve kendi müziğinizi seçebilirsiniz.',
              ),
              value: alarmAcikMi,
              onChanged: alarmAcikDegistiginde,
            ),
            if (alarmAcikMi) ...[
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.schedule, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Alarm Saatleri (${saatMetinleri.length})',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  FilledButton.tonalIcon(
                    onPressed: saatEkleTiklandiginda,
                    icon: const Icon(Icons.add_alarm, size: 18),
                    label: const Text('+ Alarm Ekle'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(saatMetinleri.length, (indeks) {
                  return InputChip(
                    avatar: const Icon(Icons.alarm, size: 16),
                    label: Text(
                      saatMetinleri[indeks],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    onPressed: () => saatDuzenleTiklandiginda(indeks),
                    onDeleted: saatMetinleri.length > 1
                        ? () => saatSilTiklandiginda(indeks)
                        : null,
                  );
                }),
              ),
              const SizedBox(height: 6),
              Text(
                'Seçilen müzik, günler ve erteleme ayarları listedeki tüm saatler için uygulanır.',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.music_note),
                title: const Text('Alarm Müziği'),
                subtitle: Text(muzikAdi),
                trailing: FilledButton.tonalIcon(
                  onPressed: muzikSecTiklandiginda,
                  icon: const Icon(Icons.folder_open, size: 18),
                  label: const Text('Müzik Seç'),
                ),
              ),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (ozelMuzikVarMi)
                    TextButton.icon(
                      onPressed: varsayilanMuzikTiklandiginda,
                      icon: const Icon(Icons.restore, size: 18),
                      label: const Text('Varsayılan Sese Dön'),
                    ),
                  OutlinedButton.icon(
                    onPressed: testTiklandiginda,
                    icon: const Icon(Icons.volume_up, size: 18),
                    label: const Text('Alarmı Test Et'),
                  ),
                  TextButton.icon(
                    onPressed: susturTiklandiginda,
                    icon: const Icon(Icons.volume_off, size: 18),
                    label: const Text('Sesi Durdur'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
