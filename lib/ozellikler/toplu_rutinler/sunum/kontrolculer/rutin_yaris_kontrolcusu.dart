// lib/ozellikler/toplu_rutinler/sunum/kontrolculer/rutin_yaris_kontrolcusu.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../veri/firestore_grup_servisi.dart';
import 'kullanici_profil_kontrolcusu.dart';

final rutinYarisKontrolcusuSaglayici = Provider<RutinYarisKontrolcusu>((ref) {
  return RutinYarisKontrolcusu(ref);
});

/// Rutin içi süreli yarışları (7, 10, 14, 30 gün) yöneten kontrolcü.
class RutinYarisKontrolcusu {
  final Ref _ref;

  RutinYarisKontrolcusu(this._ref);

  FirestoreGrupServisi get _servis => _ref.read(firestoreGrupServisiSaglayici);

  /// Rutin içinde yeni bir yarış başlatır.
  Future<void> yarisBaslat({
    required String rutinId,
    required String baslik,
    required int gunSayisi,
    required int hedefPuan,
  }) async {
    final profil = _ref.read(aktifKullaniciProfiliSaglayici).value;
    final baslatanAdi = profil?.kullaniciAdi ?? 'Kullanıcı';

    await _servis.yarisBaslat(
      rutinId: rutinId,
      baslik: baslik,
      gunSayisi: gunSayisi,
      hedefPuan: hedefPuan,
      baslatanKullaniciAdi: baslatanAdi,
    );
  }

  /// Kalan süreyi insan dostu metin olarak hesaplar (Örn: "3 Gün 4 Saat").
  static String kalanSureMetni(Map<String, dynamic>? yarisVerisi) {
    if (yarisVerisi == null) return '';
    final bitisStr = yarisVerisi['bitisTarihi'] as String?;
    if (bitisStr == null) return '';

    final bitis = DateTime.tryParse(bitisStr);
    if (bitis == null) return '';

    final simdi = DateTime.now();
    final fark = bitis.difference(simdi);

    if (fark.isNegative) return 'Yarış Tamamlandı 🏁';

    final gun = fark.inDays;
    final saat = fark.inHours % 24;

    if (gun > 0) {
      return '$gun Gün $saat Saat Kaldı';
    } else {
      final dakika = fark.inMinutes % 60;
      return '$saat Saat $dakika Dk Kaldı';
    }
  }
}
