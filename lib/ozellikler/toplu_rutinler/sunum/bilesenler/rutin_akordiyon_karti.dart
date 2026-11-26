// lib/ozellikler/toplu_rutinler/sunum/bilesenler/rutin_akordiyon_karti.dart

import 'package:flutter/material.dart';
import '../../../../cekirdek/tema/uygulama_renkleri.dart';
import '../../alan/rutin_hareketi_modeli.dart';
import '../../alan/toplu_rutin_modeli.dart';

/// Rutin kartına dokunulduğunda açılan ve altındaki hareketleri listeleyen akordiyon bileşeni.
/// Renkler doğrudan UygulamaRenkleri sınıfından çağrılır (Açık ve Koyu Mod Tam Uyumlu).
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

    final birincil = UygulamaRenkleri.birincil(context);
    final birincilMetin = UygulamaRenkleri.birincilUzeriMetin(context);
    final ikincil = UygulamaRenkleri.ikincil(context);
    final kartZemin = UygulamaRenkleri.kartZemini(context);
    final yukseltilmis = UygulamaRenkleri.yukseltilmisZemin(context);
    final kenarlik = UygulamaRenkleri.kenarlik(context);
    final metinBirincil = UygulamaRenkleri.metinBirincil(context);
    final metinIkincil = UygulamaRenkleri.metinIkincil(context);
    final kupaAltin = UygulamaRenkleri.kupa(context);
    final basari = UygulamaRenkleri.basariRengi(context);

    return Card(
      color: kartZemin,
      elevation: 0,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: kenarlik, width: 1),
      ),
      child: Column(
        children: [
          // ÜST BAŞLIK ALANI (Dokunulduğunda açılır / kapanır)
          InkWell(
            onTap: () => setState(() => _genisletildi = !_genisletildi),
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Kategori İkonu
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: yukseltilmis,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: kenarlik),
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
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: metinBirincil,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: kupaAltin.withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: kupaAltin.withValues(alpha: 0.3)),
                              ),
                              child: Text(
                                '🔥 ${widget.rutin.mevcutSeriGun} Gün',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: kupaAltin,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${widget.rutin.uyeIdleri.length} Katılımcı',
                              style: TextStyle(fontSize: 12, color: metinIkincil),
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
                      SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
                          value: yuzde / 100,
                          backgroundColor: kenarlik,
                          color: yuzde == 100 ? basari : birincil,
                          strokeWidth: 3.5,
                        ),
                      ),
                      Text(
                        '%$yuzde',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: metinBirincil,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 8),
                  Icon(
                    _genisletildi ? Icons.expand_less : Icons.expand_more,
                    color: metinIkincil,
                  ),
                ],
              ),
            ),
          ),

          // AKORDİYON İÇİ (Alt Hareketler Listesi)
          if (_genisletildi) ...[
            Divider(height: 1, color: kenarlik),
            if (hareketler.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Bu rutinde henüz bir görev eklenmemiş.',
                  style: TextStyle(color: metinIkincil, fontSize: 13),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: hareketler.length,
                separatorBuilder: (_, _) => Divider(height: 1, color: kenarlik.withValues(alpha: 0.5)),
                itemBuilder: (context, index) {
                  final hareket = hareketler[index];
                  final yapildiMi = hareket.bugunTamamlayanUyeIdleri.contains(widget.mevcutKullaniciId);

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        // Numara veya Tik
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: yapildiMi ? basari.withValues(alpha: 0.16) : yukseltilmis,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: yapildiMi ? basari.withValues(alpha: 0.4) : kenarlik,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: yapildiMi
                              ? Icon(Icons.check, size: 17, color: basari)
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                    color: metinBirincil,
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
                                  color: yapildiMi ? metinIkincil : metinBirincil,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  if (hareket.hedefDeger != null) ...[
                                    Text(
                                      hareket.tur == 'sureli'
                                          ? '${hareket.hedefDeger} Sn'
                                          : '${hareket.hedefDeger} Tekrar',
                                      style: TextStyle(fontSize: 11, color: metinIkincil),
                                    ),
                                    Text(' • ', style: TextStyle(color: metinIkincil)),
                                  ],
                                  Text(
                                    '+${hareket.puan} Puan',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: birincil,
                                    ),
                                  ),
                                  if (hareket.nesneGerektirirMi && hareket.beklenenNesneAdi != null) ...[
                                    Text(' • ', style: TextStyle(color: metinIkincil)),
                                    Text(
                                      '📦 ${hareket.beklenenNesneAdi}',
                                      style: TextStyle(fontSize: 11, color: ikincil, fontWeight: FontWeight.w500),
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
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: basari.withValues(alpha: 0.14),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: basari.withValues(alpha: 0.3)),
                            ),
                            child: Text(
                              'Tamam ✅',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: basari,
                              ),
                            ),
                          )
                        else if (hareket.kanitZorunluMu)
                          ElevatedButton.icon(
                            onPressed: () => widget.onKanitlaTiklandi(hareket),
                            icon: const Icon(Icons.camera_alt, size: 14),
                            label: const Text('Kanıtla'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: birincil,
                              foregroundColor: birincilMetin,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                          )
                        else
                          IconButton(
                            icon: Icon(Icons.radio_button_unchecked, color: birincil),
                            onPressed: () => widget.onHizliTikTiklandi(hareket),
                          ),
                      ],
                    ),
                  );
                },
              ),

            // DETAYLARI GÖR VE MERKEZE GİT BUTONU
            Divider(height: 1, color: kenarlik),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: TextButton.icon(
                onPressed: widget.onDetayaGitTiklandi,
                icon: Icon(Icons.hub_outlined, size: 16, color: birincil),
                label: Text(
                  'Rutin Merkezine Git (Sohbet, Kanıtlar, Liderlik) ➔',
                  style: TextStyle(color: birincil, fontWeight: FontWeight.bold, fontSize: 12.5),
                ),
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
