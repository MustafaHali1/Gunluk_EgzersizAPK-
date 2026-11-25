// lib/ozellikler/toplu_rutinler/sunum/bilesenler/rutin_olusturma_formu.dart

import 'package:flutter/material.dart';
import '../../alan/rutin_hareketi_modeli.dart';

/// Yeni bir toplu rutin oluşturma veya hazır şablon seçme modal penceresi.
class RutinOlusturmaFormu extends StatefulWidget {
  final Future<void> Function({
    required String baslik,
    required String aciklama,
    required String kategori,
    required List<RutinHareketiModeli> hareketler,
  }) onKaydet;

  const RutinOlusturmaFormu({
    super.key,
    required this.onKaydet,
  });

  static Future<void> goster(
    BuildContext context, {
    required Future<void> Function({
      required String baslik,
      required String aciklama,
      required String kategori,
      required List<RutinHareketiModeli> hareketler,
    }) onKaydet,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => RutinOlusturmaFormu(onKaydet: onKaydet),
    );
  }

  @override
  State<RutinOlusturmaFormu> createState() => _RutinOlusturmaFormuState();
}

class _RutinOlusturmaFormuState extends State<RutinOlusturmaFormu> {
  final _baslikDenetleyici = TextEditingController();
  final _aciklamaDenetleyici = TextEditingController();
  String _secilenKategori = 'Sabah';
  bool _yukleniyor = false;

  final List<RutinHareketiModeli> _hareketler = [];

  // Hazır Şablonlar
  void _sablonYukle(String sablonAdi) {
    setState(() {
      _hareketler.clear();
      if (sablonAdi == 'aile_sabah') {
        _baslikDenetleyici.text = '🌟 Aile Sabah Başlangıcı';
        _secilenKategori = 'Sabah';
        _hareketler.addAll([
          const RutinHareketiModeli(
            id: 'h1',
            baslik: '2 Bardak Ilık Su İç',
            tur: 'kontrol',
            puan: 10,
            nesneGerektirirMi: true,
            beklenenNesneAdi: 'Su Bardağı / Şişe',
            siraIndeksi: 0,
          ),
          const RutinHareketiModeli(
            id: 'h2',
            baslik: 'Yatağını Topla',
            tur: 'kontrol',
            puan: 10,
            nesneGerektirirMi: true,
            beklenenNesneAdi: 'Toplanmış Yatak',
            siraIndeksi: 1,
          ),
          const RutinHareketiModeli(
            id: 'h3',
            baslik: '2 Dakika Tüm Vücut Esneme',
            tur: 'sureli',
            hedefDeger: 120,
            puan: 15,
            siraIndeksi: 2,
          ),
          const RutinHareketiModeli(
            id: 'h4',
            baslik: '15 Derin Squat',
            tur: 'tekrarli',
            hedefDeger: 15,
            puan: 20,
            siraIndeksi: 3,
          ),
        ]);
      } else if (sablonAdi == 'fitness_10dk') {
        _baslikDenetleyici.text = '🔥 10 Dk Evde Fitness';
        _secilenKategori = 'Fitness';
        _hareketler.addAll([
          const RutinHareketiModeli(
            id: 'f1',
            baslik: '30 Sn Jumping Jack',
            tur: 'sureli',
            hedefDeger: 30,
            puan: 15,
            siraIndeksi: 0,
          ),
          const RutinHareketiModeli(
            id: 'f2',
            baslik: '20 Derin Squat',
            tur: 'tekrarli',
            hedefDeger: 20,
            puan: 20,
            siraIndeksi: 1,
          ),
          const RutinHareketiModeli(
            id: 'f3',
            baslik: '15 Şınav',
            tur: 'tekrarli',
            hedefDeger: 15,
            puan: 25,
            siraIndeksi: 2,
          ),
          const RutinHareketiModeli(
            id: 'f4',
            baslik: '45 Sn Plank',
            tur: 'sureli',
            hedefDeger: 45,
            puan: 25,
            siraIndeksi: 3,
          ),
        ]);
      } else if (sablonAdi == 'omurga') {
        _baslikDenetleyici.text = '🦴 Masa Başı Omurga Kurtarma';
        _secilenKategori = 'Esneme';
        _hareketler.addAll([
          const RutinHareketiModeli(
            id: 'o1',
            baslik: 'Kedi-Deve Hareketi',
            tur: 'sureli',
            hedefDeger: 60,
            puan: 15,
            siraIndeksi: 0,
          ),
          const RutinHareketiModeli(
            id: 'o2',
            baslik: 'Boyun & Omuz Esnetme',
            tur: 'sureli',
            hedefDeger: 60,
            puan: 15,
            siraIndeksi: 1,
          ),
          const RutinHareketiModeli(
            id: 'o3',
            baslik: 'Göğüs Açma & Kürek Kemiği Sıkıştırma',
            tur: 'tekrarli',
            hedefDeger: 15,
            puan: 15,
            siraIndeksi: 2,
          ),
        ]);
      }
    });
  }

  void _yeniHareketEkleDialogu() {
    final baslikController = TextEditingController();
    String tur = 'kontrol';
    int puan = 15;
    bool nesneGerekli = false;
    final nesneController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDState) => AlertDialog(
          title: const Text('Yeni Egzersiz / Görev Ekle'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: baslikController,
                  decoration: const InputDecoration(labelText: 'Hareket Adı (örn: 20 Squat)'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: tur,
                  decoration: const InputDecoration(labelText: 'Ölçüm Türü'),
                  items: const [
                    DropdownMenuItem(value: 'kontrol', child: Text('☑️ Kontrol / Tamamlandı')),
                    DropdownMenuItem(value: 'sureli', child: Text('⏱️ Süre Bazlı (Saniye)')),
                    DropdownMenuItem(value: 'tekrarli', child: Text('🔢 Tekrar Bazlı')),
                  ],
                  onChanged: (v) => setDState(() => tur = v ?? 'kontrol'),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  title: const Text('Doğal Nesne Var mı?'),
                  subtitle: const Text('Diş fırçası, su bardağı, kitap vb.'),
                  value: nesneGerekli,
                  onChanged: (v) => setDState(() => nesneGerekli = v),
                ),
                if (nesneGerekli)
                  TextField(
                    controller: nesneController,
                    decoration: const InputDecoration(
                      labelText: 'Beklenen Nesne Adı (örn: Diş Fırçası)',
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Vazgeç'),
            ),
            ElevatedButton(
              onPressed: () {
                if (baslikController.text.trim().isEmpty) return;
                setState(() {
                  _hareketler.add(
                    RutinHareketiModeli(
                      id: 'h_${DateTime.now().millisecondsSinceEpoch}',
                      baslik: baslikController.text.trim(),
                      tur: tur,
                      puan: puan,
                      nesneGerektirirMi: nesneGerekli,
                      beklenenNesneAdi: nesneGerekli ? nesneController.text.trim() : null,
                      siraIndeksi: _hareketler.length,
                    ),
                  );
                });
                Navigator.pop(ctx);
              },
              child: const Text('Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _kaydet() async {
    final baslik = _baslikDenetleyici.text.trim();
    if (baslik.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen bir rutin başlığı girin.')),
      );
      return;
    }

    if (_hareketler.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen en az bir egzersiz veya görev ekleyin.')),
      );
      return;
    }

    setState(() => _yukleniyor = true);
    try {
      await widget.onKaydet(
        baslik: baslik,
        aciklama: _aciklamaDenetleyici.text.trim(),
        kategori: _secilenKategori,
        hareketler: _hareketler,
      );
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() => _yukleniyor = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata oluştu: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Yeni Toplu Rutin Kur',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // HIZLI ŞABLON SEÇİM BUTONLARI
            const Text(
              'Hızlı Şablonlar (1-Dokunuşla Ekle):',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ActionChip(
                    avatar: const Text('🌟'),
                    label: const Text('Aile Sabahı'),
                    onPressed: () => _sablonYukle('aile_sabah'),
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Text('🔥'),
                    label: const Text('10 Dk Fitness'),
                    onPressed: () => _sablonYukle('fitness_10dk'),
                  ),
                  const SizedBox(width: 8),
                  ActionChip(
                    avatar: const Text('🦴'),
                    label: const Text('Omurga Kurtarma'),
                    onPressed: () => _sablonYukle('omurga'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // RUTİN BAŞLIĞI
            TextField(
              controller: _baslikDenetleyici,
              decoration: InputDecoration(
                labelText: 'Rutin Başlığı',
                hintText: 'örn: Sabah Canlanma, 30 Gün Şınav',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),

            // KATEGORİ SEÇİMİ
            DropdownButtonFormField<String>(
              initialValue: _secilenKategori,
              decoration: InputDecoration(
                labelText: 'Kategori / Tema',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: const [
                DropdownMenuItem(value: 'Sabah', child: Text('🌅 Sabah')),
                DropdownMenuItem(value: 'Fitness', child: Text('💪 Fitness')),
                DropdownMenuItem(value: 'Esneme', child: Text('🧘 Esneme / Yoga')),
                DropdownMenuItem(value: 'Gece', child: Text('🌙 Gece')),
                DropdownMenuItem(value: 'Saglik', child: Text('🥗 Sağlık')),
                DropdownMenuItem(value: 'Zihin', child: Text('🧠 Zihin')),
              ],
              onChanged: (v) => setState(() => _secilenKategori = v ?? 'Sabah'),
            ),
            const SizedBox(height: 16),

            // HAREKETLER LİSTESİ VE EKLEME
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'İçindeki Görevler (${_hareketler.length}):',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                TextButton.icon(
                  onPressed: _yeniHareketEkleDialogu,
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Görev Ekle'),
                ),
              ],
            ),

            if (_hareketler.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                alignment: Alignment.center,
                child: const Text('Yukarıdan bir hazır şablon seçin veya "Görev Ekle"ye basın.'),
              )
            else
              ReorderableListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _hareketler.length,
                onReorderItem: (oldIndex, newIndex) {
                  setState(() {
                    final item = _hareketler.removeAt(oldIndex);
                    _hareketler.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  final h = _hareketler[index];
                  return ListTile(
                    key: ValueKey(h.id),
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal.shade50,
                      child: Text('${index + 1}', style: const TextStyle(color: Colors.teal)),
                    ),
                    title: Text(h.baslik, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    subtitle: Text(
                      '${h.puan} Puan ${h.nesneGerektirirMi ? '• 📦 ${h.beklenenNesneAdi}' : ''}',
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => setState(() => _hareketler.removeAt(index)),
                    ),
                  );
                },
              ),

            const SizedBox(height: 20),

            // KAYDET BUTONU
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _yukleniyor ? null : _kaydet,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _yukleniyor
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Rutini Kur ve Başlat 🚀', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
