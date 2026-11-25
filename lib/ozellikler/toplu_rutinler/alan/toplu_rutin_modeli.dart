// lib/ozellikler/toplu_rutinler/alan/toplu_rutin_modeli.dart

import 'rutin_hareketi_modeli.dart';

/// Toplu Rutin ana nesne modeli.
class TopluRutinModeli {
  final String id;
  final String baslik; // "Sabah Canlanma & Su"
  final String aciklama;
  final String kategori; // Sabah, Fitness, Esneme, Gece, Sağlık, Zihin
  final String davetKodu; // 6 haneli benzersiz davet kodu
  final String kurucuKullaniciId;
  final List<String> yoneticiIdleri;
  final List<String> uyeIdleri;
  final List<String> hedefGunler; // '1' (Pzt) ... '7' (Paz)
  final List<RutinHareketiModeli> hareketler; // Alt egzersizler listesi
  final Map<String, dynamic>? sabitlenmisMesaj; // Sohbette başa sabitlenen mesaj
  final Map<String, dynamic>? aktifYaris; // 7/10/30 günlük süreli yarış panosu
  final bool yalnizcaYoneticiHareketEkleyebilir;
  final bool yalnizcaYoneticiDuzenleyebilir;
  final int mevcutSeriGun;
  final DateTime olusturulmaTarihi;

  const TopluRutinModeli({
    required this.id,
    required this.baslik,
    this.aciklama = '',
    this.kategori = 'Sabah',
    required this.davetKodu,
    required this.kurucuKullaniciId,
    this.yoneticiIdleri = const [],
    this.uyeIdleri = const [],
    this.hedefGunler = const ['1', '2', '3', '4', '5', '6', '7'],
    this.hareketler = const [],
    this.sabitlenmisMesaj,
    this.aktifYaris,
    this.yalnizcaYoneticiHareketEkleyebilir = false,
    this.yalnizcaYoneticiDuzenleyebilir = true,
    this.mevcutSeriGun = 0,
    required this.olusturulmaTarihi,
  });

  /// Rutinin açılışından bugüne geçen toplam gün sayısı
  int get acilisindanBeriGecenGun {
    final fark = DateTime.now().difference(olusturulmaTarihi).inDays;
    return fark <= 0 ? 1 : fark + 1;
  }

  factory TopluRutinModeli.haritadan(Map<String, dynamic> harita, String id) {
    final hareketlerHam = harita['hareketler'] as List? ?? [];
    final hareketListesi = hareketlerHam
        .map((h) => RutinHareketiModeli.haritadan(Map<String, dynamic>.from(h as Map)))
        .toList()
      ..sort((a, b) => a.siraIndeksi.compareTo(b.siraIndeksi));

    return TopluRutinModeli(
      id: id,
      baslik: harita['baslik'] as String? ?? '',
      aciklama: harita['aciklama'] as String? ?? '',
      kategori: harita['kategori'] as String? ?? 'Sabah',
      davetKodu: harita['davetKodu'] as String? ?? '',
      kurucuKullaniciId: harita['kurucuKullaniciId'] as String? ?? '',
      yoneticiIdleri: List<String>.from(harita['yoneticiIdleri'] as List? ?? []),
      uyeIdleri: List<String>.from(harita['uyeIdleri'] as List? ?? []),
      hedefGunler: List<String>.from(harita['hedefGunler'] as List? ?? ['1', '2', '3', '4', '5', '6', '7']),
      hareketler: hareketListesi,
      sabitlenmisMesaj: harita['sabitlenmisMesaj'] != null
          ? Map<String, dynamic>.from(harita['sabitlenmisMesaj'] as Map)
          : null,
      aktifYaris: harita['aktifYaris'] != null
          ? Map<String, dynamic>.from(harita['aktifYaris'] as Map)
          : null,
      yalnizcaYoneticiHareketEkleyebilir: harita['yalnizcaYoneticiHareketEkleyebilir'] as bool? ?? false,
      yalnizcaYoneticiDuzenleyebilir: harita['yalnizcaYoneticiDuzenleyebilir'] as bool? ?? true,
      mevcutSeriGun: harita['mevcutSeriGun'] as int? ?? 0,
      olusturulmaTarihi: harita['olusturulmaTarihi'] != null
          ? DateTime.tryParse(harita['olusturulmaTarihi'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> haritaya() {
    return {
      'baslik': baslik,
      'aciklama': aciklama,
      'kategori': kategori,
      'davetKodu': davetKodu,
      'kurucuKullaniciId': kurucuKullaniciId,
      'yoneticiIdleri': yoneticiIdleri,
      'uyeIdleri': uyeIdleri,
      'hedefGunler': hedefGunler,
      'hareketler': hareketler.map((h) => h.haritaya()).toList(),
      'sabitlenmisMesaj': sabitlenmisMesaj,
      'aktifYaris': aktifYaris,
      'yalnizcaYoneticiHareketEkleyebilir': yalnizcaYoneticiHareketEkleyebilir,
      'yalnizcaYoneticiDuzenleyebilir': yalnizcaYoneticiDuzenleyebilir,
      'mevcutSeriGun': mevcutSeriGun,
      'olusturulmaTarihi': olusturulmaTarihi.toIso8601String(),
    };
  }

  TopluRutinModeli kopyala({
    String? baslik,
    String? aciklama,
    String? kategori,
    String? davetKodu,
    List<String>? yoneticiIdleri,
    List<String>? uyeIdleri,
    List<String>? hedefGunler,
    List<RutinHareketiModeli>? hareketler,
    Map<String, dynamic>? sabitlenmisMesaj,
    bool sifirlaSabitlenmisMesaj = false,
    Map<String, dynamic>? aktifYaris,
    bool sifirlaAktifYaris = false,
    bool? yalnizcaYoneticiHareketEkleyebilir,
    bool? yalnizcaYoneticiDuzenleyebilir,
    int? mevcutSeriGun,
  }) {
    return TopluRutinModeli(
      id: id,
      baslik: baslik ?? this.baslik,
      aciklama: aciklama ?? this.aciklama,
      kategori: kategori ?? this.kategori,
      davetKodu: davetKodu ?? this.davetKodu,
      kurucuKullaniciId: kurucuKullaniciId,
      yoneticiIdleri: yoneticiIdleri ?? this.yoneticiIdleri,
      uyeIdleri: uyeIdleri ?? this.uyeIdleri,
      hedefGunler: hedefGunler ?? this.hedefGunler,
      hareketler: hareketler ?? this.hareketler,
      sabitlenmisMesaj: sifirlaSabitlenmisMesaj ? null : (sabitlenmisMesaj ?? this.sabitlenmisMesaj),
      aktifYaris: sifirlaAktifYaris ? null : (aktifYaris ?? this.aktifYaris),
      yalnizcaYoneticiHareketEkleyebilir: yalnizcaYoneticiHareketEkleyebilir ?? this.yalnizcaYoneticiHareketEkleyebilir,
      yalnizcaYoneticiDuzenleyebilir: yalnizcaYoneticiDuzenleyebilir ?? this.yalnizcaYoneticiDuzenleyebilir,
      mevcutSeriGun: mevcutSeriGun ?? this.mevcutSeriGun,
      olusturulmaTarihi: olusturulmaTarihi,
    );
  }
}
