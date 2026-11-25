// lib/ozellikler/toplu_rutinler/veri/firestore_grup_servisi.dart

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../cekirdek/hatalar/merkezi_kaydedici.dart';
import '../alan/grup_kanit_modeli.dart';
import '../alan/grup_mesaj_modeli.dart';
import '../alan/grup_modeli.dart';
import '../alan/grup_rutin_modeli.dart';
import '../alan/grup_uyesi_modeli.dart';
import '../alan/toplu_rutin_modeli.dart';
import '../alan/rutin_hareketi_modeli.dart';

final firestoreGrupServisiSaglayici = Provider<FirestoreGrupServisi>((ref) {
  return FirestoreGrupServisi();
});

/// Firebase Firestore üzerinde toplu rutinler, canlı sohbet, kanıt paylaşımı,
/// yarış panoları ve liderlik tablosunu yöneten ana servis.
class FirestoreGrupServisi {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestoreGrupServisi({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  /// Aktif kullanıcının kimliğini döner. Oturum açık değilse anonim giriş yapar.
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

  /// 6 karakterli rastgele benzersiz bir davet kodu üretir (Örn: "SNAV26").
  String _davetKoduUret() {
    const karakterler = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rastgele = Random();
    return List.generate(
      6,
      (index) => karakterler[rastgele.nextInt(karakterler.length)],
    ).join();
  }

  // ==========================================
  // TOPLU RUTİN İŞLEMLERİ (Rutin Bazlı Katılım)
  // ==========================================

  /// Kullanıcının dahil olduğu toplu rutinleri canlı dinler.
  Stream<List<TopluRutinModeli>> kullaniciRutinleriniDinle(String kullaniciId) {
    return _firestore
        .collection('toplu_rutinler')
        .where('uyeIdleri', arrayContains: kullaniciId)
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => TopluRutinModeli.haritadan(doc.data(), doc.id))
          .toList();
    }).handleError((hata, yiginIzi) {
      MerkeziKaydedici.hataYaz('Kullanıcı rutinleri dinlenirken hata', hata: hata, yiginIzi: yiginIzi);
      return <TopluRutinModeli>[];
    });
  }

  /// Yeni bir toplu rutin oluşturur.
  Future<TopluRutinModeli> rutinOlustur({
    required String baslik,
    required String aciklama,
    required String kategori,
    required List<RutinHareketiModeli> hareketler,
    required String kurucuAdi,
    List<String> hedefGunler = const ['1', '2', '3', '4', '5', '6', '7'],
  }) async {
    final uid = await mevcutKullaniciKimligiAl();
    final rutinRef = _firestore.collection('toplu_rutinler').doc();
    final davetKodu = _davetKoduUret();

    final yeniRutin = TopluRutinModeli(
      id: rutinRef.id,
      baslik: baslik,
      aciklama: aciklama,
      kategori: kategori,
      davetKodu: davetKodu,
      kurucuKullaniciId: uid,
      yoneticiIdleri: [uid],
      uyeIdleri: [uid],
      hedefGunler: hedefGunler,
      hareketler: hareketler,
      mevcutSeriGun: 1,
      olusturulmaTarihi: DateTime.now(),
    );

    await rutinRef.set(yeniRutin.haritaya());

    // Kurucu üyeyi rutinin üyeler tablosuna ekle
    await rutinRef.collection('uyeler').doc(uid).set({
      'kullaniciId': uid,
      'kullaniciAdi': kurucuAdi,
      'rol': 'kurucu',
      'toplamPuan': 0,
      'mevcutSeri': 1,
      'tamamlananGorevSayisi': 0,
      'tamamlananGunSayisi': 0,
      'katilmaTarihi': DateTime.now().toIso8601String(),
    });

    // Açılış sistem mesajı gönder
    await rutinRef.collection('mesajlar').add({
      'rutinId': rutinRef.id,
      'grupId': rutinRef.id,
      'gonderenId': 'sistem',
      'gonderenAdi': 'Sistem',
      'tur': 'sistem',
      'metin': '🎉 "$baslik" rutini başarıyla oluşturuldu! Arkadaşlarını davet etmek için kod: $davetKodu',
      'tarih': DateTime.now().toIso8601String(),
      'durum': 'iletildi',
      'sabitlendiMi': false,
    });

    return yeniRutin;
  }

  /// 6 haneli davet kodunu kullanarak bir rutine katılır.
  Future<TopluRutinModeli?> kodaGoreRutineKatil({
    required String davetKodu,
    required String kullaniciAdi,
  }) async {
    final temizKod = davetKodu.trim().toUpperCase();
    final uid = await mevcutKullaniciKimligiAl();

    final sorgu = await _firestore
        .collection('toplu_rutinler')
        .where('davetKodu', isEqualTo: temizKod)
        .limit(1)
        .get();

    if (sorgu.docs.isEmpty) return null;

    final doc = sorgu.docs.first;
    final rutin = TopluRutinModeli.haritadan(doc.data(), doc.id);

    if (!rutin.uyeIdleri.contains(uid)) {
      await doc.reference.update({
        'uyeIdleri': FieldValue.arrayUnion([uid]),
      });

      await doc.reference.collection('uyeler').doc(uid).set({
        'kullaniciId': uid,
        'kullaniciAdi': kullaniciAdi,
        'rol': 'uye',
        'toplamPuan': 0,
        'mevcutSeri': 1,
        'tamamlananGorevSayisi': 0,
        'tamamlananGunSayisi': 0,
        'katilmaTarihi': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      // Sohbete hoş geldin mesajı at
      await doc.reference.collection('mesajlar').add({
        'rutinId': doc.id,
        'grupId': doc.id,
        'gonderenId': 'sistem',
        'gonderenAdi': 'Sistem',
        'tur': 'sistem',
        'metin': '👋 @$kullaniciAdi davet koduyla rutine katıldı!',
        'tarih': DateTime.now().toIso8601String(),
        'durum': 'iletildi',
        'sabitlendiMi': false,
      });
    }

    return rutin;
  }

  /// Bir alt hareketi tamamlar ve kullanıcının puanını günceller.
  Future<void> hareketTamamla({
    required String rutinId,
    required String hareketId,
    required int kazanilanPuan,
    required String kullaniciAdi,
  }) async {
    final uid = await mevcutKullaniciKimligiAl();
    final rutinRef = _firestore.collection('toplu_rutinler').doc(rutinId);
    final doc = await rutinRef.get();
    if (!doc.exists) return;

    final rutin = TopluRutinModeli.haritadan(doc.data()!, doc.id);
    final guncelHareketler = rutin.hareketler.map((h) {
      if (h.id == hareketId && !h.bugunTamamlayanUyeIdleri.contains(uid)) {
        return h.kopyala(
          bugunTamamlayanUyeIdleri: [...h.bugunTamamlayanUyeIdleri, uid],
        );
      }
      return h;
    }).toList();

    await rutinRef.update({
      'hareketler': guncelHareketler.map((h) => h.haritaya()).toList(),
    });

    // Üyenin puanını artır
    await rutinRef.collection('uyeler').doc(uid).set({
      'toplamPuan': FieldValue.increment(kazanilanPuan),
      'tamamlananGorevSayisi': FieldValue.increment(1),
    }, SetOptions(merge: true));
  }

  /// Çekilen kanıt fotoğrafını Firestore'a ve sohbete işler.
  Future<void> kanitKaydetVeSohbeteAt({
    required GrupKanitModeli kanit,
    required int kazanilanPuan,
  }) async {
    final rutinId = kanit.rutinId.isNotEmpty ? kanit.rutinId : kanit.grupId;
    final rutinRef = _firestore.collection('toplu_rutinler').doc(rutinId);

    // 1. Kanıtlar koleksiyonuna ekle
    final kanitDocRef = await rutinRef.collection('kanitlar').add(kanit.haritayaDonustur());

    // 2. Üye puanını ve tamamlanan görev sayısını güncelle
    await rutinRef.collection('uyeler').doc(kanit.kullaniciId).set({
      'toplamPuan': FieldValue.increment(kazanilanPuan),
      'tamamlananGorevSayisi': FieldValue.increment(1),
    }, SetOptions(merge: true));

    // 3. Sohbete başarı kanıt kartı olarak at
    final guncelKanit = GrupKanitModeli(
      id: kanitDocRef.id,
      grupId: rutinId,
      rutinId: rutinId,
      rutinBasligi: kanit.rutinBasligi,
      kullaniciId: kanit.kullaniciId,
      kullaniciAdi: kanit.kullaniciAdi,
      fotoUrl: kanit.fotoUrl,
      istenenDinamikPoz: kanit.istenenDinamikPoz,
      kanitTuru: kanit.kanitTuru,
      kanitDamgasi: kanit.kanitDamgasi,
      aiOnaylandiMi: kanit.aiOnaylandiMi,
      aiGuvenSkoru: kanit.aiGuvenSkoru,
      aiGeriBildirimi: kanit.aiGeriBildirimi,
      tarih: kanit.tarih,
      reaksiyonlar: kanit.reaksiyonlar,
    );

    final mesaj = GrupMesajModeli(
      id: '',
      grupId: rutinId,
      gonderenId: kanit.kullaniciId,
      gonderenAdi: kanit.kullaniciAdi,
      tur: 'kanit_karti',
      metin: '📸 ${kanit.rutinBasligi} kanıtını yükledi! (+ $kazanilanPuan Puan)',
      kanit: guncelKanit,
      tarih: DateTime.now(),
      durum: MesajGonderimDurumu.gonderildi,
      sabitlendiMi: false,
    );

    await rutinRef.collection('mesajlar').add(mesaj.haritayaDonustur());
  }

  // ==========================================
  // SOHBET & MESAJ SABİTLEME (Pin) İŞLEMLERİ
  // ==========================================

  /// Canlı sohbet akışını dinler (Yerel kuyruktaki mesajlar durumunu bildirir).
  Stream<List<GrupMesajModeli>> mesajlariDinle(String rutinId) {
    return _firestore
        .collection('toplu_rutinler')
        .doc(rutinId)
        .collection('mesajlar')
        .orderBy('tarih', descending: false)
        .snapshots(includeMetadataChanges: true)
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final beklemede = doc.metadata.hasPendingWrites;
        return GrupMesajModeli.haritadanUret(doc.data(), doc.id, yerelBeklemedeMi: beklemede);
      }).toList();
    }).handleError((e, yiginIzi) {
      MerkeziKaydedici.hataYaz('Mesajlar dinlenirken hata', hata: e, yiginIzi: yiginIzi);
      return <GrupMesajModeli>[];
    });
  }

  /// Sohbete yeni bir mesaj gönderir.
  Future<void> mesajGonder({
    required String rutinId,
    required String metin,
    required String gonderenAdi,
  }) async {
    final uid = await mevcutKullaniciKimligiAl();
    final mesaj = GrupMesajModeli(
      id: '',
      grupId: rutinId,
      gonderenId: uid,
      gonderenAdi: gonderenAdi,
      tur: 'metin',
      metin: metin,
      tarih: DateTime.now(),
      durum: MesajGonderimDurumu.gonderildi,
      sabitlendiMi: false,
    );

    await _firestore
        .collection('toplu_rutinler')
        .doc(rutinId)
        .collection('mesajlar')
        .add(mesaj.haritayaDonustur());
  }

  /// Sohbette bir mesajı başa sabitler (Pin 📌).
  Future<void> mesajSabitle({
    required String rutinId,
    required String mesajId,
    required String metin,
    required String gonderenAdi,
  }) async {
    await _firestore.collection('toplu_rutinler').doc(rutinId).update({
      'sabitlenmisMesaj': {
        'id': mesajId,
        'metin': metin,
        'gonderenKullaniciAdi': gonderenAdi,
        'tarih': DateTime.now().toIso8601String(),
      },
    });

    await _firestore
        .collection('toplu_rutinler')
        .doc(rutinId)
        .collection('mesajlar')
        .doc(mesajId)
        .update({'sabitlendiMi': true});
  }

  /// Sabitlenmiş mesajı kaldırır (Unpin).
  Future<void> mesajSabitlemeKaldir(String rutinId) async {
    await _firestore.collection('toplu_rutinler').doc(rutinId).update({
      'sabitlenmisMesaj': FieldValue.delete(),
    });
  }

  // ==========================================
  // SÜRELİ YARIŞ (Sprint / Lig) İŞLEMLERİ
  // ==========================================

  /// Rutin içinde süreli bir yarış başlatır (Örn: 10 günlük yarış).
  Future<void> yarisBaslat({
    required String rutinId,
    required String baslik,
    required int gunSayisi,
    required int hedefPuan,
    required String baslatanKullaniciAdi,
  }) async {
    final simdi = DateTime.now();
    final bitis = simdi.add(Duration(days: gunSayisi));

    final yarisVerisi = {
      'id': 'yaris_${simdi.millisecondsSinceEpoch}',
      'baslik': baslik,
      'baslangicTarihi': simdi.toIso8601String(),
      'bitisTarihi': bitis.toIso8601String(),
      'gunSayisi': gunSayisi,
      'hedefPuan': hedefPuan,
      'tamamlandiMi': false,
    };

    await _firestore.collection('toplu_rutinler').doc(rutinId).update({
      'aktifYaris': yarisVerisi,
    });

    // Sohbete yarış duyurusu at
    await _firestore
        .collection('toplu_rutinler')
        .doc(rutinId)
        .collection('mesajlar')
        .add({
      'rutinId': rutinId,
      'grupId': rutinId,
      'gonderenId': 'sistem',
      'gonderenAdi': 'Sistem',
      'tur': 'yaris_duyurusu',
      'metin': '🏁 @$baslatanKullaniciAdi "$baslik" yarışını başlattı! Süre: $gunSayisi Gün. Kim kazanacak?',
      'tarih': simdi.toIso8601String(),
      'durum': 'iletildi',
      'sabitlendiMi': false,
    });
  }

  // ==========================================
  // RUTİN BİLGİSİ, ÜYE VE YÖNETİM AYARLARI
  // ==========================================

  /// Rutinin üyeler listesini dinler.
  Stream<List<GrupUyesiModeli>> uyeleriDinle(String rutinId) {
    return _firestore
        .collection('toplu_rutinler')
        .doc(rutinId)
        .collection('uyeler')
        .orderBy('toplamPuan', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => GrupUyesiModeli.haritadanUret(doc.data(), doc.id))
          .toList();
    }).handleError((e) {
      return <GrupUyesiModeli>[];
    });
  }

  Stream<List<GrupUyesiModeli>> grupUyeleriniDinle(String grupId) => uyeleriDinle(grupId);

  /// Rutin bilgilerini ve izinlerini günceller.
  Future<void> rutinGuncelle(TopluRutinModeli rutin) async {
    await _firestore.collection('toplu_rutinler').doc(rutin.id).update(rutin.haritaya());
  }

  /// Bir üyeyi rutinden çıkarır (Yönetici yetkisi).
  Future<void> uyeCikar(String rutinId, String uyeId) async {
    await _firestore.collection('toplu_rutinler').doc(rutinId).update({
      'uyeIdleri': FieldValue.arrayRemove([uyeId]),
      'yoneticiIdleri': FieldValue.arrayRemove([uyeId]),
    });
    await _firestore
        .collection('toplu_rutinler')
        .doc(rutinId)
        .collection('uyeler')
        .doc(uyeId)
        .delete();
  }

  /// Kullanıcının kendi isteğiyle rutinden ayrılması.
  Future<void> rutindenAyril(String rutinId) async {
    final uid = await mevcutKullaniciKimligiAl();
    await uyeCikar(rutinId, uid);
  }

  // ==========================================
  // ESKİ V1 METODLARI (Geriye Uyumluluk Köprüsü)
  // ==========================================

  Stream<List<GrupModeli>> kullaniciGruplariniDinle() async* {
    final uid = await mevcutKullaniciKimligiAl();
    yield* _firestore
        .collection('gruplar')
        .where('uyeIdleri', arrayContains: uid)
        .snapshots()
        .map((s) => s.docs.map((d) => GrupModeli.haritadanUret(d.data(), d.id)).toList());
  }

  Stream<List<GrupModeli>> kullanicininGruplariniDinle(String kullaniciId) {
    return _firestore
        .collection('gruplar')
        .where('uyeIdleri', arrayContains: kullaniciId)
        .snapshots()
        .map((s) => s.docs.map((d) => GrupModeli.haritadanUret(d.data(), d.id)).toList());
  }

  Stream<List<GrupRutinModeli>> grupRutinleriniDinle(String grupId) {
    return _firestore
        .collection('gruplar')
        .doc(grupId)
        .collection('rutinler')
        .snapshots()
        .map((s) => s.docs.map((d) => GrupRutinModeli.haritadanUret(d.data(), d.id)).toList());
  }

  Stream<List<GrupMesajModeli>> grupMesajlariniDinle(String grupId) {
    return mesajlariDinle(grupId);
  }

  Future<GrupModeli> grupOlustur({
    required String ad,
    required String aciklama,
    required String kurucuAdi,
  }) async {
    final uid = await mevcutKullaniciKimligiAl();
    final ref = _firestore.collection('gruplar').doc();
    final davetKodu = _davetKoduUret();
    final grup = GrupModeli(
      id: ref.id,
      ad: ad,
      aciklama: aciklama,
      davetKodu: davetKodu,
      olusturanKullaniciId: uid,
      uyeIdleri: [uid],
      olusturmaTarihi: DateTime.now(),
    );
    await ref.set(grup.haritayaDonustur());
    return grup;
  }

  Future<GrupModeli> davetKoduylaGrubaKatil({
    required String davetKodu,
    required String kullaniciAdi,
  }) async {
    final uid = await mevcutKullaniciKimligiAl();
    final sorgu = await _firestore.collection('gruplar').where('davetKodu', isEqualTo: davetKodu.trim().toUpperCase()).limit(1).get();
    if (sorgu.docs.isEmpty) throw Exception('Grup bulunamadı');
    final doc = sorgu.docs.first;
    await doc.reference.update({'uyeIdleri': FieldValue.arrayUnion([uid])});
    return GrupModeli.haritadanUret(doc.data(), doc.id);
  }

  Future<void> grupRutiniEkle(GrupRutinModeli rutin) async {
    await _firestore.collection('gruplar').doc(rutin.grupId).collection('rutinler').add(rutin.haritayaDonustur());
  }

  Future<void> mesajaTepkiVer({
    required String grupId,
    required String mesajId,
    required String emoji,
    required String kullaniciId,
  }) async {
    final ref = _firestore.collection('toplu_rutinler').doc(grupId).collection('mesajlar').doc(mesajId);
    final doc = await ref.get();
    if (!doc.exists) return;
    final mesaj = GrupMesajModeli.haritadanUret(doc.data()!, doc.id);
    final guncel = mesaj.tepkiGuncelle(emoji, kullaniciId);
    await ref.update({'tepkiler': guncel.tepkiler});
  }
}
