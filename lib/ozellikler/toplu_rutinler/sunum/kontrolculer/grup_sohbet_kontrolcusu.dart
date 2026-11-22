// lib/ozellikler/toplu_rutinler/sunum/kontrolculer/grup_sohbet_kontrolcusu.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../alan/grup_mesaj_modeli.dart';
import '../../veri/firestore_grup_servisi.dart';
import 'grup_kontrolcusu.dart';

/// Belirli bir grubun canlı mesaj akışını sağlayan StreamProvider
final grupMesajlariSaglayici =
    StreamProvider.family<List<GrupMesajModeli>, String>((ref, grupId) {
  final servis = ref.watch(firestoreGrupServisiSaglayici);
  return servis.grupMesajlariniDinle(grupId);
});

/// Grup sohbet işlemlerini (mesaj atma, emoji tepkisi verme) yöneten sınıf.
class GrupSohbetKontrolcusu {
  final Ref _ref;

  GrupSohbetKontrolcusu(this._ref);

  FirestoreGrupServisi get _servis => _ref.read(firestoreGrupServisiSaglayici);

  /// Sohbete yeni metin mesajı gönderir.
  Future<void> mesajGonder({
    required String grupId,
    required String metin,
    required String gonderenAdi,
  }) async {
    if (metin.trim().isEmpty) return;

    final kullaniciId = await _servis.mevcutKullaniciKimligiAl();
    await _servis.mesajGonder(
      grupId: grupId,
      metin: metin.trim(),
      gonderenId: kullaniciId,
      gonderenAdi: gonderenAdi,
      tur: 'metin',
    );
  }

  /// Mesaja veya kanıt kartına emoji tepkisi (🔥, 👏, 💪) bırakır.
  Future<void> tepkiVer({
    required String grupId,
    required String mesajId,
    required String emoji,
  }) async {
    final kullaniciId = await _servis.mevcutKullaniciKimligiAl();
    await _servis.mesajaTepkiVer(
      grupId: grupId,
      mesajId: mesajId,
      emoji: emoji,
      kullaniciId: kullaniciId,
    );
  }
}

final grupSohbetKontrolcusuSaglayici = Provider<GrupSohbetKontrolcusu>((ref) {
  return GrupSohbetKontrolcusu(ref);
});
