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
  Future<bool> kullaniciAdiBelirle(String yeniAd) async {
    state = const AsyncValue.loading();
    try {
      final musaitMi = await _servis.kullaniciAdiMusaitMi(yeniAd);
      if (!musaitMi) {
        state = AsyncValue.error('Bu kullanıcı adı maalesef dolu, başka bir ad deneyin.', StackTrace.current);
        return false;
      }

      final yeniProfil = await _servis.profilKaydetVeyaGuncelle(yeniAd);
      state = AsyncValue.data(yeniProfil);
      return true;
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      return false;
    }
  }

  /// Profil bilgilerini yeniler.
  Future<void> profiliYenile() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _servis.aktifProfiliGetir());
  }
}
