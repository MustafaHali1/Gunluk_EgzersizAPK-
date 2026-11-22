// lib/ozellikler/toplu_rutinler/veri/supabase_depolama_servisi.dart

import 'dart:typed_data';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../cekirdek/hatalar/merkezi_kaydedici.dart';
import '../../../cekirdek/sabitler/gizli_anahtarlar.dart';

/// Çekilen kanıt fotoğraflarını Supabase Storage üzerindeki 'kanitlar' kovasına yükleyen servis.
class SupabaseDepolamaServisi {
  static bool _baslatildi = false;

  /// Supabase istemcisini başlatır (eğer henüz başlatılmadıysa).
  static Future<void> baslat() async {
    if (_baslatildi) return;
    try {
      await Supabase.initialize(
        url: GizliAnahtarlar.supabaseUrl,
        publishableKey: GizliAnahtarlar.supabaseAnonKey,
      );
      _baslatildi = true;
      MerkeziKaydedici.bilgiYaz('Supabase Depolama Servisi başarıyla bağlandı.');
    } catch (hata, yiginIzi) {
      MerkeziKaydedici.hataYaz(
        'Supabase başlatılırken hata oluştu',
        hata: hata,
        yiginIzi: yiginIzi,
      );
    }
  }

  /// Verilen fotoğraf baytlarını Supabase Storage'a yükler ve genel erişim bağlantısını döner.
  Future<String> kanitFotografiYukle({
    required Uint8List fotoBaytlari,
    required String grupId,
    required String kullaniciId,
  }) async {
    await baslat();

    try {
      final zamanDamgasi = DateTime.now().millisecondsSinceEpoch;
      final dosyaYolu = 'grup_$grupId/${kullaniciId}_$zamanDamgasi.jpg';

      final istemci = Supabase.instance.client;
      await istemci.storage.from(GizliAnahtarlar.supabaseKovaAdi).uploadBinary(
            dosyaYolu,
            fotoBaytlari,
            fileOptions: const FileOptions(
              contentType: 'image/jpeg',
              upsert: true,
            ),
          );

      final genelUrl = istemci.storage
          .from(GizliAnahtarlar.supabaseKovaAdi)
          .getPublicUrl(dosyaYolu);

      MerkeziKaydedici.bilgiYaz('Kanıt fotoğrafı yüklendi: $genelUrl');
      return genelUrl;
    } catch (hata, yiginIzi) {
      MerkeziKaydedici.hataYaz(
        'Kanıt fotoğrafı yüklenirken hata oluştu',
        hata: hata,
        yiginIzi: yiginIzi,
      );
      rethrow;
    }
  }
}
