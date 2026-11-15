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

// Fizyoterapi hastaları ve günlük sağlık için hazır örnek hareket şablonları.
const List<HazirEgzersizSablonu> hazirEgzersizSablonlari = [
  HazirEgzersizSablonu(
    ad: 'Boyun Sağa-Sola Esnetme',
    aciklama: 'Başı nazikçe omuza doğru eğip 5 saniye tutma (10 tekrar).',
    tur: 'tekrarli',
    setSayisi: 2,
    tekrarSayisi: 10,
    kategori: 'Boyun & Omuz (Fizyoterapi)',
  ),
  HazirEgzersizSablonu(
    ad: 'Omuz Çevirme ve Germe',
    aciklama: 'Omuzları yavaşça geriye doğru daire çizerek yuvarlama.',
    tur: 'tekrarli',
    setSayisi: 2,
    tekrarSayisi: 12,
    kategori: 'Boyun & Omuz (Fizyoterapi)',
  ),
  HazirEgzersizSablonu(
    ad: 'Bel Çukuru Bastırma (Pelvik Tilt)',
    aciklama: 'Sırtüstü yatarken bel boşluğunu yatağa/yere bastırıp 5 sn tutma.',
    tur: 'tekrarli',
    setSayisi: 3,
    tekrarSayisi: 10,
    kategori: 'Bel & Omurga (Fizyoterapi)',
  ),
  HazirEgzersizSablonu(
    ad: 'Havlu ile Diz Bastırma',
    aciklama: 'Diz altına rulo havlu koyup dizi aşağı bastırarak 5 sn kasma.',
    tur: 'tekrarli',
    setSayisi: 3,
    tekrarSayisi: 10,
    kategori: 'Diz & Bacak (Fizyoterapi)',
  ),
  HazirEgzersizSablonu(
    ad: 'Ayak Bileği Pompalama',
    aciklama: 'Ayak ucunu kendine çekip ileri iterek kan dolaşımını artırma.',
    tur: 'tekrarli',
    setSayisi: 3,
    tekrarSayisi: 15,
    kategori: 'Diz & Bacak (Fizyoterapi)',
  ),
  HazirEgzersizSablonu(
    ad: 'Kedi - Deve Sırt Esnetme',
    aciklama: 'Dört ayak üzerinde sırtı yavaşça kamburlaştırıp çukurlaştırma.',
    tur: 'tekrarli',
    setSayisi: 2,
    tekrarSayisi: 10,
    kategori: 'Bel & Omurga (Fizyoterapi)',
  ),
  HazirEgzersizSablonu(
    ad: 'Köprü Kurma (Kalça Kaldırma)',
    aciklama: 'Sırtüstü dizler bükülü yatarken kalçayı yukarı kaldırıp indirme.',
    tur: 'tekrarli',
    setSayisi: 3,
    tekrarSayisi: 10,
    kategori: 'Bel & Omurga (Fizyoterapi)',
  ),
  HazirEgzersizSablonu(
    ad: 'Düz Bacak Kaldırma',
    aciklama: 'Sırtüstü yatarken dizi bükmeden bacağı 45 derece yukarı kaldırma.',
    tur: 'tekrarli',
    setSayisi: 3,
    tekrarSayisi: 10,
    kategori: 'Diz & Bacak (Fizyoterapi)',
  ),
  HazirEgzersizSablonu(
    ad: 'El ve Parmak Açma - Kapama',
    aciklama: 'Parmakları tam açıp yumruk yaparak el eklemlerini çalıştırma.',
    tur: 'tekrarli',
    setSayisi: 2,
    tekrarSayisi: 15,
    kategori: 'El & Kol (Fizyoterapi)',
  ),
  HazirEgzersizSablonu(
    ad: 'Dik Duruş (Postür) Egzersizi',
    aciklama: 'Sırtı duvara yaslayıp kürek kemiklerini birbirine yaklaştırma.',
    tur: 'sureli',
    sureSaniye: 60,
    kategori: 'Günlük Esneklik & Yürüyüş',
  ),
];

// Egzersiz formlarında kullanılan varsayılan kategori listesi.
const List<String> varsayilanEgzersizKategorileri = [
  'Boyun & Omuz (Fizyoterapi)',
  'Bel & Omurga (Fizyoterapi)',
  'Diz & Bacak (Fizyoterapi)',
  'El & Kol (Fizyoterapi)',
  'Günlük Esneklik & Yürüyüş',
  'Genel Egzersiz',
];
