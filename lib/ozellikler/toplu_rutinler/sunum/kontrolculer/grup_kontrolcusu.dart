// lib/ozellikler/toplu_rutinler/sunum/kontrolculer/grup_kontrolcusu.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../alan/grup_modeli.dart';
import '../../alan/grup_rutin_modeli.dart';
import '../../alan/grup_uyesi_modeli.dart';
import '../../alan/toplu_rutin_modeli.dart';
import '../../alan/rutin_hareketi_modeli.dart';
import '../../veri/firestore_grup_servisi.dart';
import 'kullanici_profil_kontrolcusu.dart';

export '../../veri/firestore_grup_servisi.dart' show firestoreGrupServisiSaglayici;

/// Aktif kullanıcının kimlik sağlayıcısı
final mevcutKullaniciIdSaglayici = FutureProvider<String>((ref) async {
  final servis = ref.watch(firestoreGrupServisiSaglayici);
  return await servis.mevcutKullaniciKimligiAl();
});

// ==========================================
// TOPLU RUTİN SAĞLAYICILARI (Rutin Bazlı Model)
// ==========================================

/// Kullanıcının dahil olduğu toplu rutinleri canlı dinleyen ana sağlayıcı
final kullaniciRutinleriSaglayici = StreamProvider<List<TopluRutinModeli>>((ref) {
  final servis = ref.watch(firestoreGrupServisiSaglayici);
  final kullaniciIdAsync = ref.watch(mevcutKullaniciIdSaglayici);

  return kullaniciIdAsync.when(
    data: (uid) => servis.kullaniciRutinleriniDinle(uid),
    loading: () => Stream.value(<TopluRutinModeli>[]),
    error: (_, _) => Stream.value(<TopluRutinModeli>[]),
  );
});

/// Ekranda seçili olan aktif toplu rutini tutan Notifier
class SeciliRutinKontrolcusu extends Notifier<TopluRutinModeli?> {
  @override
  TopluRutinModeli? build() => null;

  void sec(TopluRutinModeli? rutin) => state = rutin;

  void guncelle(TopluRutinModeli rutin) {
    state = rutin;
  }
}

final seciliTopluRutinSaglayici =
    NotifierProvider<SeciliRutinKontrolcusu, TopluRutinModeli?>(
  SeciliRutinKontrolcusu.new,
);

/// Seçili rutinin üyelerini ve puan sıralamasını canlı dinleyen sağlayıcı
final rutinUyeleriSaglayici = StreamProvider.family<List<GrupUyesiModeli>, String>((ref, rutinId) {
  final servis = ref.watch(firestoreGrupServisiSaglayici);
  return servis.uyeleriDinle(rutinId);
});

/// Toplu rutin işlemlerini yöneten ana kontrolcü sınıfı
final topluRutinKontrolcusuSaglayici = Provider<TopluRutinKontrolcusu>((ref) {
  return TopluRutinKontrolcusu(ref);
});

class TopluRutinKontrolcusu {
  final Ref _ref;

  TopluRutinKontrolcusu(this._ref);

  FirestoreGrupServisi get _servis => _ref.read(firestoreGrupServisiSaglayici);

  /// Yeni bir toplu rutin kurar ve seçili yapar.
  Future<TopluRutinModeli> rutinKur({
    required String baslik,
    required String aciklama,
    required String kategori,
    required List<RutinHareketiModeli> hareketler,
    List<String> hedefGunler = const ['1', '2', '3', '4', '5', '6', '7'],
  }) async {
    final profil = _ref.read(aktifKullaniciProfiliSaglayici).value;
    final kurucuAdi = profil?.kullaniciAdi ?? 'Kullanıcı';

    final yeniRutin = await _servis.rutinOlustur(
      baslik: baslik,
      aciklama: aciklama,
      kategori: kategori,
      hareketler: hareketler,
      kurucuAdi: kurucuAdi,
      hedefGunler: hedefGunler,
    );

    _ref.read(seciliTopluRutinSaglayici.notifier).sec(yeniRutin);
    return yeniRutin;
  }

  /// 6 haneli kod ile rutine katılır.
  Future<TopluRutinModeli?> kodaGoreKatil(String davetKodu) async {
    final profil = _ref.read(aktifKullaniciProfiliSaglayici).value;
    final kullaniciAdi = profil?.kullaniciAdi ?? 'Kullanıcı';

    final rutin = await _servis.kodaGoreRutineKatil(
      davetKodu: davetKodu,
      kullaniciAdi: kullaniciAdi,
    );

    if (rutin != null) {
      _ref.read(seciliTopluRutinSaglayici.notifier).sec(rutin);
    }
    return rutin;
  }

  /// Bir alt hareketi tamamlar.
  Future<void> hareketTamamla({
    required String rutinId,
    required String hareketId,
    required int puan,
  }) async {
    final profil = _ref.read(aktifKullaniciProfiliSaglayici).value;
    final kullaniciAdi = profil?.kullaniciAdi ?? 'Kullanıcı';

    await _servis.hareketTamamla(
      rutinId: rutinId,
      hareketId: hareketId,
      kazanilanPuan: puan,
      kullaniciAdi: kullaniciAdi,
    );
  }

  /// Rutin bilgilerini ve izinlerini günceller.
  Future<void> rutinGuncelle(TopluRutinModeli guncelRutin) async {
    _ref.read(seciliTopluRutinSaglayici.notifier).guncelle(guncelRutin);
    await _servis.rutinGuncelle(guncelRutin);
    _ref.invalidate(kullaniciRutinleriSaglayici);
  }

  /// Bir üyeyi çıkarır.
  Future<void> uyeCikar(String rutinId, String uyeId) async {
    await _servis.uyeCikar(rutinId, uyeId);
  }

  /// Rutinden kendi isteğiyle ayrılır.
  Future<void> rutindenAyril(String rutinId) async {
    await _servis.rutindenAyril(rutinId);
    _ref.read(seciliTopluRutinSaglayici.notifier).sec(null);
  }
}

// ==========================================
// ESKİ V1 SAĞLAYICILARI (Geriye Uyumluluk)
// ==========================================

final kullaniciGruplariSaglayici = StreamProvider<List<GrupModeli>>((ref) {
  final servis = ref.watch(firestoreGrupServisiSaglayici);
  return servis.kullaniciGruplariniDinle();
});

class SeciliGrupKontrolcusu extends Notifier<GrupModeli?> {
  @override
  GrupModeli? build() => null;
  void sec(GrupModeli? grup) => state = grup;
}

final seciliGrupSaglayici = NotifierProvider<SeciliGrupKontrolcusu, GrupModeli?>(
  SeciliGrupKontrolcusu.new,
);

final seciliGrupRutinleriSaglayici = StreamProvider<List<GrupRutinModeli>>((ref) {
  final seciliGrup = ref.watch(seciliGrupSaglayici);
  if (seciliGrup == null) return const Stream.empty();
  final servis = ref.watch(firestoreGrupServisiSaglayici);
  return servis.grupRutinleriniDinle(seciliGrup.id);
});

final grupKontrolcusuSaglayici = Provider<GrupKontrolcusu>((ref) {
  return GrupKontrolcusu(ref);
});

class GrupKontrolcusu {
  final Ref _ref;
  GrupKontrolcusu(this._ref);
  FirestoreGrupServisi get _servis => _ref.read(firestoreGrupServisiSaglayici);

  Future<GrupModeli> grupOlustur({
    required String ad,
    required String aciklama,
    required String kurucuAdi,
  }) async {
    final yeniGrup = await _servis.grupOlustur(ad: ad, aciklama: aciklama, kurucuAdi: kurucuAdi);
    _ref.read(seciliGrupSaglayici.notifier).sec(yeniGrup);
    return yeniGrup;
  }
}
