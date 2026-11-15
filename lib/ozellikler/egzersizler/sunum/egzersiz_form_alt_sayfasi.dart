// lib/ozellikler/egzersizler/sunum/egzersiz_form_alt_sayfasi.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cekirdek/veritabani/uygulama_veritabani.dart';
import 'egzersiz_kontrolcusu.dart';

// Yeni egzersiz ekleme ve mevcut egzersizi düzenleme alt sayfası (BottomSheet).
class EgzersizFormAltSayfasi extends ConsumerStatefulWidget {
  final EgzersizlerData? duzenlenecekEgzersiz;

  const EgzersizFormAltSayfasi({
    super.key,
    this.duzenlenecekEgzersiz,
  });

  @override
  ConsumerState<EgzersizFormAltSayfasi> createState() =>
      _EgzersizFormAltSayfasiState();
}

class _EgzersizFormAltSayfasiState
    extends ConsumerState<EgzersizFormAltSayfasi> {
  final _formAnahtari = GlobalKey<FormState>();
  late final TextEditingController _adDenetleyici;
  late final TextEditingController _kategoriDenetleyici;
  late final TextEditingController _aciklamaDenetleyici;
  late final TextEditingController _sureDenetleyici;
  late final TextEditingController _setDenetleyici;
  late final TextEditingController _tekrarDenetleyici;
  late String _seciliTur;

  @override
  void initState() {
    super.initState();
    final e = widget.duzenlenecekEgzersiz;
    _adDenetleyici = TextEditingController(text: e?.ad ?? '');
    _kategoriDenetleyici = TextEditingController(text: e?.kategori ?? 'Genel');
    _aciklamaDenetleyici = TextEditingController(text: e?.aciklama ?? '');
    _sureDenetleyici = TextEditingController(
      text: (e?.sureSaniye ?? 45).toString(),
    );
    _setDenetleyici = TextEditingController(
      text: (e?.setSayisi ?? 3).toString(),
    );
    _tekrarDenetleyici = TextEditingController(
      text: (e?.tekrarSayisi ?? 12).toString(),
    );
    _seciliTur = e?.tur ?? 'tekrarli';
  }

  @override
  void dispose() {
    _adDenetleyici.dispose();
    _kategoriDenetleyici.dispose();
    _aciklamaDenetleyici.dispose();
    _sureDenetleyici.dispose();
    _setDenetleyici.dispose();
    _tekrarDenetleyici.dispose();
    super.dispose();
  }

  Future<void> _kaydet() async {
    if (!_formAnahtari.currentState!.validate()) return;

    final sureliMi = _seciliTur == 'sureli';
    final basarili = await ref
        .read(egzersizKontrolcusuSaglayici.notifier)
        .egzersizKaydet(
          id: widget.duzenlenecekEgzersiz?.id,
          ad: _adDenetleyici.text,
          aciklama: _aciklamaDenetleyici.text,
          tur: _seciliTur,
          sureSaniye: sureliMi ? int.tryParse(_sureDenetleyici.text) : null,
          setSayisi: !sureliMi ? int.tryParse(_setDenetleyici.text) : null,
          tekrarSayisi:
              !sureliMi ? int.tryParse(_tekrarDenetleyici.text) : null,
          kategori: _kategoriDenetleyici.text.isEmpty
              ? 'Genel'
              : _kategoriDenetleyici.text,
        );

    if (!mounted) return;
    if (basarili) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Egzersiz kaydedilirken hata oluştu.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final altBosluk = MediaQuery.of(context).viewInsets.bottom;
    final duzenlemeMi = widget.duzenlenecekEgzersiz != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, altBosluk + 16),
      child: SingleChildScrollView(
        child: Form(
          key: _formAnahtari,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                duzenlemeMi ? 'Egzersizi Düzenle' : 'Yeni Egzersiz Ekle',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _adDenetleyici,
                decoration: const InputDecoration(
                  labelText: 'Egzersiz Adı *',
                  border: OutlineInputBorder(),
                ),
                validator: (deger) => (deger == null || deger.trim().isEmpty)
                    ? 'Lütfen egzersiz adını girin'
                    : null,
              ),
              const SizedBox(height: 12),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'tekrarli',
                    label: Text('Tekrarlı (Set × Tekrar)'),
                    icon: Icon(Icons.repeat),
                  ),
                  ButtonSegment(
                    value: 'sureli',
                    label: Text('Süreli (Saniye)'),
                    icon: Icon(Icons.timer_outlined),
                  ),
                ],
                selected: {_seciliTur},
                onSelectionChanged: (secim) {
                  setState(() => _seciliTur = secim.first);
                },
              ),
              const SizedBox(height: 12),
              if (_seciliTur == 'sureli')
                TextFormField(
                  controller: _sureDenetleyici,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Süre (Saniye) *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (deger) {
                    final sayi = int.tryParse(deger ?? '');
                    if (sayi == null || sayi <= 0) {
                      return 'Geçerli bir saniye girin';
                    }
                    return null;
                  },
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _setDenetleyici,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Set Sayısı *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (deger) {
                          final sayi = int.tryParse(deger ?? '');
                          return (sayi == null || sayi <= 0)
                              ? 'Geçersiz'
                              : null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _tekrarDenetleyici,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Tekrar Sayısı *',
                          border: OutlineInputBorder(),
                        ),
                        validator: (deger) {
                          final sayi = int.tryParse(deger ?? '');
                          return (sayi == null || sayi <= 0)
                              ? 'Geçersiz'
                              : null;
                        },
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _kategoriDenetleyici,
                decoration: const InputDecoration(
                  labelText: 'Kategori (örn. Alt Vücut, Karın, Esneklik)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _aciklamaDenetleyici,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Açıklama / Not (İsteğe bağlı)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _kaydet,
                icon: const Icon(Icons.check),
                label: Text(duzenlemeMi ? 'Güncelle' : 'Kaydet'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
