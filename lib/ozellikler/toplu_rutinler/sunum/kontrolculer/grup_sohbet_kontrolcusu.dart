// lib/ozellikler/toplu_rutinler/sunum/kontrolculer/grup_sohbet_kontrolcusu.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../alan/grup_mesaj_modeli.dart';
import '../../veri/firestore_grup_servisi.dart';
import 'kullanici_profil_kontrolcusu.dart';

/// Belirli bir rutinin canlı mesaj akışını sağlayan StreamProvider (Offline Persistence açık)
final rutinMesajlariSaglayici =
    StreamProvider.family<List<GrupMesajModeli>, String>((ref, rutinId) {
  final servis = ref.watch(firestoreGrupServisiSaglayici);
  return servis.mesajlariDinle(rutinId);
});

final grupMesajlariSaglayici = rutinMesajlariSaglayici; // Geriye uyumluluk

final grupSohbetKontrolcusuSaglayici = Provider<GrupSohbetKontrolcusu>((ref) {
  return GrupSohbetKontrolcusu(ref);
});

/// Sohbet işlemlerini (mesaj atma, mesaj sabitleme, emoji tepkisi verme) yöneten kontrolcü sınıfı.
class GrupSohbetKontrolcusu {
  final Ref _ref;

  GrupSohbetKontrolcusu(this._ref);

  FirestoreGrupServisi get _servis => _ref.read(firestoreGrupServisiSaglayici);

  /// Sohbete yeni bir metin mesajı gönderir.
  Future<void> mesajGonder({
    String? rutinId,
    String? grupId,
    required String metin,
    String? gonderenAdi,
    String? gonderenId,
    String? tur,
  }) async {
    final hedefId = (rutinId != null && rutinId.isNotEmpty) ? rutinId : (grupId ?? '');
    final temizMetin = metin.trim();
    if (temizMetin.isEmpty || hedefId.isEmpty) return;

    final profil = _ref.read(aktifKullaniciProfiliSaglayici).value;
    final ad = gonderenAdi ?? profil?.kullaniciAdi ?? 'Kullanıcı';

    await _servis.mesajGonder(
      rutinId: hedefId,
      metin: temizMetin,
      gonderenAdi: ad,
    );
  }

  /// Mesaja emoji tepkisi verir.
  Future<void> tepkiVer({
    required String grupId,
    required String mesajId,
    required String emoji,
  }) async {
    final uid = await _servis.mevcutKullaniciKimligiAl();
    await _servis.mesajaTepkiVer(
      grupId: grupId,
      mesajId: mesajId,
      emoji: emoji,
      kullaniciId: uid,
    );
  }

  /// Önemli bir mesajı sohbetin tepesine sabitler (Pin 📌).
  Future<void> mesajSabitle({
    required String rutinId,
    required GrupMesajModeli mesaj,
  }) async {
    await _servis.mesajSabitle(
      rutinId: rutinId,
      mesajId: mesaj.id,
      metin: mesaj.metin,
      gonderenAdi: mesaj.gonderenAdi,
    );
  }

  /// Sabitlenmiş mesajı kaldırır (Unpin).
  Future<void> mesajSabitlemeKaldir(String rutinId) async {
    await _servis.mesajSabitlemeKaldir(rutinId);
  }
}
