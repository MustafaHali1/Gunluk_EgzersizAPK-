// lib/ozellikler/toplu_rutinler/sunum/kontrolculer/liderlik_rapor_kontrolcusu.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../alan/grup_uyesi_modeli.dart';
import 'grup_kontrolcusu.dart';

/// Belirli bir grubun üyelerini toplam puana göre azalan sıralamayla dinler.
final grupLiderlikSaglayici =
    StreamProvider.family<List<GrupUyesiModeli>, String>((ref, grupId) {
  final servis = ref.watch(firestoreGrupServisiSaglayici);
  return servis.grupUyeleriniDinle(grupId);
});

/// Grup üyelerinin başarı istatistiklerini ve sıralamasını hesaplayan kontrolcü sınıfı.
class LiderlikRaporKontrolcusu {
  /// Üyenin hedeflenen görevlere göre tahmini tamamlanma yüzdesini hesaplar (Örn: %85).
  static double yuzdelikOranHesapla({
    required int tamamlananGorevSayisi,
    required DateTime katilmaTarihi,
  }) {
    final gecenGunSayisi = DateTime.now().difference(katilmaTarihi).inDays + 1;
    if (gecenGunSayisi <= 0) return 100.0;

    // Günde en az 1 görev tamamlanması varsayımıyla oran hesaplanır
    final oran = (tamamlananGorevSayisi / gecenGunSayisi) * 100;
    if (oran > 100.0) return 100.0;
    if (oran < 0.0) return 0.0;
    return double.parse(oran.toStringAsFixed(1));
  }

  /// Podyum için ilk 3 dereceyi döner.
  static List<GrupUyesiModeli> ilkUcuGetir(List<GrupUyesiModeli> uyeler) {
    if (uyeler.length <= 3) return uyeler;
    return uyeler.sublist(0, 3);
  }
}
