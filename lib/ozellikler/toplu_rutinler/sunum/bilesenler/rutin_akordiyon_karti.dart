// lib/ozellikler/toplu_rutinler/sunum/bilesenler/rutin_akordiyon_karti.dart

import 'package:flutter/material.dart';
import '../../alan/rutin_hareketi_modeli.dart';
import '../../alan/toplu_rutin_modeli.dart';

/// Rutin kartına dokunulduğunda açılan ve altındaki hareketleri listeleyen akordiyon bileşeni.
class RutinAkordiyonKarti extends StatefulWidget {
  final TopluRutinModeli rutin;
  final String mevcutKullaniciId;
  final void Function(RutinHareketiModeli hareket) onKanitlaTiklandi;
  final void Function(RutinHareketiModeli hareket) onHizliTikTiklandi;
  final VoidCallback onDetayaGitTiklandi;

  const RutinAkordiyonKarti({
    super.key,
    required this.rutin,
    required this.mevcutKullaniciId,
    required this.onKanitlaTiklandi,
    required this.onHizliTikTiklandi,
    required this.onDetayaGitTiklandi,
  });

  @override
  State<RutinAkordiyonKarti> createState() => _RutinAkordiyonKartiState();
}

class _RutinAkordiyonKartiState extends State<RutinAkordiyonKarti> {
  bool _genisletildi = true;

  @override
  Widget build(BuildContext context) {
    final hareketler = widget.rutin.hareketler;

    // Tamamlanma oranını hesapla
    int tamamlananSayisi = 0;
    for (final h in hareketler) {
      if (h.bugunTamamlayanUyeIdleri.contains(widget.mevcutKullaniciId)) {
        tamamlananSayisi++;
      }
    }
    final yuzde = hareketler.isEmpty ? 0 : (tamamlananSayisi / hareketler.length * 100).toInt();

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // ÜST BAŞLIK ALANI (Dokunulduğunda açılır / kapanır)
          InkWell(
            onTap: () => setState(() => _genisletildi = !_genisletildi),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Kategori İkonu
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.teal.shade50,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _kategoriIkonu(widget.rutin.kategori),
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Başlık ve Seri Bilgisi
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.rutin.baslik,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '🔥 ${widget.rutin.mevcutSeriGun} Gün',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${widget.rutin.uyeIdleri.length} Katılımcı',
                              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Yüzde Çemberi
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircularProgressIndicator(
                        value: yuzde / 100,
                        backgroundColor: Colors.grey.shade200,
                        color: yuzde == 100 ? Colors.green : Colors.teal,
                        strokeWidth: 4,
                      ),
                      Text(
                        '%$yuzde',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 8),
                  Icon(
                    _genisletildi ? Icons.expand_less : Icons.expand_more,
                    color: Colors.grey.shade600,
                  ),
                ],
              ),
            ),
          ),

          // AKORDİYON İÇİ (Alt Hareketler Listesi)
          if (_genisletildi) ...[
            const Divider(height: 1),
            if (hareketler.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Bu rutinde henüz bir görev eklenmemiş.'),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: hareketler.length,
                separatorBuilder: (_, _) => Divider(height: 1, color: Colors.grey.shade100),
                itemBuilder: (context, index) {
                  final hareket = hareketler[index];
                  final yapildiMi = hareket.bugunTamamlayanUyeIdleri.contains(widget.mevcutKullaniciId);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Row(
                      children: [
                        // Numara veya Tik
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: yapildiMi ? Colors.green.shade50 : Colors.grey.shade100,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: yapildiMi
                              ? const Icon(Icons.check, size: 18, color: Colors.green)
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: Colors.grey.shade700,
                                  ),
                                ),
                        ),
                        const SizedBox(width: 12),

                        // Görev Adı ve Puanı
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                hareket.baslik,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                  decoration: yapildiMi ? TextDecoration.lineThrough : null,
                                  color: yapildiMi ? Colors.grey : Colors.black87,
                                ),
                              ),
                              Row(
                                children: [
                                  if (hareket.hedefDeger != null) ...[
                                    Text(
                                      hareket.tur == 'sureli'
                                          ? '${hareket.hedefDeger} Sn'
                                          : '${hareket.hedefDeger} Tekrar',
                                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                                    ),
                                    const Text(' • ', style: TextStyle(color: Colors.grey)),
                                  ],
                                  Text(
                                    '+${hareket.puan} Puan',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.teal.shade700,
                                    ),
                                  ),
                                  if (hareket.nesneGerektirirMi && hareket.beklenenNesneAdi != null) ...[
                                    const Text(' • ', style: TextStyle(color: Colors.grey)),
                                    Text(
                                      '📦 ${hareket.beklenenNesneAdi}',
                                      style: TextStyle(fontSize: 11, color: Colors.purple.shade700),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Eylem Butonu
                        if (yapildiMi)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Tamam ✅',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                            ),
                          )
                        else if (hareket.kanitZorunluMu)
                          ElevatedButton.icon(
                            onPressed: () => widget.onKanitlaTiklandi(hareket),
                            icon: const Icon(Icons.camera_alt, size: 14),
                            label: const Text('Kanıtla'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.radio_button_unchecked, color: Colors.teal),
                            onPressed: () => widget.onHizliTikTiklandi(hareket),
                          ),
                      ],
                    ),
                  );
                },
              ),

            // DETAYLARI GÖR VE MERKEZE GİT BUTONU
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.all(8),
              child: TextButton.icon(
                onPressed: widget.onDetayaGitTiklandi,
                icon: const Icon(Icons.hub_outlined, size: 16),
                label: const Text('Rutin Merkezine Git (Sohbet, Kanıtlar, Liderlik) ➔'),
                style: TextButton.styleFrom(foregroundColor: Colors.teal.shade800),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _kategoriIkonu(String kategori) {
    switch (kategori.toLowerCase()) {
      case 'sabah':
        return '🌅';
      case 'fitness':
        return '💪';
      case 'esneme':
        return '🧘';
      case 'gece':
        return '🌙';
      case 'saglik':
        return '🥗';
      case 'zihin':
        return '🧠';
      default:
        return '⚡';
    }
  }
}
