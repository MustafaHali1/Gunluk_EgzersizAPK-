// lib/ozellikler/toplu_rutinler/veri/kullanici_profil_servisi.dart

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../cekirdek/hatalar/merkezi_kaydedici.dart';
import '../alan/kullanici_profili_modeli.dart';

final kullaniciProfilServisiSaglayici = Provider<KullaniciProfilServisi>((ref) {
  return KullaniciProfilServisi();
});

/// Firebase Firestore 'kullanicilar' koleksiyonu ve yerel depolama üzerinden
/// benzersiz kullanıcı adı ve profil işlemlerini yönetir (Offline-First & Hata Korumalı).
class KullaniciProfilServisi {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  KullaniciProfilServisi({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Mevcut oturum açmış kullanıcının kimliğini döner.
  /// Oturum açık değilse anonim giriş dener, başarısız olursa güvenli yerel UUID üretir.
  Future<String> mevcutKullaniciKimligiAl() async {
    try {
      User? kullanici = _auth.currentUser;
      if (kullanici == null) {
        final kimlikSonucu = await _auth.signInAnonymously();
        kullanici = kimlikSonucu.user;
      }
      if (kullanici != null) return kullanici.uid;
    } catch (e) {
      MerkeziKaydedici.bilgiYaz('FirebaseAuth anonim girişte hata, yerel UUID kullanılıyor: $e');
    }

    final tercihler = await SharedPreferences.getInstance();
    String? yerelId = tercihler.getString('yerel_toplu_kullanici_id');
    if (yerelId == null) {
      yerelId = 'kul_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';
      await tercihler.setString('yerel_toplu_kullanici_id', yerelId);
    }
    return yerelId;
  }

  /// Verilen kullanıcı adının sistemde boşta olup olmadığını kontrol eder.
  Future<bool> kullaniciAdiMusaitMi(String kullaniciAdi) async {
    final temizAd = kullaniciAdi.trim().toLowerCase().replaceAll('@', '');
    if (temizAd.isEmpty || temizAd.length < 3) return false;

    try {
      final mevcutUid = await mevcutKullaniciKimligiAl();
      final sonuc = await _firestore
          .collection('kullanicilar')
          .where('kullaniciAdiKucuk', isEqualTo: temizAd)
          .limit(2)
          .get();

      // Dokümanlardan herhangi biri başka bir kullanıcıya aitse dolu demektir
      final baskaBiriVarMi = sonuc.docs.any((dokuman) => dokuman.id != mevcutUid);
      return !baskaBiriVarMi;
    } catch (e, yiginIzi) {
      MerkeziKaydedici.hataYaz('Kullanıcı adı müsaitlik kontrolü Firestore uyarısı (yerel izin veriliyor)', hata: e, yiginIzi: yiginIzi);
      return true; // Hata durumunda kullanıcıyı engelleme
    }
  }

  /// Aktif kullanıcının profilini yerel depolamaya ve Firestore'a kaydeder veya günceller.
  Future<KullaniciProfiliModeli> profilKaydetVeyaGuncelle(String kullaniciAdi) async {
    final uid = await mevcutKullaniciKimligiAl();
    final temizAd = kullaniciAdi.trim().replaceAll('@', '');
    final temizAdKucuk = temizAd.toLowerCase();

    final profil = KullaniciProfiliModeli(
      kullaniciId: uid,
      kullaniciAdi: temizAd,
      kayitTarihi: DateTime.now(),
    );

    // 1. Önce SharedPreferences'a yerel olarak kaydet (asla başarısız olmaz)
    try {
      final tercihler = await SharedPreferences.getInstance();
      await tercihler.setString('yerel_kullanici_adi', temizAd);
      await tercihler.setString('yerel_toplu_kullanici_id', uid);
    } catch (e) {
      MerkeziKaydedici.bilgiYaz('Yerel profil kaydetme uyarısı: $e');
    }

    // 2. Firestore ve Firebase Auth'a senkronize etmeyi dene
    try {
      final veri = {
        ...profil.haritaya(),
        'kullaniciAdiKucuk': temizAdKucuk,
      };
      await _firestore.collection('kullanicilar').doc(uid).set(veri, SetOptions(merge: true));
      await _auth.currentUser?.updateDisplayName(temizAd);
    } catch (e, yiginIzi) {
      MerkeziKaydedici.hataYaz('Firestore profil senkronizasyon uyarısı (yerel kayıt korundu)', hata: e, yiginIzi: yiginIzi);
    }

    return profil;
  }

  /// Aktif kullanıcının profilini çeker. Önce Firestore'u dener, hata veya boşlukta SharedPreferences'a bakar.
  Future<KullaniciProfiliModeli?> aktifProfiliGetir() async {
    final uid = await mevcutKullaniciKimligiAl();

    final tercihler = await SharedPreferences.getInstance();
    final yerelAd = tercihler.getString('yerel_kullanici_adi');

    try {
      final dokuman = await _firestore.collection('kullanicilar').doc(uid).get();

      if (dokuman.exists && dokuman.data() != null) {
        final profil = KullaniciProfiliModeli.haritadan(dokuman.data()!, dokuman.id);
        // Yerel önbelleği güncelle
        await tercihler.setString('yerel_kullanici_adi', profil.kullaniciAdi);
        return profil;
      }
    } catch (e) {
      MerkeziKaydedici.bilgiYaz('Aktif profil Firestore okuma uyarısı (yerel profil kontrol ediliyor): $e');
    }

    if (yerelAd != null && yerelAd.isNotEmpty) {
      return KullaniciProfiliModeli(
        kullaniciId: uid,
        kullaniciAdi: yerelAd,
        kayitTarihi: DateTime.now(),
      );
    }

    return null;
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
