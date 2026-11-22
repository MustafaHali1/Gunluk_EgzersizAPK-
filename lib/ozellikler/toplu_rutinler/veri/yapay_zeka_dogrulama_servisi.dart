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

  const YapayZekaDogrulamaSonucu({
    required this.onaylandiMi,
    required this.eylemTespitEdildiMi,
    required this.jestTespitEdildiMi,
    required this.guvenSkoru,
    required this.aciklama,
  });

  factory YapayZekaDogrulamaSonucu.varsayilanBasarisiz(String hataMesaji) {
    return YapayZekaDogrulamaSonucu(
      onaylandiMi: false,
      eylemTespitEdildiMi: false,
      jestTespitEdildiMi: false,
      guvenSkoru: 0.0,
      aciklama: hataMesaji,
    );
  }
}

/// Gemini Multimodal Vision API kullanarak hem eylemi hem de anlık dinamik jesti doğrulayan servis.
class YapayZekaDogrulamaServisi {
  /// Fotoğraf baytlarını ve beklenen rutin bilgilerini Gemini Vision API'ye gönderip denetler.
  Future<YapayZekaDogrulamaSonucu> fotografiDenetle({
    required Uint8List fotoBaytlari,
    required String rutinBasligi,
    required String istenenJest,
  }) async {
    final apiAnahtari = GizliAnahtarlar.geminiApiKey;
    if (apiAnahtari.isEmpty || apiAnahtari.contains('BURAYA')) {
      return YapayZekaDogrulamaSonucu.varsayilanBasarisiz(
        'Gemini API anahtarı tanımlanmamış.',
      );
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent?key=$apiAnahtari',
    );

    final resimBase64 = base64Encode(fotoBaytlari);

    final komutIstemi = '''
Sen bir alışkanlık, sağlık ve spor takip uygulamasının yapay zeka denetçisisin.
Kullanıcının gönderdiği fotoğrafı çok dikkatli bir şekilde incele.

İki ana kriteri kontrol et:
1. Eylem: Fotoğrafta "$rutinBasligi" eylemi veya eylemle ilgili nesneler (örneğin diş fırçası, spor duruşu, su bardağı vb.) görünüyor mu?
2. Dinamik Jest/Poz: Kullanıcı fotoğrafta anlık olarak istenen şu el/vücut jestini yapmış mı: "$istenenJest"?

Cevabını YALNIZCA geçerli bir JSON nesnesi olarak ver. Markdown bloğu veya ek yazı ekleme. Format şu şekilde olmalıdır:
{
  "eylemTespitEdildiMi": true,
  "jestTespitEdildiMi": true,
  "onaylandiMi": true,
  "guvenSkoru": 0.95,
  "aciklama": "Diş fırçası ve istenen 2 parmak zafer işareti başarıyla tespit edildi."
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
      final yanit = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: istekGovdesi,
      );

      if (yanit.statusCode == 200) {
        final cozulenYanit = jsonDecode(yanit.body);
        final adaylar = cozulenYanit['candidates'] as List?;
        if (adaylar != null && adaylar.isNotEmpty) {
          final metin = adaylar[0]['content']['parts'][0]['text'] as String? ?? '';
          final jsonSonuc = jsonDecode(metin) as Map<String, dynamic>;

          final eylemVarMi = jsonSonuc['eylemTespitEdildiMi'] as bool? ?? false;
          final jestVarMi = jsonSonuc['jestTespitEdildiMi'] as bool? ?? false;
          final onaylandiMi = jsonSonuc['onaylandiMi'] as bool? ?? (eylemVarMi && jestVarMi);
          final guvenSkoru = (jsonSonuc['guvenSkoru'] as num?)?.toDouble() ?? 1.0;
          final aciklama = jsonSonuc['aciklama'] as String? ?? 'Analiz tamamlandı.';

          return YapayZekaDogrulamaSonucu(
            onaylandiMi: onaylandiMi,
            eylemTespitEdildiMi: eylemVarMi,
            jestTespitEdildiMi: jestVarMi,
            guvenSkoru: guvenSkoru,
            aciklama: aciklama,
          );
        }
      }

      MerkeziKaydedici.hataYaz(
        'Gemini API Hatası: ${yanit.statusCode}',
        hata: yanit.body,
      );
      return YapayZekaDogrulamaSonucu.varsayilanBasarisiz(
        'Yapay zeka analizi yapılamadı (Hata Kodu: ${yanit.statusCode}).',
      );
    } catch (hata, yiginIzi) {
      MerkeziKaydedici.hataYaz(
        'Yapay zeka servisi çağrılırken hata oluştu',
        hata: hata,
        yiginIzi: yiginIzi,
      );
      return YapayZekaDogrulamaSonucu.varsayilanBasarisiz(
        'Yapay zeka servisine bağlanırken bir sorun oluştu.',
      );
    }
  }
}
