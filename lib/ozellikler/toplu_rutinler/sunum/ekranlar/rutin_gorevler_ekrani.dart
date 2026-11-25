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

  void _yarisBaslatDialogu(BuildContext context, WidgetRef ref) {
    final baslikController = TextEditingController(text: '10 Günlük Meydan Okuma');
    int gun = 10;

    final birincil = UygulamaRenkleri.birincil(context);
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
              decoration: const InputDecoration(labelText: 'Yarış Başlığı'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: gun,
              decoration: const InputDecoration(labelText: 'Yarış Süresi'),
              items: const [
                DropdownMenuItem(value: 7, child: Text('7 Günlük Sprint')),
                DropdownMenuItem(value: 10, child: Text('10 Günlük Yarış (Önerilen)')),
                DropdownMenuItem(value: 14, child: Text('14 Günlük Lig')),
                DropdownMenuItem(value: 30, child: Text('30 Günlük Maraton')),
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
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Başlat 🚀'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uid = ref.watch(mevcutKullaniciIdSaglayici).value ?? '';
    final hareketler = rutin.hareketler;

    final birincil = UygulamaRenkleri.birincil(context);
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
              Text(
                'Seri: 🔥 ${rutin.mevcutSeriGun} Gün',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: birincil,
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
                      : birincil.withValues(alpha: 0.12),
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
                        side: BorderSide(color: basari.withValues(alpha: 0.2)),
                      )
                    : ElevatedButton.icon(
                        onPressed: () => _kameraAc(context, hareket),
                        icon: const Icon(Icons.camera_alt, size: 14),
                        label: const Text('Kanıtla'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: birincil,
                          foregroundColor: Colors.white,
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
