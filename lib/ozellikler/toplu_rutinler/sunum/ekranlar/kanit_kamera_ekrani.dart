// lib/ozellikler/toplu_rutinler/sunum/ekranlar/kanit_kamera_ekrani.dart

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../alan/grup_rutin_modeli.dart';
import '../kontrolculer/kanit_kamera_kontrolcusu.dart';

/// Dinamik jestli, hile korumalı canlı kamera ve yapay zeka kanıt ekranı.
/// İnce Ekran kuralına uygundur; tüm iş mantığını KanitKameraKontrolcusu yürütür.
class KanitKameraEkrani extends ConsumerStatefulWidget {
  final GrupRutinModeli rutin;
  final String kullaniciAdi;

  const KanitKameraEkrani({
    super.key,
    required this.rutin,
    required this.kullaniciAdi,
  });

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

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('${widget.rutin.baslik} Kanıtı'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Stack(
        children: [
          // 1. Canlı Kamera Vizörü
          if (kontrolcu.kameraKontrolcusu != null &&
              kontrolcu.kameraKontrolcusu!.value.isInitialized)
            Center(
              child: CameraPreview(kontrolcu.kameraKontrolcusu!),
            )
          else
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),

          // 2. Üst Poz Talimatı Rozeti (Hile Önleme)
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.75),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.amber, width: 2),
              ),
              child: Column(
                children: [
                  const Text(
                    '⚡ ANLIK GÖREV (HİLE ÖNLEME)',
                    style: TextStyle(
                      color: Colors.amber,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    durum.istenenPoz.isNotEmpty
                        ? durum.istenenPoz
                        : 'Görev belirleniyor...',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 3. Alt Deklanşör Butonu
          if (durum.asama == KanitAsamasi.hazir)
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: FloatingActionButton.large(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  onPressed: () async {
                    final basarili = await kontrolcu.fotografiCekVeDogrula(
                      rutin: widget.rutin,
                      kullaniciAdi: widget.kullaniciAdi,
                    );
                    if (basarili && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🎉 Yapay zeka onayladı! Kanıt sohbete atıldı.'),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Icon(Icons.camera_alt, size: 36),
                ),
              ),
            ),

          // 4. Analiz / Yükleme Sırasında Karartma ve Durum
          if (durum.asama == KanitAsamasi.yapayZekaInceliyor ||
              durum.asama == KanitAsamasi.bulutaYukleniyor ||
              durum.asama == KanitAsamasi.fotografCekildi)
            Container(
              color: Colors.black87,
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(color: Colors.amber),
                    const SizedBox(height: 20),
                    Text(
                      durum.asama == KanitAsamasi.yapayZekaInceliyor
                          ? '🤖 Yapay Zeka Eylemi ve Pozu İnceliyor...'
                          : '☁️ Kanıt Supabase Bulutuna Yükleniyor...',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
            ),

          // 5. Hata / Uyarı Durumu
          if (durum.asama == KanitAsamasi.hata && durum.hataMesaji != null)
            Container(
              color: Colors.black.withValues(alpha: 0.85),
              padding: const EdgeInsets.all(24),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.cancel, color: Colors.red, size: 60),
                    const SizedBox(height: 16),
                    const Text(
                      'Doğrulama Başarısız Oldu',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      durum.hataMesaji!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        foregroundColor: Colors.black,
                      ),
                      onPressed: kontrolcu.tekrarDene,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tekrar Çek'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
