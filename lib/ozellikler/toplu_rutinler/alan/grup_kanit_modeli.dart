// lib/ozellikler/toplu_rutinler/alan/grup_kanit_modeli.dart

/// Kullanıcının yaptığı bir rutin için yüklediği kanıtı ve yapay zeka doğrulama sonucunu temsil eder.
class GrupKanitModeli {
  final String id;
  final String grupId;
  final String rutinId;
  final String rutinBasligi;
  final String kullaniciId;
  final String kullaniciAdi;
  final String fotoUrl;
  final String istenenDinamikPoz;
  final bool aiOnaylandiMi;
  final double aiGuvenSkoru; // 0.0 - 1.0 arası
  final String aiGeriBildirimi;
  final DateTime tarih;

  const GrupKanitModeli({
    required this.id,
    required this.grupId,
    required this.rutinId,
    required this.rutinBasligi,
    required this.kullaniciId,
    required this.kullaniciAdi,
    required this.fotoUrl,
    required this.istenenDinamikPoz,
    required this.aiOnaylandiMi,
    this.aiGuvenSkoru = 1.0,
    required this.aiGeriBildirimi,
    required this.tarih,
  });

  /// Firestore belgesini veya harita (Map) verisini modele dönüştürür.
  factory GrupKanitModeli.haritadanUret(Map<String, dynamic> harita, String id) {
    return GrupKanitModeli(
      id: id,
      grupId: harita['grupId'] as String? ?? '',
      rutinId: harita['rutinId'] as String? ?? '',
      rutinBasligi: harita['rutinBasligi'] as String? ?? 'Rutin',
      kullaniciId: harita['kullaniciId'] as String? ?? '',
      kullaniciAdi: harita['kullaniciAdi'] as String? ?? 'Kullanıcı',
      fotoUrl: harita['fotoUrl'] as String? ?? '',
      istenenDinamikPoz: harita['istenenDinamikPoz'] as String? ?? '',
      aiOnaylandiMi: harita['aiOnaylandiMi'] as bool? ?? false,
      aiGuvenSkoru: (harita['aiGuvenSkoru'] as num?)?.toDouble() ?? 1.0,
      aiGeriBildirimi: harita['aiGeriBildirimi'] as String? ?? '',
      tarih: harita['tarih'] != null
          ? DateTime.tryParse(harita['tarih'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Modeli Firestore'a kaydetmek üzere haritaya (Map) dönüştürür.
  Map<String, dynamic> haritayaDonustur() {
    return {
      'grupId': grupId,
      'rutinId': rutinId,
      'rutinBasligi': rutinBasligi,
      'kullaniciId': kullaniciId,
      'kullaniciAdi': kullaniciAdi,
      'fotoUrl': fotoUrl,
      'istenenDinamikPoz': istenenDinamikPoz,
      'aiOnaylandiMi': aiOnaylandiMi,
      'aiGuvenSkoru': aiGuvenSkoru,
      'aiGeriBildirimi': aiGeriBildirimi,
      'tarih': tarih.toIso8601String(),
    };
  }
}
