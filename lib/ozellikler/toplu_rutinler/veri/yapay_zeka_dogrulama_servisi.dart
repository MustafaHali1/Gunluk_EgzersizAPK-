// lib/ozellikler/toplu_rutinler/veri/yapay_zeka_dogrulama_servisi.dart

import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../../cekirdek/hatalar/merkezi_kaydedici.dart';
import '../../../cekirdek/sabitler/gizli_anahtarlar.dart';

/// Yapay zeka fotoğraf analizi sonucunu temsil eden model.
class YapayZekaDogrulamaSonucu {
  final bool onaylandiMi;
  final bool eylemTespitEdildiMi;
  final bool jestTespitEdildiMi;
  final double guvenSkoru;
  final String aciklama;
  final bool sosyalFallbackMi; // Ağ veya API hatasında kullanıcıyı kilitlemeyen güven modu

  const YapayZekaDogrulamaSonucu({
    required this.onaylandiMi,
    required this.eylemTespitEdildiMi,
    required this.jestTespitEdildiMi,
    required this.guvenSkoru,
    required this.aciklama,
    this.sosyalFallbackMi = false,
  });

  factory YapayZekaDogrulamaSonucu.sosyalFallback(String aciklama) {
    return YapayZekaDogrulamaSonucu(
      onaylandiMi: true,
      eylemTespitEdildiMi: true,
      jestTespitEdildiMi: true,
      guvenSkoru: 0.8,
      aciklama: aciklama,
      sosyalFallbackMi: true,
    );
  }

  factory YapayZekaDogrulamaSonucu.varsayilanBasarisiz(String hataMesaji) {
    return YapayZekaDogrulamaSonucu(
      onaylandiMi: false,
      eylemTespitEdildiMi: false,
      jestTespitEdildiMi: false,
      guvenSkoru: 0.0,
      aciklama: hataMesaji,
      sosyalFallbackMi: false,
    );
  }
}

/// Gemini Flash Multimodal API kullanarak nesneleri ve jestleri şimşek hızında doğrulayan servis.
class YapayZekaDogrulamaServisi {
  /// Fotoğraf baytlarını ve görev/nesne/jest bilgilerini Gemini Flash'a gönderip inceler.
  Future<YapayZekaDogrulamaSonucu> fotografiDenetle({
    required Uint8List fotoBaytlari,
    required String rutinBasligi,
    required String gorevBasligi,
    String? beklenenNesne,
    String? istenenJest,
    bool kurtarmaJestiMi = false,
  }) async {
    final apiAnahtari = GizliAnahtarlar.geminiApiKey;
    if (apiAnahtari.isEmpty || apiAnahtari.contains('BURAYA')) {
      // API anahtarı girilmemişse kullanıcıyı engelleme, sosyal onaya devret
      return YapayZekaDogrulamaSonucu.sosyalFallback(
        'Gemini API anahtarı tanımlanmamış, kanıt grubun denetimine bırakılarak onaylandı ✅',
      );
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiAnahtari',
    );

    final resimBase64 = base64Encode(fotoBaytlari);

    final komutIstemi = '''
Sen motive edici, kullanıcı dostu bir sağlık ve spor denetçisisin.
Kullanıcının kanıt fotoğrafını incele.

Görev Bilgisi:
- Rutin: "$rutinBasligi"
- Yapılan Hareket/Görev: "$gorevBasligi"
${beklenenNesne != null && !kurtarmaJestiMi ? '- Beklenen Nesne/Bağlam: "$beklenenNesne"' : ''}
${istenenJest != null ? '- İstenen Canlı Poz/Jest: "$istenenJest"' : ''}
${kurtarmaJestiMi ? '- Not: Kullanıcı nesne yanında olmadığı için canlı jest ile tamamlama seçeneğini kullandı.' : ''}

Kural ve Tolerans:
1. Kullanıcıyı haksız yere reddetme. Amacımız stüdyo fotoğrafı çekmek değil, günlük motivasyondur.
2. Fotoğraf tamamen boş bir duvar, tavan, siyah ekran veya belirgin bir aldatmaca DEĞİLSE; fotoğrafta ilgili nesne (fırça, bardak, kitap vb.) veya spor çabası/jesti görünüyorsa ONAYLA.

Cevabını YALNIZCA geçerli bir JSON olarak ver. Markdown etiketi ekleme.
Format:
{
  "onaylandiMi": true,
  "guvenSkoru": 0.95,
  "aciklama": "Harika! Görev başarıyla doğrulandı."
}
''';

    final istekGovdesi = jsonEncode({
      "contents": [
        {
          "parts": [
            {"text": komutIstemi},
            {
              "inline_data": {
                "mime_type": "image/jpeg",
                "data": resimBase64,
              }
            }
          ]
        }
      ],
      "generationConfig": {
        "temperature": 0.2,
        "response_mime_type": "application/json",
      }
    });

    try {
      final yanit = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: istekGovdesi,
          )
          .timeout(const Duration(seconds: 4)); // 4 saniye içinde dönmezse fallback

      if (yanit.statusCode == 200) {
        final cozulmus = jsonDecode(yanit.body);
        final adayMetin = cozulmus['candidates']?[0]?['content']?['parts']?[0]?['text'] as String?;
        if (adayMetin != null) {
          final jsonSonuc = jsonDecode(adayMetin);
          final bool onaylandi = jsonSonuc['onaylandiMi'] as bool? ?? true;
          final double guven = (jsonSonuc['guvenSkoru'] as num?)?.toDouble() ?? 0.9;
          final String aciklama = jsonSonuc['aciklama'] as String? ?? 'Görev doğrulandı.';

          return YapayZekaDogrulamaSonucu(
            onaylandiMi: onaylandi,
            eylemTespitEdildiMi: onaylandi,
            jestTespitEdildiMi: onaylandi,
            guvenSkoru: guven,
            aciklama: aciklama,
          );
        }
      }

      // 200 dışı kodlarda veya ayrıştırma hatasında çökme, sosyal güven moduna devret
      return YapayZekaDogrulamaSonucu.sosyalFallback(
        'Yapay zeka ağı meşgul, kanıt grubun denetimine bırakılarak onaylandı ✅',
      );
    } catch (hata, yiginIzi) {
      MerkeziKaydedici.hataYaz('Gemini Flash doğrulama çağrısında hata, fallback devreye girdi', hata: hata, yiginIzi: yiginIzi);
      // Ağ hatasında kullanıcıyı asla kilitleme
      return YapayZekaDogrulamaSonucu.sosyalFallback(
        'Bağlantı zayıf, kanıt grubun denetimine bırakılarak onaylandı ✅',
      );
    }
  }
}
