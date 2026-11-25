// lib/ozellikler/toplu_rutinler/sunum/ekranlar/kanit_kamera_ekrani.dart

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../alan/grup_rutin_modeli.dart';
import '../../alan/rutin_hareketi_modeli.dart';
import '../../alan/toplu_rutin_modeli.dart';
import '../kontrolculer/kanit_kamera_kontrolcusu.dart';

/// Şimşek hızında canlı kamera, nesne/jest vizörü ve kurtarma butonlu kanıt ekranı.
class KanitKameraEkrani extends ConsumerStatefulWidget {
  final TopluRutinModeli rutin;
  final RutinHareketiModeli hareket;

  const KanitKameraEkrani({
    super.key,
    required this.rutin,
    required this.hareket,
  });

  /// Geriye dönük uyumluluk yapıcı metodu
  factory KanitKameraEkrani.eskiUyumlu({
    Key? key,
    required GrupRutinModeli rutin,
    required String kullaniciAdi,
  }) {
    final donusturulmusRutin = TopluRutinModeli(
      id: rutin.id,
      baslik: rutin.baslik,
      aciklama: rutin.aciklama,
      kategori: rutin.kategori,
      davetKodu: '',
      kurucuKullaniciId: '',
      olusturulmaTarihi: rutin.olusturmaTarihi,
    );
    final varsayilanHareket = RutinHareketiModeli(
      id: 'h_${rutin.id}',
      baslik: rutin.baslik,
      puan: rutin.puanDegeri,
    );
    return KanitKameraEkrani(key: key, rutin: donusturulmusRutin, hareket: varsayilanHareket);
  }

  @override
  ConsumerState<KanitKameraEkrani> createState() => _KanitKameraEkraniState();
}

class _KanitKameraEkraniState extends ConsumerState<KanitKameraEkrani> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(kanitKameraKontrolcusuSaglayici.notifier).kameraVePozBaslat();
    });
  }

  @override
  Widget build(BuildContext context) {
    final durum = ref.watch(kanitKameraKontrolcusuSaglayici);
    final kontrolcu = ref.read(kanitKameraKontrolcusuSaglayici.notifier);

    final bool nesneliMi = widget.hareket.nesneGerektirirMi && !durum.kurtarmaJestiAktifMi;
    final jest = durum.secilenJest;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('${widget.hareket.baslik} Kanıtı'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // 1. Canlı Kamera Vizörü
          if (kontrolcu.kameraKontrolcusu != null && kontrolcu.kameraKontrolcusu!.value.isInitialized)
            Center(
              child: CameraPreview(kontrolcu.kameraKontrolcusu!),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),

          // 2. Üst Görev Talimatı Rozeti
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: nesneliMi ? Colors.purpleAccent : Colors.amber,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(
                        nesneliMi ? '📦' : (jest?.emoji ?? '✌️'),
                        style: const TextStyle(fontSize: 28),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              nesneliMi
                                  ? 'DOĞAL NESNE GÖREVİ'
                                  : (durum.kurtarmaJestiAktifMi ? 'KURTARMA POZU' : 'CANLI JEST GÖREVİ'),
                              style: TextStyle(
                                color: nesneliMi ? Colors.purpleAccent : Colors.amber,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                            Text(
                              nesneliMi
                                  ? 'Fotoğrafta "${widget.hareket.beklenenNesneAdi}" göster'
                                  : (jest?.talimat ?? 'Kameraya zafer işareti yap'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Kurtarma Butonu: "Nesne Yanımda Değil"
                if (nesneliMi) ...[
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => kontrolcu.kurtarmaJestineGec(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white24,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.swap_horiz, color: Colors.white, size: 16),
                          SizedBox(width: 6),
                          Text(
                            'Nesne Yanımda Değil / Çekemiyorum ➔ Canlı Poza Geç',
                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // 3. Alt Deklanşör & Durum Bildirimleri
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // İnceleme / Yükleme / Hata Mesajları
                if (durum.asama == KanitAsamasi.yapayZekaInceliyor ||
                    durum.asama == KanitAsamasi.bulutaYukleniyor)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade900.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        ),
                        SizedBox(width: 12),
                        Text(
                          '⚡ Şimşek hızında doğrulanıyor...',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  )
                else if (durum.asama == KanitAsamasi.hata && durum.hataMesaji != null)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.red.shade900.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      durum.hataMesaji!,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),

                const SizedBox(height: 10),

                // Büyük Deklanşör Butonu
                GestureDetector(
                  onTap: (durum.asama == KanitAsamasi.yapayZekaInceliyor ||
                          durum.asama == KanitAsamasi.bulutaYukleniyor)
                      ? null
                      : () async {
                          final nav = Navigator.of(context);
                          final messenger = ScaffoldMessenger.of(context);
                          final basarili = await kontrolcu.fotografiCekVeDogrula(
                            rutin: widget.rutin,
                            hareket: widget.hareket,
                          );
                          if (!mounted) return;
                          if (basarili) {
                            messenger.showSnackBar(
                              SnackBar(
                                content: Text('Tebrikler! ${widget.hareket.baslik} doğrulandı 🎉 (+${widget.hareket.puan} Puan)'),
                                backgroundColor: Colors.teal.shade700,
                              ),
                            );
                            nav.pop();
                          }
                        },
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      color: Colors.teal,
                    ),
                    child: const Icon(Icons.camera_alt, color: Colors.white, size: 36),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
