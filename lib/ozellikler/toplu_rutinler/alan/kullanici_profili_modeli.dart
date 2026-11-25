// lib/ozellikler/toplu_rutinler/alan/kullanici_profili_modeli.dart

/// Firebase üzerindeki resmi kullanıcı profil kimliği.
class KullaniciProfiliModeli {
  final String kullaniciId; // Firebase UID
  final String kullaniciAdi; // @mustafa, @zeynep
  final int kazanilanKupaSayisi; // 🏆 Kazanılan yarış kupaları
  final String? profilResmiUrl;
  final DateTime kayitTarihi;

  const KullaniciProfiliModeli({
    required this.kullaniciId,
    required this.kullaniciAdi,
    this.kazanilanKupaSayisi = 0,
    this.profilResmiUrl,
    required this.kayitTarihi,
  });

  factory KullaniciProfiliModeli.haritadan(Map<String, dynamic> harita, String id) {
    return KullaniciProfiliModeli(
      kullaniciId: id,
      kullaniciAdi: harita['kullaniciAdi'] as String? ?? 'Kullanıcı',
      kazanilanKupaSayisi: harita['kazanilanKupaSayisi'] as int? ?? 0,
      profilResmiUrl: harita['profilResmiUrl'] as String?,
      kayitTarihi: harita['kayitTarihi'] != null
          ? DateTime.tryParse(harita['kayitTarihi'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> haritaya() {
    return {
      'kullaniciId': kullaniciId,
      'kullaniciAdi': kullaniciAdi,
      'kazanilanKupaSayisi': kazanilanKupaSayisi,
      'profilResmiUrl': profilResmiUrl,
      'kayitTarihi': kayitTarihi.toIso8601String(),
    };
  }

  KullaniciProfiliModeli kopyala({
    String? kullaniciAdi,
    int? kazanilanKupaSayisi,
    String? profilResmiUrl,
  }) {
    return KullaniciProfiliModeli(
      kullaniciId: kullaniciId,
      kullaniciAdi: kullaniciAdi ?? this.kullaniciAdi,
      kazanilanKupaSayisi: kazanilanKupaSayisi ?? this.kazanilanKupaSayisi,
      profilResmiUrl: profilResmiUrl ?? this.profilResmiUrl,
      kayitTarihi: kayitTarihi,
    );
  }
}
