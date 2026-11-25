// lib/ozellikler/toplu_rutinler/alan/rutin_hareketi_modeli.dart

/// Rutin içindeki her bir alt egzersiz veya alışkanlık görevini temsil eden model.
class RutinHareketiModeli {
  final String id;
  final String baslik; // Örn: "20 Derin Squat", "Diş Fırçalama"
  final String tur; // 'sureli', 'tekrarli', 'kontrol'
  final int? hedefDeger; // 45 sn veya 20 tekrar
  final int puan; // 10, 20, 25 puan
  final bool nesneGerektirirMi; // Diş fırçası, su bardağı vb.
  final String? beklenenNesneAdi; // "Diş Fırçası", "Su Bardağı", "Kitap"
  final bool kanitZorunluMu; // true -> kamera açılır, false -> hızlı tik
  final List<String> bugunTamamlayanUyeIdleri;
  final int siraIndeksi;

  const RutinHareketiModeli({
    required this.id,
    required this.baslik,
    this.tur = 'kontrol',
    this.hedefDeger,
    this.puan = 15,
    this.nesneGerektirirMi = false,
    this.beklenenNesneAdi,
    this.kanitZorunluMu = true,
    this.bugunTamamlayanUyeIdleri = const [],
    this.siraIndeksi = 0,
  });

  factory RutinHareketiModeli.haritadan(Map<String, dynamic> harita) {
    return RutinHareketiModeli(
      id: harita['id'] as String? ?? '',
      baslik: harita['baslik'] as String? ?? '',
      tur: harita['tur'] as String? ?? 'kontrol',
      hedefDeger: harita['hedefDeger'] as int?,
      puan: harita['puan'] as int? ?? 15,
      nesneGerektirirMi: harita['nesneGerektirirMi'] as bool? ?? false,
      beklenenNesneAdi: harita['beklenenNesneAdi'] as String?,
      kanitZorunluMu: harita['kanitZorunluMu'] as bool? ?? true,
      bugunTamamlayanUyeIdleri: List<String>.from(
        harita['bugunTamamlayanUyeIdleri'] as List? ?? [],
      ),
      siraIndeksi: harita['siraIndeksi'] as int? ?? 0,
    );
  }

  Map<String, dynamic> haritaya() {
    return {
      'id': id,
      'baslik': baslik,
      'tur': tur,
      'hedefDeger': hedefDeger,
      'puan': puan,
      'nesneGerektirirMi': nesneGerektirirMi,
      'beklenenNesneAdi': beklenenNesneAdi,
      'kanitZorunluMu': kanitZorunluMu,
      'bugunTamamlayanUyeIdleri': bugunTamamlayanUyeIdleri,
      'siraIndeksi': siraIndeksi,
    };
  }

  RutinHareketiModeli kopyala({
    String? baslik,
    String? tur,
    int? hedefDeger,
    int? puan,
    bool? nesneGerektirirMi,
    String? beklenenNesneAdi,
    bool? kanitZorunluMu,
    List<String>? bugunTamamlayanUyeIdleri,
    int? siraIndeksi,
  }) {
    return RutinHareketiModeli(
      id: id,
      baslik: baslik ?? this.baslik,
      tur: tur ?? this.tur,
      hedefDeger: hedefDeger ?? this.hedefDeger,
      puan: puan ?? this.puan,
      nesneGerektirirMi: nesneGerektirirMi ?? this.nesneGerektirirMi,
      beklenenNesneAdi: beklenenNesneAdi ?? this.beklenenNesneAdi,
      kanitZorunluMu: kanitZorunluMu ?? this.kanitZorunluMu,
      bugunTamamlayanUyeIdleri: bugunTamamlayanUyeIdleri ?? this.bugunTamamlayanUyeIdleri,
      siraIndeksi: siraIndeksi ?? this.siraIndeksi,
    );
  }
}
