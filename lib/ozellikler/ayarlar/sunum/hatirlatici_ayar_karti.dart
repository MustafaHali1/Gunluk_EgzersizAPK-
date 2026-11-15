// lib/ozellikler/ayarlar/sunum/hatirlatici_ayar_karti.dart

import 'package:flutter/material.dart';
import '../../../cekirdek/veritabani/uygulama_veritabani.dart';
import '../../../cekirdek/yardimcilar/tarih_yardimcisi.dart';

// Sabah veya akşam hatırlatıcısının saatini, günlerini ve açık/kapalı durumunu düzenleyen kart.
class HatirlaticiAyarKarti extends StatelessWidget {
  final HatirlaticilarData hatirlatici;
  final void Function({
    required int saat,
    required int dakika,
    required List<int> seciliGunler,
    required bool etkinMi,
  }) degistiginde;

  const HatirlaticiAyarKarti({
    super.key,
    required this.hatirlatici,
    required this.degistiginde,
  });

  List<int> _gunleriCozumle() {
    return hatirlatici.haftaninGunleri
        .split(',')
        .map((e) => int.tryParse(e.trim()))
        .whereType<int>()
        .toList();
  }

  String _saatFormatla() {
    final s = hatirlatici.saat.toString().padLeft(2, '0');
    final d = hatirlatici.dakika.toString().padLeft(2, '0');
    return '$s:$d';
  }

  Future<void> _saatSeciciAc(BuildContext context, List<int> gunler) async {
    final secilen = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: hatirlatici.saat,
        minute: hatirlatici.dakika,
      ),
      helpText: hatirlatici.etiket == 'sabah'
          ? 'Sabah Hatırlatıcı Saati'
          : 'Akşam Hatırlatıcı Saati',
    );
    if (secilen != null) {
      degistiginde(
        saat: secilen.hour,
        dakika: secilen.minute,
        seciliGunler: gunler,
        etkinMi: hatirlatici.etkinMi,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final sabahMi = hatirlatici.etiket == 'sabah';
    final seciliGunler = _gunleriCozumle();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  sabahMi ? Icons.wb_sunny_outlined : Icons.nights_stay_outlined,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    sabahMi ? 'Sabah Hatırlatıcısı' : 'Akşam Hatırlatıcısı',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () => _saatSeciciAc(context, seciliGunler),
                  icon: const Icon(Icons.access_time, size: 18),
                  label: Text(
                    _saatFormatla(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 6),
                Switch(
                  value: hatirlatici.etkinMi,
                  onChanged: (yeniDeger) {
                    degistiginde(
                      saat: hatirlatici.saat,
                      dakika: hatirlatici.dakika,
                      seciliGunler: seciliGunler,
                      etkinMi: yeniDeger,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: List.generate(7, (indeks) {
                final gunNo = indeks + 1;
                final seciliMi = seciliGunler.contains(gunNo);
                return FilterChip(
                  label: Text(TarihYardimcisi.gunKisaAdi(gunNo)),
                  selected: seciliMi,
                  onSelected: hatirlatici.etkinMi
                      ? (deger) {
                          final yeniListe = [...seciliGunler];
                          if (deger) {
                            yeniListe.add(gunNo);
                          } else if (yeniListe.length > 1) {
                            yeniListe.remove(gunNo);
                          }
                          degistiginde(
                            saat: hatirlatici.saat,
                            dakika: hatirlatici.dakika,
                            seciliGunler: yeniListe,
                            etkinMi: hatirlatici.etkinMi,
                          );
                        }
                      : null,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
