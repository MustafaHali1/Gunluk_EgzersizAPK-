// lib/ozellikler/toplu_rutinler/alan/kanit_jesti.dart

/// Rastgele canlı kanıt jestini temsil eden model.
class KanitJesti {
  final String id;
  final String baslik;
  final String emoji;
  final String talimat;

  const KanitJesti({
    required this.id,
    required this.baslik,
    required this.emoji,
    required this.talimat,
  });
}

/// Kullanıcının kolayca yenilerini ekleyebileceği dinamik jest havuzu.
class JestHavuzu {
  static const List<KanitJesti> jestler = [
    KanitJesti(
      id: 'zafer',
      baslik: 'Zafer Pozu',
      emoji: '✌️',
      talimat: 'Kameraya iki parmağınla barış / zafer işareti yap',
    ),
    KanitJesti(
      id: 'onay',
      baslik: 'Süper / Onay',
      emoji: '👍',
      talimat: 'Başparmağını kaldırarak onay pozu ver',
    ),
    KanitJesti(
      id: 'avuc',
      baslik: 'Açık Avuç',
      emoji: '🖐️',
      talimat: 'Açık avucunu kameraya doğru göster',
    ),
    KanitJesti(
      id: 'kas',
      baslik: 'Kas Göster',
      emoji: '💪',
      talimat: 'Pazunu sıkarak enerjini göster',
    ),
    KanitJesti(
      id: 'rock',
      baslik: 'Rock Pozu',
      emoji: '🤟',
      talimat: 'Rock / metal işareti yap',
    ),
    KanitJesti(
      id: 'bir',
      baslik: '1 Numara',
      emoji: '☝️',
      talimat: 'İşaret parmağını havaya kaldır',
    ),
    KanitJesti(
      id: 'tamam',
      baslik: 'Kusursuz',
      emoji: '👌',
      talimat: 'Baş ve işaret parmağını birleştirerek tamam işareti yap',
    ),
  ];

  /// Havuzdan rastgele bir jest seçer.
  static KanitJesti rastgeleJestSec() {
    return (List<KanitJesti>.from(jestler)..shuffle()).first;
  }
}
