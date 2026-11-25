// lib/ozellikler/toplu_rutinler/alan/grup_uyesi_modeli.dart

/// Grup veya rutin içerisindeki bir katılımcıyı ve başarı istatistiklerini temsil eden model.
class GrupUyesiModeli {
  final String id;
  final String kullaniciId;
  final String gorunenAd;
  final String? profilResmiUrl;
  final String rol; // 'kurucu' veya 'uye'
  final int toplamPuan;
  final int mevcutSeri;
  final int enUzunSeri;
  final int tamamlananGorevSayisi;
  final int tamamlananGunSayisi;
  final DateTime katilmaTarihi;

  const GrupUyesiModeli({
    required this.id,
    required this.kullaniciId,
    required this.gorunenAd,
    this.profilResmiUrl,
    this.rol = 'uye',
    this.toplamPuan = 0,
    this.mevcutSeri = 0,
    this.enUzunSeri = 0,
    this.tamamlananGorevSayisi = 0,
    this.tamamlananGunSayisi = 0,
    required this.katilmaTarihi,
  });

  /// Firestore belgesini veya harita (Map) verisini modele dönüştürür.
  factory GrupUyesiModeli.haritadanUret(Map<String, dynamic> harita, String id) {
    final gorevSayisi = (harita['tamamlananGorevSayisi'] as num?)?.toInt() ?? 0;
    return GrupUyesiModeli(
      id: id,
      kullaniciId: harita['kullaniciId'] as String? ?? '',
      gorunenAd: harita['gorunenAd'] as String? ?? harita['kullaniciAdi'] as String? ?? 'Katılımcı',
      profilResmiUrl: harita['profilResmiUrl'] as String?,
      rol: harita['rol'] as String? ?? 'uye',
      toplamPuan: (harita['toplamPuan'] as num?)?.toInt() ?? 0,
      mevcutSeri: (harita['mevcutSeri'] as num?)?.toInt() ?? 0,
      enUzunSeri: (harita['enUzunSeri'] as num?)?.toInt() ?? 0,
      tamamlananGorevSayisi: gorevSayisi,
      tamamlananGunSayisi: (harita['tamamlananGunSayisi'] as num?)?.toInt() ?? (gorevSayisi > 0 ? (gorevSayisi / 3).ceil() : 0),
      katilmaTarihi: harita['katilmaTarihi'] != null
          ? DateTime.tryParse(harita['katilmaTarihi'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Modeli Firestore'a kaydetmek üzere haritaya (Map) dönüştürür.
  Map<String, dynamic> haritayaDonustur() {
    return {
      'kullaniciId': kullaniciId,
      'gorunenAd': gorunenAd,
      'kullaniciAdi': gorunenAd,
      'profilResmiUrl': profilResmiUrl,
      'rol': rol,
      'toplamPuan': toplamPuan,
      'mevcutSeri': mevcutSeri,
      'enUzunSeri': enUzunSeri,
      'tamamlananGorevSayisi': tamamlananGorevSayisi,
      'tamamlananGunSayisi': tamamlananGunSayisi,
      'katilmaTarihi': katilmaTarihi.toIso8601String(),
    };
  }

  GrupUyesiModeli kopyala({
    String? gorunenAd,
    String? profilResmiUrl,
    String? rol,
    int? toplamPuan,
    int? mevcutSeri,
    int? enUzunSeri,
    int? tamamlananGorevSayisi,
    int? tamamlananGunSayisi,
  }) {
    return GrupUyesiModeli(
      id: id,
      kullaniciId: kullaniciId,
      gorunenAd: gorunenAd ?? this.gorunenAd,
      profilResmiUrl: profilResmiUrl ?? this.profilResmiUrl,
      rol: rol ?? this.rol,
      toplamPuan: toplamPuan ?? this.toplamPuan,
      mevcutSeri: mevcutSeri ?? this.mevcutSeri,
      enUzunSeri: enUzunSeri ?? this.enUzunSeri,
      tamamlananGorevSayisi: tamamlananGorevSayisi ?? this.tamamlananGorevSayisi,
      tamamlananGunSayisi: tamamlananGunSayisi ?? this.tamamlananGunSayisi,
      katilmaTarihi: katilmaTarihi,
    );
  }
}
