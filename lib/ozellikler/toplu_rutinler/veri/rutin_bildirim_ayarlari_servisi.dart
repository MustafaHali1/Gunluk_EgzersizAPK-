// lib/ozellikler/toplu_rutinler/veri/rutin_bildirim_ayarlari_servisi.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final rutinBildirimAyarlariServisiSaglayici = Provider<RutinBildirimAyarlariServisi>((ref) {
  return RutinBildirimAyarlariServisi();
});

/// Rutin bazlı bildirim sessize alma sürelerini SharedPreferences üzerinden yönetir.
class RutinBildirimAyarlariServisi {
  static const String _onEk = 'rutin_sessiz_bitis_';
  static const String _suresizOnEk = 'rutin_suresiz_sessiz_';

  /// Rutini belirli bir tarihe kadar veya süresiz sessize alır.
  /// [bitisTarihi] null ise süresiz sessize alınmıştır.
  Future<void> sessizeAl(String rutinId, DateTime? bitisTarihi) async {
    final tercihler = await SharedPreferences.getInstance();
    if (bitisTarihi == null) {
      await tercihler.setBool('$_suresizOnEk$rutinId', true);
      await tercihler.remove('$_onEk$rutinId');
    } else {
      await tercihler.remove('$_suresizOnEk$rutinId');
      await tercihler.setString('$_onEk$rutinId', bitisTarihi.toIso8601String());
    }
  }

  /// Rutinin sessiz durumunu kaldırır (Bildirimleri tekrar açar).
  Future<void> sessizdenCikar(String rutinId) async {
    final tercihler = await SharedPreferences.getInstance();
    await tercihler.remove('$_suresizOnEk$rutinId');
    await tercihler.remove('$_onEk$rutinId');
  }

  /// Rutinin şu an sessizde olup olmadığını ve açıklamasını döner.
  Future<(bool sessizdeMi, String aciklama)> sessizDurumunuGetir(String rutinId) async {
    final tercihler = await SharedPreferences.getInstance();

    final suresiz = tercihler.getBool('$_suresizOnEk$rutinId') ?? false;
    if (suresiz) {
      return (true, 'Sessizde (Her zaman)');
    }

    final bitisStr = tercihler.getString('$_onEk$rutinId');
    if (bitisStr == null) {
      return (false, 'Açık (Tüm bildirimler iletiliyor)');
    }

    final bitis = DateTime.tryParse(bitisStr);
    if (bitis == null || DateTime.now().isAfter(bitis)) {
      // Süresi dolmuş, temizle
      await sessizdenCikar(rutinId);
      return (false, 'Açık (Tüm bildirimler iletiliyor)');
    }

    final fark = bitis.difference(DateTime.now());
    if (fark.inHours < 24) {
      final saat = bitis.hour.toString().padLeft(2, '0');
      final dakika = bitis.minute.toString().padLeft(2, '0');
      return (true, 'Sessizde (Bugün $saat:$dakika)');
    } else {
      final gun = bitis.day.toString().padLeft(2, '0');
      final ay = bitis.month.toString().padLeft(2, '0');
      return (true, 'Sessizde ($gun.$ay tarihine kadar)');
    }
  }
}
