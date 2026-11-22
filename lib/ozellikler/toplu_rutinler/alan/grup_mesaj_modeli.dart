// lib/ozellikler/toplu_rutinler/alan/grup_mesaj_modeli.dart

import 'grup_kanit_modeli.dart';

/// Grup içi canlı sohbet mesajlarını veya otomatik başarı/kanıt bildirimlerini temsil eder.
class GrupMesajModeli {
  final String id;
  final String grupId;
  final String gonderenId;
  final String gonderenAdi;
  final String tur; // 'metin', 'kanit_karti', 'sistem'
  final String metin;
  final GrupKanitModeli? kanit;
  final Map<String, List<String>> tepkiler; // Örn: {'🔥': ['userId1', 'userId2'], '👏': ['userId3']}
  final DateTime tarih;

  const GrupMesajModeli({
    required this.id,
    required this.grupId,
    required this.gonderenId,
    required this.gonderenAdi,
    required this.tur,
    required this.metin,
    this.kanit,
    this.tepkiler = const {},
    required this.tarih,
  });

  /// Firestore belgesini veya harita (Map) verisini modele dönüştürür.
  factory GrupMesajModeli.haritadanUret(Map<String, dynamic> harita, String id) {
    Map<String, List<String>> cozulenTepkiler = {};
    if (harita['tepkiler'] is Map) {
      (harita['tepkiler'] as Map).forEach((anahtar, deger) {
        if (deger is List) {
          cozulenTepkiler[anahtar.toString()] =
              deger.map((e) => e.toString()).toList();
        }
      });
    }

    GrupKanitModeli? cozulenKanit;
    if (harita['kanit'] is Map<String, dynamic>) {
      cozulenKanit = GrupKanitModeli.haritadanUret(
        harita['kanit'] as Map<String, dynamic>,
        harita['kanitId'] as String? ?? '',
      );
    }

    return GrupMesajModeli(
      id: id,
      grupId: harita['grupId'] as String? ?? '',
      gonderenId: harita['gonderenId'] as String? ?? '',
      gonderenAdi: harita['gonderenAdi'] as String? ?? 'Katılımcı',
      tur: harita['tur'] as String? ?? 'metin',
      metin: harita['metin'] as String? ?? '',
      kanit: cozulenKanit,
      tepkiler: cozulenTepkiler,
      tarih: harita['tarih'] != null
          ? DateTime.tryParse(harita['tarih'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Modeli Firestore'a kaydetmek üzere haritaya (Map) dönüştürür.
  Map<String, dynamic> haritayaDonustur() {
    return {
      'grupId': grupId,
      'gonderenId': gonderenId,
      'gonderenAdi': gonderenAdi,
      'tur': tur,
      'metin': metin,
      'kanit': kanit?.haritayaDonustur(),
      'kanitId': kanit?.id,
      'tepkiler': tepkiler,
      'tarih': tarih.toIso8601String(),
    };
  }

  GrupMesajModeli tepkiGuncelle(String emoji, String kullaniciId) {
    final yeniTepkiler = Map<String, List<String>>.from(
      tepkiler.map((k, v) => MapEntry(k, List<String>.from(v))),
    );

    final liste = yeniTepkiler[emoji] ?? [];
    if (liste.contains(kullaniciId)) {
      liste.remove(kullaniciId);
      if (liste.isEmpty) {
        yeniTepkiler.remove(emoji);
      } else {
        yeniTepkiler[emoji] = liste;
      }
    } else {
      liste.add(kullaniciId);
      yeniTepkiler[emoji] = liste;
    }

    return GrupMesajModeli(
      id: id,
      grupId: grupId,
      gonderenId: gonderenId,
      gonderenAdi: gonderenAdi,
      tur: tur,
      metin: metin,
      kanit: kanit,
      tepkiler: yeniTepkiler,
      tarih: tarih,
    );
  }
}
