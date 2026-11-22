// lib/ozellikler/toplu_rutinler/sunum/kontrolculer/grup_kontrolcusu.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../alan/grup_modeli.dart';
import '../../alan/grup_rutin_modeli.dart';
import '../../veri/firestore_grup_servisi.dart';

/// Firestore grup servisi sağlayıcısı
final firestoreGrupServisiSaglayici = Provider<FirestoreGrupServisi>((ref) {
  return FirestoreGrupServisi();
});

/// Aktif kullanıcının kimlik sağlayıcısı
final mevcutKullaniciIdSaglayici = FutureProvider<String>((ref) async {
  final servis = ref.watch(firestoreGrupServisiSaglayici);
  return await servis.mevcutKullaniciKimligiAl();
});

/// Kullanıcının dahil olduğu grupları canlı dinleyen sağlayıcı
final kullaniciGruplariSaglayici = StreamProvider<List<GrupModeli>>((ref) {
  final servis = ref.watch(firestoreGrupServisiSaglayici);
  final kullaniciIdAsync = ref.watch(mevcutKullaniciIdSaglayici);

  return kullaniciIdAsync.when(
    data: (id) => servis.kullanicininGruplariniDinle(id),
    loading: () => Stream.value(<GrupModeli>[]),
    error: (_, _) => Stream.value(<GrupModeli>[]),
  );
});

/// Ekranda seçili olan aktif grubu tutan Notifier
class SeciliGrupKontrolcusu extends Notifier<GrupModeli?> {
  @override
  GrupModeli? build() => null;

  void sec(GrupModeli? grup) => state = grup;
}

final seciliGrupSaglayici =
    NotifierProvider<SeciliGrupKontrolcusu, GrupModeli?>(
  SeciliGrupKontrolcusu.new,
);

/// Seçili grubun rutinlerini canlı dinleyen sağlayıcı
final seciliGrupRutinleriSaglayici = StreamProvider<List<GrupRutinModeli>>((ref) {
  final seciliGrup = ref.watch(seciliGrupSaglayici);
  if (seciliGrup == null) return const Stream.empty();

  final servis = ref.watch(firestoreGrupServisiSaglayici);
  return servis.grupRutinleriniDinle(seciliGrup.id);
});

/// Grup işlemlerini (oluşturma, katılma, rutin ekleme) yöneten iş mantığı sınıfı.
class GrupKontrolcusu {
  final Ref _ref;

  GrupKontrolcusu(this._ref);

  FirestoreGrupServisi get _servis => _ref.read(firestoreGrupServisiSaglayici);

  /// Yeni bir grup oluşturur ve seçili aktif grup yapar.
  Future<GrupModeli> grupOlustur({
    required String ad,
    required String aciklama,
    required String kurucuAdi,
  }) async {
    final yeniGrup = await _servis.grupOlustur(
      ad: ad,
      aciklama: aciklama,
      kurucuAdi: kurucuAdi,
    );
    _ref.read(seciliGrupSaglayici.notifier).sec(yeniGrup);
    return yeniGrup;
  }

  /// 6 haneli kod ile gruba katılır ve aktif grup olarak seçer.
  Future<GrupModeli> davetKoduylaKatil({
    required String kod,
    required String kullaniciAdi,
  }) async {
    final grup = await _servis.davetKoduylaGrubaKatil(
      davetKodu: kod,
      kullaniciAdi: kullaniciAdi,
    );
    _ref.read(seciliGrupSaglayici.notifier).sec(grup);
    return grup;
  }

  /// Aktif gruba saat ve alarm kısıtlamasız yeni bir rutin ekler.
  Future<void> grubaRutinEkle({
    required String grupId,
    required String baslik,
    required String aciklama,
    String kategori = 'saglik',
    int puanDegeri = 10,
  }) async {
    final yeniRutin = GrupRutinModeli(
      id: '',
      grupId: grupId,
      baslik: baslik,
      aciklama: aciklama,
      kategori: kategori,
      puanDegeri: puanDegeri,
      olusturmaTarihi: DateTime.now(),
    );

    await _servis.grupRutiniEkle(yeniRutin);
  }

  /// Aktif seçili grubu günceller.
  void grubuSec(GrupModeli grup) {
    _ref.read(seciliGrupSaglayici.notifier).sec(grup);
  }
}

final grupKontrolcusuSaglayici = Provider<GrupKontrolcusu>((ref) {
  return GrupKontrolcusu(ref);
});
