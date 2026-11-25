// lib/ozellikler/toplu_rutinler/sunum/kontrolculer/kanit_kamera_kontrolcusu.dart

import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../cekirdek/hatalar/merkezi_kaydedici.dart';
import '../../alan/grup_kanit_modeli.dart';
import '../../alan/kanit_jesti.dart';
import '../../alan/rutin_hareketi_modeli.dart';
import '../../alan/toplu_rutin_modeli.dart';
import '../../veri/firestore_grup_servisi.dart';
import '../../veri/supabase_depolama_servisi.dart';
import '../../veri/yapay_zeka_dogrulama_servisi.dart';
import 'kullanici_profil_kontrolcusu.dart';

enum KanitAsamasi {
  hazirlaniyor,
  hazir,
  fotografCekildi,
  yapayZekaInceliyor,
  bulutaYukleniyor,
  basarili,
  hata,
}

class KanitKameraDurumu {
  final KanitAsamasi asama;
  final KanitJesti? secilenJest;
  final bool kurtarmaJestiAktifMi; // "Nesne Yanımda Değil" seçildi mi?
  final String? hataMesaji;
  final String? basariMesaji;
  final double? guvenSkoru;

  const KanitKameraDurumu({
    this.asama = KanitAsamasi.hazirlaniyor,
    this.secilenJest,
    this.kurtarmaJestiAktifMi = false,
    this.hataMesaji,
    this.basariMesaji,
    this.guvenSkoru,
  });

  KanitKameraDurumu kopyala({
    KanitAsamasi? asama,
    KanitJesti? secilenJest,
    bool? kurtarmaJestiAktifMi,
    String? hataMesaji,
    String? basariMesaji,
    double? guvenSkoru,
  }) {
    return KanitKameraDurumu(
      asama: asama ?? this.asama,
      secilenJest: secilenJest ?? this.secilenJest,
      kurtarmaJestiAktifMi: kurtarmaJestiAktifMi ?? this.kurtarmaJestiAktifMi,
      hataMesaji: hataMesaji,
      basariMesaji: basariMesaji,
      guvenSkoru: guvenSkoru ?? this.guvenSkoru,
    );
  }
}

final kanitKameraKontrolcusuSaglayici =
    NotifierProvider<KanitKameraKontrolcusu, KanitKameraDurumu>(
  KanitKameraKontrolcusu.new,
);

/// Şimşek hızında fotoğraf çekimi, nesne/jest doğrulaması ve paralel bulut yüklemesini yöneten kontrolcü.
class KanitKameraKontrolcusu extends Notifier<KanitKameraDurumu> {
  CameraController? kameraKontrolcusu;
  final YapayZekaDogrulamaServisi _aiServisi = YapayZekaDogrulamaServisi();
  final SupabaseDepolamaServisi _depolamaServisi = SupabaseDepolamaServisi();

  @override
  KanitKameraDurumu build() {
    ref.onDispose(() {
      kameraKontrolcusu?.dispose();
    });
    return const KanitKameraDurumu();
  }

  FirestoreGrupServisi get _grupServisi => ref.read(firestoreGrupServisiSaglayici);

  /// Kamerayı ve rastgele dinamik jesti başlatır.
  Future<void> kameraVePozBaslat({bool onKameraTercih = true}) async {
    state = state.kopyala(asama: KanitAsamasi.hazirlaniyor);

    try {
      final secilenJest = JestHavuzu.rastgeleJestSec();
      final kameralar = await availableCameras();
      if (kameralar.isEmpty) {
        state = state.kopyala(
          asama: KanitAsamasi.hata,
          hataMesaji: 'Cihazda kullanılabilir kamera bulunamadı.',
        );
        return;
      }

      CameraDescription secilenKamera;
      if (onKameraTercih) {
        secilenKamera = kameralar.firstWhere(
          (k) => k.lensDirection == CameraLensDirection.front,
          orElse: () => kameralar.first,
        );
      } else {
        secilenKamera = kameralar.firstWhere(
          (k) => k.lensDirection == CameraLensDirection.back,
          orElse: () => kameralar.first,
        );
      }

      kameraKontrolcusu = CameraController(
        secilenKamera,
        ResolutionPreset.medium, // Hız için medium (optimal 720p/50KB)
        enableAudio: false,
      );

      await kameraKontrolcusu!.initialize();

      state = state.kopyala(
        asama: KanitAsamasi.hazir,
        secilenJest: secilenJest,
        kurtarmaJestiAktifMi: false,
      );
    } catch (hata, yiginIzi) {
      MerkeziKaydedici.hataYaz('Kamera başlatma hatası', hata: hata, yiginIzi: yiginIzi);
      state = state.kopyala(
        asama: KanitAsamasi.hata,
        hataMesaji: 'Kamera açılamadı. Lütfen kamera izinlerini kontrol edin.',
      );
    }
  }

  /// Kullanıcı "Nesne Yanımda Değil / Çekemiyorum" butonuna bastığında çağrılır.
  void kurtarmaJestineGec() {
    state = state.kopyala(
      kurtarmaJestiAktifMi: true,
      secilenJest: state.secilenJest ?? JestHavuzu.rastgeleJestSec(),
    );
  }

  /// Fotoğrafı çeker, paralel olarak Gemini Flash'a ve Supabase'e fırlatır.
  Future<bool> fotografiCekVeDogrula({
    required TopluRutinModeli rutin,
    required RutinHareketiModeli hareket,
  }) async {
    if (kameraKontrolcusu == null || !kameraKontrolcusu!.value.isInitialized) {
      state = state.kopyala(
        asama: KanitAsamasi.hata,
        hataMesaji: 'Kamera henüz hazır değil.',
      );
      return false;
    }

    try {
      // 1. Canlı kameradan fotoğrafı çek
      state = state.kopyala(asama: KanitAsamasi.fotografCekildi);
      final xFile = await kameraKontrolcusu!.takePicture();
      final fotoBaytlari = await xFile.readAsBytes();

      state = state.kopyala(asama: KanitAsamasi.yapayZekaInceliyor);

      final profil = ref.read(aktifKullaniciProfiliSaglayici).value;
      final kullaniciAdi = profil?.kullaniciAdi ?? 'Kullanıcı';
      final kullaniciId = await _grupServisi.mevcutKullaniciKimligiAl();

      final jest = state.secilenJest ?? JestHavuzu.rastgeleJestSec();
      final bool kurtarmaMi = state.kurtarmaJestiAktifMi;

      // 2. PARALEL ÇALIŞMA (Future.wait): Gemini Flash Kontrolü + Supabase Yüklemesi
      final sonuclar = await Future.wait([
        _aiServisi.fotografiDenetle(
          fotoBaytlari: fotoBaytlari,
          rutinBasligi: rutin.baslik,
          gorevBasligi: hareket.baslik,
          beklenenNesne: hareket.beklenenNesneAdi,
          istenenJest: '${jest.emoji} ${jest.baslik}',
          kurtarmaJestiMi: kurtarmaMi,
        ),
        _depolamaServisi.kanitFotografiYukle(
          fotoBaytlari: fotoBaytlari,
          grupId: rutin.id,
          kullaniciId: kullaniciId,
        ),
      ]);

      final aiSonucu = sonuclar[0] as YapayZekaDogrulamaSonucu;
      final fotoUrl = sonuclar[1] as String;

      // Eğer açık hile varsa (tavan, siyah ekran vb.) ve fallback değilse reddet
      if (!aiSonucu.onaylandiMi && !aiSonucu.sosyalFallbackMi) {
        state = state.kopyala(
          asama: KanitAsamasi.hata,
          hataMesaji: aiSonucu.aciklama,
        );
        return false;
      }

      // 3. Kanıt damgasını belirle
      String damga;
      String kanitTuru;
      if (kurtarmaMi) {
        damga = '🎯 ${jest.emoji} ${jest.baslik} [Jest İle Onaylandı]';
        kanitTuru = 'kurtarma_jesti';
      } else if (hareket.nesneGerektirirMi && hareket.beklenenNesneAdi != null) {
        damga = '🎯 ${hareket.beklenenNesneAdi} [Doğal Nesne Onaylı]';
        kanitTuru = 'nesne';
      } else {
        damga = '🎯 ${jest.emoji} ${jest.baslik} [Canlı Jest Onaylı]';
        kanitTuru = 'jest';
      }

      if (aiSonucu.sosyalFallbackMi) {
        damga += ' (Sosyal Onay)';
        kanitTuru = 'sosyal_fallback';
      }

      // 4. Firestore veritabanına ve sohbete başarı kartı olarak kaydet
      final kanitModeli = GrupKanitModeli(
        id: '',
        grupId: rutin.id,
        rutinId: rutin.id,
        rutinBasligi: '${rutin.baslik} - ${hareket.baslik}',
        kullaniciId: kullaniciId,
        kullaniciAdi: kullaniciAdi,
        fotoUrl: fotoUrl,
        istenenDinamikPoz: '${jest.emoji} ${jest.baslik}',
        kanitTuru: kanitTuru,
        kanitDamgasi: damga,
        aiOnaylandiMi: true,
        aiGuvenSkoru: aiSonucu.guvenSkoru,
        aiGeriBildirimi: aiSonucu.aciklama,
        tarih: DateTime.now(),
      );

      await _grupServisi.kanitKaydetVeSohbeteAt(
        kanit: kanitModeli,
        kazanilanPuan: hareket.puan,
      );

      // Rutindeki alt hareketi tamamla olarak işaretle
      await _grupServisi.hareketTamamla(
        rutinId: rutin.id,
        hareketId: hareket.id,
        kazanilanPuan: hareket.puan,
        kullaniciAdi: kullaniciAdi,
      );

      state = state.kopyala(
        asama: KanitAsamasi.basarili,
        basariMesaji: aiSonucu.aciklama,
        guvenSkoru: aiSonucu.guvenSkoru,
      );
      return true;
    } catch (hata, yiginIzi) {
      MerkeziKaydedici.hataYaz('Kanıt doğrulama akışı hatası', hata: hata, yiginIzi: yiginIzi);
      state = state.kopyala(
        asama: KanitAsamasi.hata,
        hataMesaji: 'Fotoğraf işlenirken bir sorun oluştu. Lütfen tekrar deneyin.',
      );
      return false;
    }
  }
}
