// lib/ozellikler/egzersizler/alan/hazir_egzersiz_sablonu.dart

// Hazır örnek egzersiz listesindeki her bir öğeyi temsil eden model sınıfı.
class HazirEgzersizSablonu {
  final String ad;
  final String aciklama;
  final String tur; // 'sureli' veya 'tekrarli'
  final int? sureSaniye;
  final int? setSayisi;
  final int? tekrarSayisi;
  final String kategori;

  const HazirEgzersizSablonu({
    required this.ad,
    required this.aciklama,
    required this.tur,
    this.sureSaniye,
    this.setSayisi,
    this.tekrarSayisi,
    required this.kategori,
  });
}

// Kullanıcının tek dokunuşla seçip ekleyebileceği hazır örnek egzersizler.
const List<HazirEgzersizSablonu> hazirEgzersizSablonlari = [
  HazirEgzersizSablonu(
    ad: 'Squat (Çömelme)',
    aciklama: 'Sırt dik, dizler ayak ucunu geçmeyecek şekilde çömelip kalkma.',
    tur: 'tekrarli',
    setSayisi: 3,
    tekrarSayisi: 15,
    kategori: 'Alt Vücut',
  ),
  HazirEgzersizSablonu(
    ad: 'Plank',
    aciklama: 'Dirsekler ve ayak parmakları üzerinde vücudu düz tutma.',
    tur: 'sureli',
    sureSaniye: 45,
    kategori: 'Karın / Merkez',
  ),
  HazirEgzersizSablonu(
    ad: 'Şınav (Push-up)',
    aciklama: 'Eller omuz genişliğinde açık, göğsü yere yaklaştırıp itme.',
    tur: 'tekrarli',
    setSayisi: 3,
    tekrarSayisi: 12,
    kategori: 'Üst Vücut',
  ),
  HazirEgzersizSablonu(
    ad: 'Lunge (Adım Çömelme)',
    aciklama: 'Bir adım öne atarak her iki dizi 90 derece bükme.',
    tur: 'tekrarli',
    setSayisi: 3,
    tekrarSayisi: 12,
    kategori: 'Alt Vücut',
  ),
  HazirEgzersizSablonu(
    ad: 'Köprü (Glute Bridge)',
    aciklama: 'Sırtüstü yatarken dizler bükülü kalçayı yukarı kaldırma.',
    tur: 'tekrarli',
    setSayisi: 3,
    tekrarSayisi: 15,
    kategori: 'Kalça / Bel',
  ),
  HazirEgzersizSablonu(
    ad: 'Kedi - Deve Esnemesi',
    aciklama: 'Dört ayak üzerinde sırtı kamburlaştırıp çukurlaştırarak omurga esnetme.',
    tur: 'sureli',
    sureSaniye: 60,
    kategori: 'Esneklik / Omurga',
  ),
  HazirEgzersizSablonu(
    ad: 'Duvar Oturuşu (Wall Sit)',
    aciklama: 'Sırtı duvara yaslayıp dizler 90 derece açıda sabit bekleme.',
    tur: 'sureli',
    sureSaniye: 40,
    kategori: 'Alt Vücut',
  ),
  HazirEgzersizSablonu(
    ad: 'Boyun ve Omuz Esnetme',
    aciklama: 'Boynu nazikçe sağa-sola eğme ve omuzları geriye yuvarlama.',
    tur: 'sureli',
    sureSaniye: 60,
    kategori: 'Esneklik / Boyun',
  ),
];
