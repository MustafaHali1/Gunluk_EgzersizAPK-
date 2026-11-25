// lib/ozellikler/toplu_rutinler/alan/grup_kanit_modeli.dart

/// Kullanıcının yaptığı bir rutin için yüklediği kanıtı temsil eder.
class GrupKanitModeli {
  final String id;
  final String grupId; // veya rutinId
  final String rutinId;
  final String rutinBasligi;
  final String kullaniciId;
  final String kullaniciAdi;
  final String fotoUrl;
  final String istenenDinamikPoz;
  final String kanitTuru; // 'nesne', 'jest', 'kurtarma_jesti', 'sosyal_fallback'
  final String kanitDamgasi; // "🎯 Diş Fırçası [AI Onaylı]"
  final bool aiOnaylandiMi;
  final double aiGuvenSkoru; // 0.0 - 1.0 arası
  final String aiGeriBildirimi;
  final DateTime tarih;
  final Map<String, List<String>> reaksiyonlar; // {'🔥': ['uid1', 'uid2']}

  const GrupKanitModeli({
    required this.id,
    required this.grupId,
    required this.rutinId,
    required this.rutinBasligi,
    required this.kullaniciId,
    required this.kullaniciAdi,
    required this.fotoUrl,
    required this.istenenDinamikPoz,
    this.kanitTuru = 'jest',
    this.kanitDamgasi = '',
    required this.aiOnaylandiMi,
    this.aiGuvenSkoru = 1.0,
    required this.aiGeriBildirimi,
    required this.tarih,
    this.reaksiyonlar = const {},
  });

  /// Firestore belgesini veya harita (Map) verisini modele dönüştürür.
  factory GrupKanitModeli.haritadanUret(Map<String, dynamic> harita, String id) {
    final hamReaksiyonlar = harita['reaksiyonlar'] as Map? ?? {};
    final duzenlenmisReaksiyonlar = <String, List<String>>{};
    hamReaksiyonlar.forEach((anahtar, deger) {
      if (deger is List) {
        duzenlenmisReaksiyonlar[anahtar.toString()] = List<String>.from(deger);
      }
    });

    return GrupKanitModeli(
      id: id,
      grupId: harita['grupId'] as String? ?? harita['rutinId'] as String? ?? '',
      rutinId: harita['rutinId'] as String? ?? '',
      rutinBasligi: harita['rutinBasligi'] as String? ?? 'Rutin',
      kullaniciId: harita['kullaniciId'] as String? ?? '',
      kullaniciAdi: harita['kullaniciAdi'] as String? ?? 'Kullanıcı',
      fotoUrl: harita['fotoUrl'] as String? ?? '',
      istenenDinamikPoz: harita['istenenDinamikPoz'] as String? ?? '',
      kanitTuru: harita['kanitTuru'] as String? ?? 'jest',
      kanitDamgasi: harita['kanitDamgasi'] as String? ?? '',
      aiOnaylandiMi: harita['aiOnaylandiMi'] as bool? ?? false,
      aiGuvenSkoru: (harita['aiGuvenSkoru'] as num?)?.toDouble() ?? 1.0,
      aiGeriBildirimi: harita['aiGeriBildirimi'] as String? ?? '',
      tarih: harita['tarih'] != null
          ? DateTime.tryParse(harita['tarih'].toString()) ?? DateTime.now()
          : DateTime.now(),
      reaksiyonlar: duzenlenmisReaksiyonlar,
    );
  }

  factory GrupKanitModeli.haritadan(Map<String, dynamic> harita, String id) =>
      GrupKanitModeli.haritadanUret(harita, id);

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
      'kanitTuru': kanitTuru,
      'kanitDamgasi': kanitDamgasi,
      'aiOnaylandiMi': aiOnaylandiMi,
      'aiGuvenSkoru': aiGuvenSkoru,
      'aiGeriBildirimi': aiGeriBildirimi,
      'tarih': tarih.toIso8601String(),
      'reaksiyonlar': reaksiyonlar,
    };
  }

  Map<String, dynamic> haritaya() => haritayaDonustur();
}
