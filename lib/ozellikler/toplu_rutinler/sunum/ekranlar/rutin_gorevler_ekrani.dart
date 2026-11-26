// lib/ozellikler/toplu_rutinler/sunum/ekranlar/rutin_gorevler_ekrani.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../cekirdek/tema/uygulama_renkleri.dart';
import '../../alan/toplu_rutin_modeli.dart';
import '../../alan/rutin_hareketi_modeli.dart';
import '../bilesenler/canli_yaris_cubugu.dart';
import '../kontrolculer/grup_kontrolcusu.dart';
import '../kontrolculer/rutin_yaris_kontrolcusu.dart';
import 'kanit_kamera_ekrani.dart';

/// Rutin içerisindeki görevlerin/hareketlerin listelendiği ve kanıt yolunun başlatıldığı bağımsız ekran.
/// Renkler doğrudan UygulamaRenkleri sınıfından çağrılır (Thin UI kuralı).
class RutinGorevlerEkrani extends ConsumerWidget {
  final TopluRutinModeli rutin;

  const RutinGorevlerEkrani({
    super.key,
    required this.rutin,
  });

  void _kameraAc(BuildContext context, RutinHareketiModeli hareket) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KanitKameraEkrani(
          rutin: rutin,
          hareket: hareket,
        ),
      ),
    );
  }

  void _yeniGorevEkleDialogu(BuildContext context, WidgetRef ref) {
    final baslikController = TextEditingController();
    String tur = 'kontrol';
    int puan = 15;
    bool nesneGerekli = false;
    final nesneController = TextEditingController();

    final birincil = UygulamaRenkleri.birincil(context);
    final birincilMetin = UygulamaRenkleri.birincilUzeriMetin(context);
    final kartZemin = UygulamaRenkleri.kartZemini(context);
    final metinBirincil = UygulamaRenkleri.metinBirincil(context);
    final metinIkincil = UygulamaRenkleri.metinIkincil(context);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDState) => AlertDialog(
          backgroundColor: kartZemin,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Rutine Yeni Görev Ekle',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: metinBirincil),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: baslikController,
                  style: TextStyle(color: metinBirincil),
                  decoration: const InputDecoration(labelText: 'Görev Adı (örn: 20 Şınav)'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: tur,
                  dropdownColor: kartZemin,
                  style: TextStyle(color: metinBirincil, fontSize: 14),
                  decoration: const InputDecoration(labelText: 'Ölçüm Türü'),
                  items: [
                    DropdownMenuItem(value: 'kontrol', child: Text('☑️ Kontrol / Tamamlandı', style: TextStyle(color: metinBirincil))),
                    DropdownMenuItem(value: 'sureli', child: Text('⏱️ Süre Bazlı (Saniye)', style: TextStyle(color: metinBirincil))),
                    DropdownMenuItem(value: 'tekrarli', child: Text('🔢 Tekrar Bazlı', style: TextStyle(color: metinBirincil))),
                  ],
                  onChanged: (v) => setDState(() => tur = v ?? 'kontrol'),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: birincil,
                  title: Text('Doğal Nesne Var mı?', style: TextStyle(color: metinBirincil, fontSize: 14)),
                  subtitle: Text('Kitap, su bardağı, dambıl vb.', style: TextStyle(color: metinIkincil, fontSize: 12)),
                  value: nesneGerekli,
                  onChanged: (v) => setDState(() => nesneGerekli = v),
                ),
                if (nesneGerekli)
                  TextField(
                    controller: nesneController,
                    style: TextStyle(color: metinBirincil),
                    decoration: const InputDecoration(
                      labelText: 'Beklenen Nesne Adı (örn: Kitap)',
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Vazgeç', style: TextStyle(color: metinIkincil)),
            ),
            ElevatedButton(
              onPressed: () async {
                final ad = baslikController.text.trim();
                if (ad.isEmpty) return;

                Navigator.pop(ctx);
                final yeniHareket = RutinHareketiModeli(
                  id: 'h_${DateTime.now().millisecondsSinceEpoch}',
                  baslik: ad,
                  tur: tur,
                  puan: puan,
                  nesneGerektirirMi: nesneGerekli,
                  beklenenNesneAdi: nesneGerekli ? nesneController.text.trim() : null,
                  siraIndeksi: rutin.hareketler.length,
                );

                final guncelHareketler = [...rutin.hareketler, yeniHareket];
                final guncelRutin = rutin.kopyala(hareketler: guncelHareketler);
                await ref.read(topluRutinKontrolcusuSaglayici).rutinGuncelle(guncelRutin);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: birincil,
                foregroundColor: birincilMetin,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Ekle', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _yarisBaslatDialogu(BuildContext context, WidgetRef ref) {
    final baslikController = TextEditingController(text: '10 Günlük Meydan Okuma');
    int gun = 10;

    final birincil = UygulamaRenkleri.birincil(context);
    final birincilMetin = UygulamaRenkleri.birincilUzeriMetin(context);
    final kartZemin = UygulamaRenkleri.kartZemini(context);
    final metinBirincil = UygulamaRenkleri.metinBirincil(context);
    final metinIkincil = UygulamaRenkleri.metinIkincil(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kartZemin,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.emoji_events_outlined, color: birincil),
            const SizedBox(width: 8),
            Text(
              'Yeni Süreli Yarış Başlat 🏁',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: metinBirincil),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: baslikController,
              style: TextStyle(color: metinBirincil),
              decoration: const InputDecoration(labelText: 'Yarış Başlığı'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: gun,
              dropdownColor: kartZemin,
              style: TextStyle(color: metinBirincil),
              decoration: const InputDecoration(labelText: 'Yarış Süresi'),
              items: [
                DropdownMenuItem(value: 7, child: Text('7 Günlük Sprint', style: TextStyle(color: metinBirincil))),
                DropdownMenuItem(value: 10, child: Text('10 Günlük Yarış (Önerilen)', style: TextStyle(color: metinBirincil))),
                DropdownMenuItem(value: 14, child: Text('14 Günlük Lig', style: TextStyle(color: metinBirincil))),
                DropdownMenuItem(value: 30, child: Text('30 Günlük Maraton', style: TextStyle(color: metinBirincil))),
              ],
              onChanged: (v) => gun = v ?? 10,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Vazgeç', style: TextStyle(color: metinIkincil)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(rutinYarisKontrolcusuSaglayici).yarisBaslat(
                    rutinId: rutin.id,
                    baslik: baslikController.text.trim(),
                    gunSayisi: gun,
                    hedefPuan: 500,
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: birincil,
              foregroundColor: birincilMetin,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Başlat 🚀', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(mevcutKullaniciIdSaglayici).value ?? '';
    final hareketler = rutin.hareketler;
    final yoneticiMi = rutin.yoneticiIdleri.contains(uid) ||
        rutin.kurucuKullaniciId == uid ||
        rutin.uyeIdleri.length <= 1;
    final gorevEkleyebilirMi = !rutin.yalnizcaYoneticiHareketEkleyebilir || yoneticiMi;

    final birincil = UygulamaRenkleri.birincil(context);
    final birincilMetin = UygulamaRenkleri.birincilUzeriMetin(context);
    final kartZemin = UygulamaRenkleri.kartZemini(context);
    final metinBirincil = UygulamaRenkleri.metinBirincil(context);
    final metinIkincil = UygulamaRenkleri.metinIkincil(context);
    final basari = UygulamaRenkleri.basariRengi(context);

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        // Canlı Yarış Panosu
        CanliYarisCubugu(
          yarisVerisi: rutin.aktifYaris,
          onYarisBaslatTiklandi: () => _yarisBaslatDialogu(context, ref),
        ),

        const SizedBox(height: 8),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bugünün Hareketleri (${hareketler.length}):',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: metinBirincil,
                ),
              ),
              if (gorevEkleyebilirMi)
                TextButton.icon(
                  onPressed: () => _yeniGorevEkleDialogu(context, ref),
                  icon: Icon(Icons.add_circle_outline, size: 17, color: birincil),
                  label: Text(
                    'Görev Ekle',
                    style: TextStyle(color: birincil, fontWeight: FontWeight.bold, fontSize: 12.5),
                  ),
                ),
            ],
          ),
        ),

        if (hareketler.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text(
                'Bu rutinde henüz tanımlanmış hareket yok.',
                style: TextStyle(color: metinIkincil),
              ),
            ),
          )
        else
          ...hareketler.map((hareket) {
            final yapildiMi = hareket.bugunTamamlayanUyeIdleri.contains(uid);

            return Card(
              color: kartZemin,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: yapildiMi
                      ? basari.withValues(alpha: 0.15)
                      : birincil.withValues(alpha: 0.14),
                  child: yapildiMi
                      ? Icon(Icons.check, color: basari)
                      : Icon(
                          hareket.nesneGerektirirMi
                              ? Icons.inventory_2_outlined
                              : Icons.fitness_center,
                          color: birincil,
                        ),
                ),
                title: Text(
                  hareket.baslik,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: yapildiMi ? metinIkincil : metinBirincil,
                    decoration: yapildiMi ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text(
                  '${hareket.puan} Puan ${hareket.nesneGerektirirMi && hareket.beklenenNesneAdi != null ? '• 📦 ${hareket.beklenenNesneAdi}' : ''}',
                  style: TextStyle(fontSize: 12, color: metinIkincil),
                ),
                trailing: yapildiMi
                    ? Chip(
                        label: Text(
                          'Tamam ✅',
                          style: TextStyle(color: basari, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        backgroundColor: basari.withValues(alpha: 0.12),
                        side: BorderSide(color: basari.withValues(alpha: 0.25)),
                      )
                    : ElevatedButton.icon(
                        onPressed: () => _kameraAc(context, hareket),
                        icon: const Icon(Icons.camera_alt, size: 14),
                        label: const Text('Kanıtla'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: birincil,
                          foregroundColor: birincilMetin,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
            );
          }),
      ],
    );
  }
}
