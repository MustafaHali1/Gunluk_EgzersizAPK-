// lib/ozellikler/toplu_rutinler/sunum/kontrolculer/kullanici_profil_kontrolcusu.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../alan/kullanici_profili_modeli.dart';
import '../../veri/kullanici_profil_servisi.dart';

final aktifKullaniciProfiliSaglayici =
    AsyncNotifierProvider<KullaniciProfilKontrolcusu, KullaniciProfiliModeli?>(
  KullaniciProfilKontrolcusu.new,
);

/// Kullanıcının benzersiz @username ve profil durumunu yöneten Notifier.
class KullaniciProfilKontrolcusu extends AsyncNotifier<KullaniciProfiliModeli?> {
  KullaniciProfilServisi get _servis => ref.read(kullaniciProfilServisiSaglayici);

  @override
  Future<KullaniciProfiliModeli?> build() async {
    return await _servis.aktifProfiliGetir();
  }

  /// Yeni bir kullanıcı adı belirler ve kaydeder.
  Future<(bool basarili, String? hataMesaji)> kullaniciAdiBelirle(String yeniAd) async {
    final temizAd = yeniAd.trim().replaceAll('@', '');
    if (temizAd.length < 3) {
      return (false, 'Kullanıcı adı en az 3 karakter olmalıdır.');
    }

    final gecerliMi = RegExp(r'^[a-zA-Z0-9_çÇğĞıİöÖşŞüÜ]+$').hasMatch(temizAd);
    if (!gecerliMi) {
      return (false, 'Kullanıcı adında boşluk veya özel karakter olamaz.');
    }

    state = const AsyncValue.loading();
    try {
      final musaitMi = await _servis.kullaniciAdiMusaitMi(temizAd);
      if (!musaitMi) {
        state = AsyncValue.data(state.value);
        return (false, 'Bu kullanıcı adı (@$temizAd) zaten başka biri tarafından alınmış.');
      }

      final yeniProfil = await _servis.profilKaydetVeyaGuncelle(temizAd);
      state = AsyncValue.data(yeniProfil);
      return (true, null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return (false, 'Hata oluştu: $e');
    }
  }

  /// Profil bilgilerini yeniler.
  Future<void> profiliYenile() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _servis.aktifProfiliGetir());
  }
}
