// lib/ozellikler/toplu_rutinler/alan/grup_rutin_modeli.dart

/// Grup için tanımlanmış ortak bir rutini (örn: Diş Fırçalama, Sabah Şınavı) temsil eden model.
/// Saat veya alarm kısıtlaması yoktur; kullanıcı gün içinde istediği an tamamlayabilir.
class GrupRutinModeli {
  final String id;
  final String grupId;
  final String baslik;
  final String aciklama;
  final String kategori; // 'saglik', 'spor', 'kisisel_gelisim', 'diger'
  final List<int> hedefGunler; // 1=Pzt, 7=Paz (Boşsa her gün geçerlidir)
  final int puanDegeri; // Her başarılı onayda kazanılacak puan (varsayılan: 10)
  final DateTime olusturmaTarihi;
  final bool aktifMi;

  const GrupRutinModeli({
    required this.id,
    required this.grupId,
    required this.baslik,
    required this.aciklama,
    this.kategori = 'saglik',
    this.hedefGunler = const [1, 2, 3, 4, 5, 6, 7],
    this.puanDegeri = 10,
    required this.olusturmaTarihi,
    this.aktifMi = true,
  });

  /// Firestore belgesini veya harita (Map) verisini modele dönüştürür.
  factory GrupRutinModeli.haritadanUret(Map<String, dynamic> harita, String id) {
    return GrupRutinModeli(
      id: id,
      grupId: harita['grupId'] as String? ?? '',
      baslik: harita['baslik'] as String? ?? '',
      aciklama: harita['aciklama'] as String? ?? '',
      kategori: harita['kategori'] as String? ?? 'saglik',
      hedefGunler: (harita['hedefGunler'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [1, 2, 3, 4, 5, 6, 7],
      puanDegeri: (harita['puanDegeri'] as num?)?.toInt() ?? 10,
      olusturmaTarihi: harita['olusturmaTarihi'] != null
          ? DateTime.tryParse(harita['olusturmaTarihi'].toString()) ?? DateTime.now()
          : DateTime.now(),
      aktifMi: harita['aktifMi'] as bool? ?? true,
    );
  }

  /// Modeli Firestore'a kaydetmek üzere haritaya (Map) dönüştürür.
  Map<String, dynamic> haritayaDonustur() {
    return {
      'grupId': grupId,
      'baslik': baslik,
      'aciklama': aciklama,
      'kategori': kategori,
      'hedefGunler': hedefGunler,
      'puanDegeri': puanDegeri,
      'olusturmaTarihi': olusturmaTarihi.toIso8601String(),
      'aktifMi': aktifMi,
    };
  }
}
