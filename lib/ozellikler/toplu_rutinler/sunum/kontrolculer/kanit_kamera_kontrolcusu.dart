// lib/ozellikler/toplu_rutinler/sunum/kontrolculer/kanit_kamera_kontrolcusu.dart

import 'dart:math';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../cekirdek/hatalar/merkezi_kaydedici.dart';
import '../../alan/grup_kanit_modeli.dart';
import '../../alan/grup_rutin_modeli.dart';
import '../../veri/firestore_grup_servisi.dart';
import '../../veri/supabase_depolama_servisi.dart';
import '../../veri/yapay_zeka_dogrulama_servisi.dart';
import 'grup_kontrolcusu.dart';

/// Kamera ve yapay zeka kanıt sürecinin anlık durumları.
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
  final String istenenPoz;
  final String? hataMesaji;
  final String? basariMesaji;
  final double? guvenSkoru;

  const KanitKameraDurumu({
    this.asama = KanitAsamasi.hazirlaniyor,
    this.istenenPoz = '',
    this.hataMesaji,
    this.basariMesaji,
    this.guvenSkoru,
  });

  KanitKameraDurumu kopyala({
    KanitAsamasi? asama,
    String? istenenPoz,
    String? hataMesaji,
    String? basariMesaji,
    double? guvenSkoru,
  }) {
    return KanitKameraDurumu(
      asama: asama ?? this.asama,
      istenenPoz: istenenPoz ?? this.istenenPoz,
      hataMesaji: hataMesaji,
      basariMesaji: basariMesaji,
      guvenSkoru: guvenSkoru ?? this.guvenSkoru,
    );
  }
}

/// Anlık hile önleyici görev havuzu (Kullanıcı butona bastığı anda rastgele seçilir)
const List<String> _dinamikPozHavuzu = [
  '✌️ İki parmağınla zafer işareti yap',
  '👍 Başparmağını havaya kaldır (Onay pozu)',
  '🖐️ Açık avuç içini kameraya doğru tut',
  '🤟 Üç parmağını (Rock işareti) göster',
  '☝️ İşaret parmağını yukarı kaldır',
];

/// Kamera ve AI doğrulama sürecini yöneten Riverpod Notifier kontrolcü sınıfı.
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

  /// Kamerayı ve rastgele dinamik pozu başlatır.
  Future<void> kameraVePozBaslat() async {
    state = state.kopyala(asama: KanitAsamasi.hazirlaniyor);

    try {
      // Rastgele bir poz görevi seç
      final rastgeleIndex = Random().nextInt(_dinamikPozHavuzu.length);
      final secilenPoz = _dinamikPozHavuzu[rastgeleIndex];

      final kameralar = await availableCameras();
      if (kameralar.isEmpty) {
        state = state.kopyala(
          asama: KanitAsamasi.hata,
          hataMesaji: 'Cihazda kullanılabilir kamera bulunamadı.',
        );
        return;
      }

      // Varsa ön kamerayı, yoksa arka kamerayı seç
      final onKamera = kameralar.firstWhere(
        (kamera) => kamera.lensDirection == CameraLensDirection.front,
        orElse: () => kameralar.first,
      );

      kameraKontrolcusu = CameraController(
        onKamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await kameraKontrolcusu!.initialize();

      state = state.kopyala(
        asama: KanitAsamasi.hazir,
        istenenPoz: secilenPoz,
      );
    } catch (hata, yiginIzi) {
      MerkeziKaydedici.hataYaz('Kamera başlatma hatası', hata: hata, yiginIzi: yiginIzi);
      state = state.kopyala(
        asama: KanitAsamasi.hata,
        hataMesaji: 'Kamera açılamadı. Lütfen kamera izinlerini kontrol edin.',
      );
    }
  }

  /// Fotoğrafı çeker, yapay zekaya denetletir ve geçerse Supabase'e yükleyip Firestore'a işler.
  Future<bool> fotografiCekVeDogrula({
    required GrupRutinModeli rutin,
    required String kullaniciAdi,
  }) async {
    if (kameraKontrolcusu == null || !kameraKontrolcusu!.value.isInitialized) {
      state = state.kopyala(
        asama: KanitAsamasi.hata,
        hataMesaji: 'Kamera henüz hazır değil.',
      );
      return false;
    }

    try {
      // 1. Canlı kameradan çek
      state = state.kopyala(asama: KanitAsamasi.fotografCekildi);
      final xFile = await kameraKontrolcusu!.takePicture();
      final fotoBaytlari = await xFile.readAsBytes();

      // 2. Yapay zekaya (Gemini Vision) gönder
      state = state.kopyala(asama: KanitAsamasi.yapayZekaInceliyor);
      final aiSonucu = await _aiServisi.fotografiDenetle(
        fotoBaytlari: fotoBaytlari,
        rutinBasligi: rutin.baslik,
        istenenJest: state.istenenPoz,
      );

      if (!aiSonucu.onaylandiMi) {
        state = state.kopyala(
          asama: KanitAsamasi.hata,
          hataMesaji: aiSonucu.aciklama,
        );
        return false;
      }

      // 3. Supabase Storage'a yükle
      state = state.kopyala(asama: KanitAsamasi.bulutaYukleniyor);
      final kullaniciId = await _grupServisi.mevcutKullaniciKimligiAl();
      final fotoUrl = await _depolamaServisi.kanitFotografiYukle(
        fotoBaytlari: fotoBaytlari,
        grupId: rutin.grupId,
        kullaniciId: kullaniciId,
      );

      // 4. Firestore veritabanına ve sohbete başarı kartı olarak kaydet
      final kanitModeli = GrupKanitModeli(
        id: '',
        grupId: rutin.grupId,
        rutinId: rutin.id,
        rutinBasligi: rutin.baslik,
        kullaniciId: kullaniciId,
        kullaniciAdi: kullaniciAdi,
        fotoUrl: fotoUrl,
        istenenDinamikPoz: state.istenenPoz,
        aiOnaylandiMi: true,
        aiGuvenSkoru: aiSonucu.guvenSkoru,
        aiGeriBildirimi: aiSonucu.aciklama,
        tarih: DateTime.now(),
      );

      await _grupServisi.kanitKaydetVeSohbeteAt(
        kanit: kanitModeli,
        kazanilanPuan: rutin.puanDegeri,
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
        hataMesaji: 'Fotoğraf işlenirken veya doğrulanırken beklenmedik bir hata oluştu.',
      );
      return false;
    }
  }

  /// Süreci sıfırlar ve kamerayı yeniden denemeye hazırlar.
  void tekrarDene() {
    kameraVePozBaslat();
  }
}

final kanitKameraKontrolcusuSaglayici =
    NotifierProvider.autoDispose<KanitKameraKontrolcusu, KanitKameraDurumu>(
  KanitKameraKontrolcusu.new,
);
