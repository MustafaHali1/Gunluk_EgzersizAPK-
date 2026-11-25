// lib/ozellikler/toplu_rutinler/veri/kullanici_profil_servisi.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cekirdek/hatalar/merkezi_kaydedici.dart';
import '../alan/kullanici_profili_modeli.dart';

final kullaniciProfilServisiSaglayici = Provider<KullaniciProfilServisi>((ref) {
  return KullaniciProfilServisi();
});

/// Firebase Firestore 'kullanicilar' koleksiyonu üzerinden benzersiz kullanıcı adı ve profil işlemlerini yönetir.
class KullaniciProfilServisi {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  KullaniciProfilServisi({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Mevcut oturum açmış kullanıcının kimliğini döner (Yoksa anonim oturum açar).
  Future<String> mevcutKullaniciKimligiAl() async {
    final mevcutKullanici = _auth.currentUser;
    if (mevcutKullanici != null) {
      return mevcutKullanici.uid;
    }
    final sonuc = await _auth.signInAnonymously();
    return sonuc.user!.uid;
  }

  /// Verilen kullanıcı adının sistemde boşta olup olmadığını kontrol eder.
  Future<bool> kullaniciAdiMusaitMi(String kullaniciAdi) async {
    final temizAd = kullaniciAdi.trim().toLowerCase().replaceAll('@', '');
    if (temizAd.isEmpty || temizAd.length < 3) return false;

    try {
      final sonuc = await _firestore
          .collection('kullanicilar')
          .where('kullaniciAdiKucuk', isEqualTo: temizAd)
          .limit(1)
          .get();

      return sonuc.docs.isEmpty;
    } catch (e, yiginIzi) {
      MerkeziKaydedici.hataYaz('Kullanıcı adı müsaitlik kontrolü hatası', hata: e, yiginIzi: yiginIzi);
      return true; // Hata durumunda kullanıcıyı engelleme
    }
  }

  /// Aktif kullanıcının profilini Firestore'a kaydeder veya günceller.
  Future<KullaniciProfiliModeli> profilKaydetVeyaGuncelle(String kullaniciAdi) async {
    final uid = await mevcutKullaniciKimligiAl();
    final temizAd = kullaniciAdi.trim().replaceAll('@', '');
    final temizAdKucuk = temizAd.toLowerCase();

    final profil = KullaniciProfiliModeli(
      kullaniciId: uid,
      kullaniciAdi: temizAd,
      kayitTarihi: DateTime.now(),
    );

    final veri = {
      ...profil.haritaya(),
      'kullaniciAdiKucuk': temizAdKucuk,
    };

    await _firestore.collection('kullanicilar').doc(uid).set(veri, SetOptions(merge: true));

    // Firebase Auth DisplayName'i de güncelle
    try {
      await _auth.currentUser?.updateDisplayName(temizAd);
    } catch (_) {}

    return profil;
  }

  /// Aktif kullanıcının profilini Firestore'dan çeker.
  Future<KullaniciProfiliModeli?> aktifProfiliGetir() async {
    try {
      final uid = await mevcutKullaniciKimligiAl();
      final dokuman = await _firestore.collection('kullanicilar').doc(uid).get();

      if (dokuman.exists && dokuman.data() != null) {
        return KullaniciProfiliModeli.haritadan(dokuman.data()!, dokuman.id);
      }
      return null;
    } catch (e, yiginIzi) {
      MerkeziKaydedici.hataYaz('Aktif profil getirme hatası', hata: e, yiginIzi: yiginIzi);
      return null;
    }
  }

  /// Kullanıcının kazandığı kupa sayısını 1 artırır.
  Future<void> kupaSayisiniArtir(String kullaniciId) async {
    try {
      await _firestore.collection('kullanicilar').doc(kullaniciId).update({
        'kazanilanKupaSayisi': FieldValue.increment(1),
      });
    } catch (e) {
      MerkeziKaydedici.bilgiYaz('Kupa artırma hatası: $e');
    }
  }
}
