// lib/ozellikler/toplu_rutinler/veri/firestore_grup_servisi.dart

import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../cekirdek/hatalar/merkezi_kaydedici.dart';
import '../alan/grup_kanit_modeli.dart';
import '../alan/grup_mesaj_modeli.dart';
import '../alan/grup_modeli.dart';
import '../alan/grup_rutin_modeli.dart';
import '../alan/grup_uyesi_modeli.dart';

/// Firebase Firestore üzerinde grup oluşturma, rutin ekleme, canlı sohbet,
/// kanıt paylaşımı ve liderlik tablosunu yöneten servis.
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

    // Güvenli yerel kullanıcı kimliği yedeği (asla takılmaz veya çökmez)
    final tercihler = await SharedPreferences.getInstance();
    String? yerelId = tercihler.getString('yerel_toplu_kullanici_id');
    if (yerelId == null) {
      yerelId = 'kul_${DateTime.now().millisecondsSinceEpoch}_${Random().nextInt(9999)}';
      await tercihler.setString('yerel_toplu_kullanici_id', yerelId);
    }
    return yerelId;
  }

  /// 6 karakterli rastgele benzersiz bir davet kodu üretir (Örn: "HL8924").
  String _davetKoduUret() {
    const karakterler = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rastgele = Random();
    return List.generate(
      6,
      (index) => karakterler[rastgele.nextInt(karakterler.length)],
    ).join();
  }

  /// Yeni bir grup oluşturur ve oluşturan kişiyi kurucu üye olarak kaydeder.
  Future<GrupModeli> grupOlustur({
    required String ad,
    required String aciklama,
    required String kurucuAdi,
  }) async {
    try {
      final kullaniciId = await mevcutKullaniciKimligiAl();
      final grupRef = _firestore.collection('gruplar').doc();
      final davetKodu = _davetKoduUret();

      final yeniGrup = GrupModeli(
        id: grupRef.id,
        ad: ad,
        aciklama: aciklama,
        davetKodu: davetKodu,
        olusturanKullaniciId: kullaniciId,
        uyeIdleri: [kullaniciId],
        olusturmaTarihi: DateTime.now(),
        aktifMi: true,
      );

      await grupRef.set(yeniGrup.haritayaDonustur());

      // Kurucuyu üyeler alt koleksiyonuna ekle
      final kurucuUye = GrupUyesiModeli(
        id: kullaniciId,
        kullaniciId: kullaniciId,
        gorunenAd: kurucuAdi,
        rol: 'kurucu',
        toplamPuan: 0,
        mevcutSeri: 0,
        enUzunSeri: 0,
        tamamlananGorevSayisi: 0,
        katilmaTarihi: DateTime.now(),
      );

      await grupRef
          .collection('uyeler')
          .doc(kullaniciId)
          .set(kurucuUye.haritayaDonustur());

      // İlk karşılama mesajını sohbete bırak
      await mesajGonder(
        grupId: grupRef.id,
        metin: '🎉 "$ad" grubu kuruldu! Katılım Kodu: $davetKodu',
        gonderenId: 'sistem',
        gonderenAdi: 'Sistem',
        tur: 'sistem',
      );

      MerkeziKaydedici.bilgiYaz('Grup başarıyla oluşturuldu: ${yeniGrup.ad}');
      return yeniGrup;
    } catch (hata, yiginIzi) {
      MerkeziKaydedici.hataYaz('Grup oluşturulurken hata oluştu', hata: hata, yiginIzi: yiginIzi);
      rethrow;
    }
  }

  /// 6 haneli davet koduna göre grubu bulup kullanıcıyı üye olarak ekler.
  Future<GrupModeli> davetKoduylaGrubaKatil({
    required String davetKodu,
    required String kullaniciAdi,
  }) async {
    try {
      final kullaniciId = await mevcutKullaniciKimligiAl();
      final temizKod = davetKodu.trim().toUpperCase();

      final sorgu = await _firestore
          .collection('gruplar')
          .where('davetKodu', isEqualTo: temizKod)
          .limit(1)
          .get();

      if (sorgu.docs.isEmpty) {
        throw Exception('Geçersiz davet kodu! Grup bulunamadı.');
      }

      final grupDoc = sorgu.docs.first;
      final grup = GrupModeli.haritadanUret(grupDoc.data(), grupDoc.id);

      final uyeRef = grupDoc.reference.collection('uyeler').doc(kullaniciId);
      final uyeSnap = await uyeRef.get();

      if (!uyeSnap.exists) {
        final yeniUye = GrupUyesiModeli(
          id: kullaniciId,
          kullaniciId: kullaniciId,
          gorunenAd: kullaniciAdi,
          rol: 'uye',
          katilmaTarihi: DateTime.now(),
        );
        await uyeRef.set(yeniUye.haritayaDonustur());

        // Ana grup belgesindeki üye listesine de ekle
        await grupDoc.reference.update({
          'uyeIdleri': FieldValue.arrayUnion([kullaniciId]),
        });

        // Sohbete katılım duyurusu gönder
        await mesajGonder(
          grupId: grup.id,
          metin: '👋 $kullaniciAdi gruba katıldı! Hoş geldin!',
          gonderenId: 'sistem',
          gonderenAdi: 'Sistem',
          tur: 'sistem',
        );
      }

      return grup;
    } catch (hata, yiginIzi) {
      MerkeziKaydedici.hataYaz('Gruba katılırken hata oluştu', hata: hata, yiginIzi: yiginIzi);
      rethrow;
    }
  }

  /// Kullanıcının üyesi olduğu tüm grupları canlı dinler.
  Stream<List<GrupModeli>> kullanicininGruplariniDinle(String kullaniciId) {
    return _firestore
        .collection('gruplar')
        .where('uyeIdleri', arrayContains: kullaniciId)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GrupModeli.haritadanUret(doc.data(), doc.id))
            .toList());
  }

  /// Gruba ait rutinleri canlı akış olarak getirir.
  Stream<List<GrupRutinModeli>> grupRutinleriniDinle(String grupId) {
    return _firestore
        .collection('gruplar')
        .doc(grupId)
        .collection('rutinler')
        .where('aktifMi', isEqualTo: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GrupRutinModeli.haritadanUret(doc.data(), doc.id))
            .toList());
  }

  /// Gruba yeni bir rutin (örn: Diş Fırçalama) ekler.
  Future<void> grupRutiniEkle(GrupRutinModeli rutin) async {
    try {
      final ref = _firestore
          .collection('gruplar')
          .doc(rutin.grupId)
          .collection('rutinler')
          .doc();

      final eklenecek = GrupRutinModeli(
        id: ref.id,
        grupId: rutin.grupId,
        baslik: rutin.baslik,
        aciklama: rutin.aciklama,
        kategori: rutin.kategori,
        hedefGunler: rutin.hedefGunler,
        puanDegeri: rutin.puanDegeri,
        olusturmaTarihi: DateTime.now(),
      );

      await ref.set(eklenecek.haritayaDonustur());
      MerkeziKaydedici.bilgiYaz('Gruba yeni rutin eklendi: ${rutin.baslik}');
    } catch (hata, yiginIzi) {
      MerkeziKaydedici.hataYaz('Rutin eklenirken hata oluştu', hata: hata, yiginIzi: yiginIzi);
      rethrow;
    }
  }

  /// Grup üyelerini toplam puanlarına göre azalan sıralamada (liderlik tablosu) canlı dinler.
  Stream<List<GrupUyesiModeli>> grupUyeleriniDinle(String grupId) {
    return _firestore
        .collection('gruplar')
        .doc(grupId)
        .collection('uyeler')
        .orderBy('toplamPuan', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GrupUyesiModeli.haritadanUret(doc.data(), doc.id))
            .toList());
  }

  /// Yapay zeka onayından geçen kanıtı kaydeder, üyenin puanını artırır
  /// ve grup sohbetine otomatik başarı kartı gönderir.
  Future<void> kanitKaydetVeSohbeteAt({
    required GrupKanitModeli kanit,
    int kazanilanPuan = 10,
  }) async {
    try {
      final grupRef = _firestore.collection('gruplar').doc(kanit.grupId);

      // 1. Kanıt kaydını koleksiyona ekle
      final kanitRef = grupRef.collection('kanitlar').doc();
      final kaydedilenKanit = GrupKanitModeli(
        id: kanitRef.id,
        grupId: kanit.grupId,
        rutinId: kanit.rutinId,
        rutinBasligi: kanit.rutinBasligi,
        kullaniciId: kanit.kullaniciId,
        kullaniciAdi: kanit.kullaniciAdi,
        fotoUrl: kanit.fotoUrl,
        istenenDinamikPoz: kanit.istenenDinamikPoz,
        aiOnaylandiMi: kanit.aiOnaylandiMi,
        aiGuvenSkoru: kanit.aiGuvenSkoru,
        aiGeriBildirimi: kanit.aiGeriBildirimi,
        tarih: kanit.tarih,
      );
      await kanitRef.set(kaydedilenKanit.haritayaDonustur());

      // 2. Üyenin puanını ve serisini güncelle
      final uyeRef = grupRef.collection('uyeler').doc(kanit.kullaniciId);
      await _firestore.runTransaction((transaction) async {
        final uyeSnap = await transaction.get(uyeRef);
        if (uyeSnap.exists) {
          final mevcutPuan = (uyeSnap.data()?['toplamPuan'] as num?)?.toInt() ?? 0;
          final tamamlanan = (uyeSnap.data()?['tamamlananGorevSayisi'] as num?)?.toInt() ?? 0;
          final seri = (uyeSnap.data()?['mevcutSeri'] as num?)?.toInt() ?? 0;

          transaction.update(uyeRef, {
            'toplamPuan': mevcutPuan + kazanilanPuan,
            'tamamlananGorevSayisi': tamamlanan + 1,
            'mevcutSeri': seri + 1,
          });
        }
      });

      // 3. Sohbete başarı kanıt kartını fırlat
      await mesajGonder(
        grupId: kanit.grupId,
        metin: '🌟 ${kanit.kullaniciAdi} "${kanit.rutinBasligi}" rutinini tamamladı ve kanıtladı!',
        gonderenId: kanit.kullaniciId,
        gonderenAdi: kanit.kullaniciAdi,
        tur: 'kanit_karti',
        kanit: kaydedilenKanit,
      );

      MerkeziKaydedici.bilgiYaz('Kanıt başarıyla işlendi ve sohbete paylaşıldı.');
    } catch (hata, yiginIzi) {
      MerkeziKaydedici.hataYaz('Kanıt işlenirken hata oluştu', hata: hata, yiginIzi: yiginIzi);
      rethrow;
    }
  }

  /// Canlı grup sohbetine metin veya kanıt kartı mesajı gönderir.
  Future<void> mesajGonder({
    required String grupId,
    required String metin,
    required String gonderenId,
    required String gonderenAdi,
    String tur = 'metin',
    GrupKanitModeli? kanit,
  }) async {
    try {
      final mesajRef = _firestore
          .collection('gruplar')
          .doc(grupId)
          .collection('mesajlar')
          .doc();

      final yeniMesaj = GrupMesajModeli(
        id: mesajRef.id,
        grupId: grupId,
        gonderenId: gonderenId,
        gonderenAdi: gonderenAdi,
        tur: tur,
        metin: metin,
        kanit: kanit,
        tepkiler: const {},
        tarih: DateTime.now(),
      );

      await mesajRef.set(yeniMesaj.haritayaDonustur());
    } catch (hata, yiginIzi) {
      MerkeziKaydedici.hataYaz('Mesaj gönderilirken hata oluştu', hata: hata, yiginIzi: yiginIzi);
      rethrow;
    }
  }

  /// Grup sohbet akışını tarihe göre azalan sırayla canlı dinler.
  Stream<List<GrupMesajModeli>> grupMesajlariniDinle(String grupId) {
    return _firestore
        .collection('gruplar')
        .doc(grupId)
        .collection('mesajlar')
        .orderBy('tarih', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GrupMesajModeli.haritadanUret(doc.data(), doc.id))
            .toList());
  }

  /// Sohbetteki bir mesaja/kanıt kartına emoji tepkisi (Örn: 🔥, 👏, 💪) bırakır veya kaldırır.
  Future<void> mesajaTepkiVer({
    required String grupId,
    required String mesajId,
    required String emoji,
    required String kullaniciId,
  }) async {
    try {
      final mesajRef = _firestore
          .collection('gruplar')
          .doc(grupId)
          .collection('mesajlar')
          .doc(mesajId);

      await _firestore.runTransaction((transaction) async {
        final snap = await transaction.get(mesajRef);
        if (snap.exists && snap.data() != null) {
          final model = GrupMesajModeli.haritadanUret(snap.data()!, snap.id);
          final guncel = model.tepkiGuncelle(emoji, kullaniciId);
          transaction.update(mesajRef, {'tepkiler': guncel.tepkiler});
        }
      });
    } catch (hata, yiginIzi) {
      MerkeziKaydedici.hataYaz('Emoji tepkisi eklenirken hata oluştu', hata: hata, yiginIzi: yiginIzi);
    }
  }
}
