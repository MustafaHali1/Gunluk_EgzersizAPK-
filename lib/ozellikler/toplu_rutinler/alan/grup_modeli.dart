// lib/ozellikler/toplu_rutinler/alan/grup_modeli.dart

/// Toplu rutin grubunu temsil eden veri modeli.
class GrupModeli {
  final String id;
  final String ad;
  final String aciklama;
  final String davetKodu;
  final String olusturanKullaniciId;
  final DateTime olusturmaTarihi;
  final bool aktifMi;

  const GrupModeli({
    required this.id,
    required this.ad,
    required this.aciklama,
    required this.davetKodu,
    required this.olusturanKullaniciId,
    required this.olusturmaTarihi,
    this.aktifMi = true,
  });

  /// Firestore belgesini veya harita (Map) verisini modele dönüştürür.
  factory GrupModeli.haritadanUret(Map<String, dynamic> harita, String id) {
    return GrupModeli(
      id: id,
      ad: harita['ad'] as String? ?? '',
      aciklama: harita['aciklama'] as String? ?? '',
      davetKodu: harita['davetKodu'] as String? ?? '',
      olusturanKullaniciId: harita['olusturanKullaniciId'] as String? ?? '',
      olusturmaTarihi: harita['olusturmaTarihi'] != null
          ? DateTime.tryParse(harita['olusturmaTarihi'].toString()) ?? DateTime.now()
          : DateTime.now(),
      aktifMi: harita['aktifMi'] as bool? ?? true,
    );
  }

  /// Modeli Firestore'a kaydetmek üzere haritaya (Map) dönüştürür.
  Map<String, dynamic> haritayaDonustur() {
    return {
      'ad': ad,
      'aciklama': aciklama,
      'davetKodu': davetKodu,
      'olusturanKullaniciId': olusturanKullaniciId,
      'olusturmaTarihi': olusturmaTarihi.toIso8601String(),
      'aktifMi': aktifMi,
    };
  }

  GrupModeli kopyala({
    String? ad,
    String? aciklama,
    String? davetKodu,
    bool? aktifMi,
  }) {
    return GrupModeli(
      id: id,
      ad: ad ?? this.ad,
      aciklama: aciklama ?? this.aciklama,
      davetKodu: davetKodu ?? this.davetKodu,
      olusturanKullaniciId: olusturanKullaniciId,
      olusturmaTarihi: olusturmaTarihi,
      aktifMi: aktifMi ?? this.aktifMi,
    );
  }
}
