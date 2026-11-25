// lib/ozellikler/toplu_rutinler/sunum/ekranlar/rutin_detay_merkezi_ekrani.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../alan/toplu_rutin_modeli.dart';
import '../../alan/rutin_hareketi_modeli.dart';
import '../../alan/grup_mesaj_modeli.dart';
import '../bilesenler/canli_yaris_cubugu.dart';
import '../bilesenler/sabitlenmis_mesaj_seridi.dart';
import '../bilesenler/kanit_karti_bileseni.dart';
import '../kontrolculer/grup_kontrolcusu.dart';
import '../kontrolculer/grup_sohbet_kontrolcusu.dart';
import '../kontrolculer/kullanici_profil_kontrolcusu.dart';
import '../kontrolculer/rutin_yaris_kontrolcusu.dart';
import 'kanit_kamera_ekrani.dart';
import 'rutin_ayarlari_ekrani.dart';

/// Toplu Rutin içi 4 sekmeli modern detay ve deneyim merkezi.
/// Thin UI kuralına uygundur; mantık kontrolcülerdedir.
class RutinDetayMerkeziEkrani extends ConsumerStatefulWidget {
  final TopluRutinModeli rutin;

  const RutinDetayMerkeziEkrani({
    super.key,
    required this.rutin,
  });

  @override
  ConsumerState<RutinDetayMerkeziEkrani> createState() => _RutinDetayMerkeziEkraniState();
}

class _RutinDetayMerkeziEkraniState extends ConsumerState<RutinDetayMerkeziEkrani>
    with SingleTickerProviderStateMixin {
  late final TabController _sekmeDenetleyici;
  final TextEditingController _mesajDenetleyici = TextEditingController();
  final ScrollController _sohbetKaydirici = ScrollController();

  @override
  void initState() {
    super.initState();
    _sekmeDenetleyici = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _sekmeDenetleyici.dispose();
    _mesajDenetleyici.dispose();
    _sohbetKaydirici.dispose();
    super.dispose();
  }

  void _kameraAc(RutinHareketiModeli hareket, String mevcutKullaniciId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => KanitKameraEkrani(
          rutin: widget.rutin,
          hareket: hareket,
        ),
      ),
    );
  }

  void _yarisBaslatDialogu() {
    final baslikController = TextEditingController(text: '10 Günlük Meydan Okuma');
    int gun = 10;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yeni Süreli Yarış Başlat 🏁'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: baslikController,
              decoration: const InputDecoration(labelText: 'Yarış Başlığı'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: gun,
              decoration: const InputDecoration(labelText: 'Yarış Süresi'),
              items: const [
                DropdownMenuItem(value: 7, child: Text('7 Günlük Sprint')),
                DropdownMenuItem(value: 10, child: Text('10 Günlük Yarış (Önerilen)')),
                DropdownMenuItem(value: 14, child: Text('14 Günlük Lig')),
                DropdownMenuItem(value: 30, child: Text('30 Günlük Maraton')),
              ],
              onChanged: (v) => gun = v ?? 10,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Vazgeç')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(rutinYarisKontrolcusuSaglayici).yarisBaslat(
                    rutinId: widget.rutin.id,
                    baslik: baslikController.text.trim(),
                    gunSayisi: gun,
                    hedefPuan: 500,
                  );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
            child: const Text('Başlat 🚀'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(mevcutKullaniciIdSaglayici).value ?? '';
    final profil = ref.watch(aktifKullaniciProfiliSaglayici).value;
    final kullaniciAdi = profil?.kullaniciAdi ?? 'Kullanıcı';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.rutin.baslik, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(
              'Kod: ${widget.rutin.davetKodu} • ${widget.rutin.uyeIdleri.length} Üye',
              style: const TextStyle(fontSize: 11, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Kodu Kopyala',
            onPressed: () {
              Clipboard.setData(ClipboardData(text: widget.rutin.davetKodu));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Davet kodu kopyalandı: ${widget.rutin.davetKodu}')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: 'Rutin Bilgisi ve İzinler',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => RutinAyarlariEkrani(rutin: widget.rutin),
                ),
              );
            },
          ),
        ],
        bottom: TabBar(
          controller: _sekmeDenetleyici,
          indicatorColor: Colors.amber,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          tabs: const [
            Tab(icon: Icon(Icons.checklist, size: 20), text: 'Görevler'),
            Tab(icon: Icon(Icons.photo_library_outlined, size: 20), text: 'Kanıtlar'),
            Tab(icon: Icon(Icons.chat_outlined, size: 20), text: 'Sohbet'),
            Tab(icon: Icon(Icons.leaderboard_outlined, size: 20), text: 'Liderlik'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _sekmeDenetleyici,
        children: [
          // 1. SEKME: GÖREVLER
          _gorevlerSekmesi(uid),

          // 2. SEKME: KANITLAR DUVARI
          _kanitlarSekmesi(uid),

          // 3. SEKME: SOHBET (Yarış Panosu + Sabit Mesaj + WhatsApp Tikleri)
          _sohbetSekmesi(uid, kullaniciAdi),

          // 4. SEKME: LİDERLİK & DEVAMLILIK ORANI (20/20 gün)
          _liderlikSekmesi(uid),
        ],
      ),
    );
  }

  // ==========================================
  // 1. GÖREVLER SEKMESİ
  // ==========================================
  Widget _gorevlerSekmesi(String uid) {
    final hareketler = widget.rutin.hareketler;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 12),
      children: [
        // Canlı Yarış Panosu
        CanliYarisCubugu(
          yarisVerisi: widget.rutin.aktifYaris,
          onYarisBaslatTiklandi: _yarisBaslatDialogu,
        ),

        const SizedBox(height: 8),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: Text(
            'Bugünün Hareketleri (${hareketler.length}):',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),

        ...hareketler.map((hareket) {
          final yapildiMi = hareket.bugunTamamlayanUyeIdleri.contains(uid);

          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: yapildiMi ? Colors.green.shade50 : Colors.teal.shade50,
                child: yapildiMi
                    ? const Icon(Icons.check, color: Colors.green)
                    : Icon(
                        hareket.nesneGerektirirMi ? Icons.inventory_2_outlined : Icons.fitness_center,
                        color: Colors.teal,
                      ),
              ),
              title: Text(
                hareket.baslik,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  decoration: yapildiMi ? TextDecoration.lineThrough : null,
                ),
              ),
              subtitle: Text(
                '${hareket.puan} Puan ${hareket.nesneGerektirirMi && hareket.beklenenNesneAdi != null ? '• 📦 ${hareket.beklenenNesneAdi}' : ''}',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
              trailing: yapildiMi
                  ? const Chip(
                      label: Text('Tamam ✅', style: TextStyle(color: Colors.green, fontSize: 11)),
                      backgroundColor: Color(0xFFE8F5E9),
                    )
                  : ElevatedButton.icon(
                      onPressed: () => _kameraAc(hareket, uid),
                      icon: const Icon(Icons.camera_alt, size: 14),
                      label: const Text('Kanıtla'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
            ),
          );
        }),
      ],
    );
  }

  // ==========================================
  // 2. KANITLAR DUVARI SEKMESİ
  // ==========================================
  Widget _kanitlarSekmesi(String uid) {
    final mesajlarAsync = ref.watch(rutinMesajlariSaglayici(widget.rutin.id));

    return mesajlarAsync.when(
      data: (mesajlar) {
        final kanitMesajlari = mesajlar.where((m) => m.tur == 'kanit_karti' && m.kanit != null).toList().reversed.toList();

        if (kanitMesajlari.isEmpty) {
          return const Center(
            child: Text('Henüz kimse kanıt fotoğrafı yüklemedi.\nİlk alevi sen yak! 🔥', textAlign: TextAlign.center),
          );
        }

        return ListView.builder(
          itemCount: kanitMesajlari.length,
          itemBuilder: (context, index) {
            final mesaj = kanitMesajlari[index];
            return KanitKartiBileseni(
              mesaj: mesaj,
              mevcutKullaniciId: uid,
              onTepkiVer: (_) {},
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Hata: $e')),
    );
  }

  // ==========================================
  // 3. SOHBET SEKMESİ
  // ==========================================
  Widget _sohbetSekmesi(String uid, String kullaniciAdi) {
    final mesajlarAsync = ref.watch(rutinMesajlariSaglayici(widget.rutin.id));

    return Column(
      children: [
        // ÜST SABİT YARIŞ ÇUBUĞU
        if (widget.rutin.aktifYaris != null)
          CanliYarisCubugu(
            yarisVerisi: widget.rutin.aktifYaris,
            onYarisBaslatTiklandi: _yarisBaslatDialogu,
          ),

        // SABİTLENMİŞ MESAJ ŞERİDİ (Pin 📌)
        if (widget.rutin.sabitlenmisMesaj != null)
          SabitlenmisMesajSeridi(
            sabitlenmisMesaj: widget.rutin.sabitlenmisMesaj!,
            onTiklandi: () {},
            onSabitlemeKaldir: () => ref.read(grupSohbetKontrolcusuSaglayici).mesajSabitlemeKaldir(widget.rutin.id),
          ),

        // MESAJ LİSTESİ
        Expanded(
          child: mesajlarAsync.when(
            data: (mesajlar) {
              if (mesajlar.isEmpty) {
                return const Center(child: Text('Sohbet odasına ilk mesajı sen yaz! 👋'));
              }

              return ListView.builder(
                controller: _sohbetKaydirici,
                itemCount: mesajlar.length,
                itemBuilder: (context, index) {
                  final m = mesajlar[index];
                  final benimMi = m.gonderenId == uid;

                  if (m.tur == 'kanit_karti') {
                    return KanitKartiBileseni(mesaj: m, mevcutKullaniciId: uid, onTepkiVer: (_) {});
                  }

                  return Align(
                    alignment: benimMi ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: benimMi ? Colors.teal.shade500 : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: benimMi ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                        children: [
                          if (!benimMi)
                            Text(
                              '@${m.gonderenAdi}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.teal.shade900,
                              ),
                            ),
                          Text(
                            m.metin,
                            style: TextStyle(
                              color: benimMi ? Colors.white : Colors.black87,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${m.tarih.hour.toString().padLeft(2, '0')}:${m.tarih.minute.toString().padLeft(2, '0')}',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: benimMi ? Colors.white70 : Colors.black45,
                                ),
                              ),
                              if (benimMi) ...[
                                const SizedBox(width: 4),
                                _tikIkonu(m.durum),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Hata: $e')),
          ),
        ),

        // MESAJ YAZMA ALANI
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _mesajDenetleyici,
                  decoration: const InputDecoration(
                    hintText: 'Bir mesaj yazın...',
                    border: InputBorder.none,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.teal),
                onPressed: () {
                  final text = _mesajDenetleyici.text;
                  _mesajDenetleyici.clear();
                  ref.read(grupSohbetKontrolcusuSaglayici).mesajGonder(
                        rutinId: widget.rutin.id,
                        metin: text,
                      );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _tikIkonu(MesajGonderimDurumu durum) {
    switch (durum) {
      case MesajGonderimDurumu.beklemede:
        return const Icon(Icons.access_time, size: 12, color: Colors.white70);
      case MesajGonderimDurumu.gonderildi:
        return const Icon(Icons.check, size: 13, color: Colors.white70);
      case MesajGonderimDurumu.iletildi:
        return const Icon(Icons.done_all, size: 13, color: Colors.amberAccent);
    }
  }

  // ==========================================
  // 4. LİDERLİK & AÇILDIĞINDAN BERİ DEVAMLILIK SEKMESİ
  // ==========================================
  Widget _liderlikSekmesi(String uid) {
    final uyelerAsync = ref.watch(rutinUyeleriSaglayici(widget.rutin.id));
    final toplamGun = widget.rutin.acilisindanBeriGecenGun;

    return uyelerAsync.when(
      data: (uyeler) {
        if (uyeler.isEmpty) return const Center(child: Text('Katılımcı bulunamadı.'));

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Podyum Özeti
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [Colors.teal.shade700, Colors.teal.shade900]),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Text('🏆 LİDERLİK PODYUMU', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (uyeler.length > 1) _podyumBasamagi(uyeler[1], 2, Colors.grey.shade300, 70),
                      if (uyeler.isNotEmpty) _podyumBasamagi(uyeler[0], 1, Colors.amber, 90),
                      if (uyeler.length > 2) _podyumBasamagi(uyeler[2], 3, Colors.brown.shade300, 60),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'Açıldığından Beri Devamlılık Oranı ($toplamGun Gün):',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),

            ...uyeler.map((uye) {
              final tamamlanan = uye.tamamlananGunSayisi;
              final oran = (tamamlanan / toplamGun * 100).toInt();

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.shade50,
                    child: Text(
                      uye.gorunenAd.isNotEmpty ? uye.gorunenAd[0].toUpperCase() : 'U',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                  ),
                  title: Text('@${uye.gorunenAd}', style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('$tamamlanan / $toplamGun Gün Tamamlandı • 🔥 ${uye.mevcutSeri} Gün Seri'),
                  trailing: Text(
                    '%$oran',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: oran >= 80 ? Colors.green : Colors.orange.shade800,
                    ),
                  ),
                ),
              );
            }),
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Hata: $e')),
    );
  }

  Widget _podyumBasamagi(dynamic uye, int sira, Color renk, double yukseklik) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('@${uye.gorunenAd}', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
        const SizedBox(height: 4),
        Container(
          width: 70,
          height: yukseklik,
          decoration: BoxDecoration(
            color: renk,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          ),
          alignment: Alignment.center,
          child: Text(
            '$sira',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
          ),
        ),
      ],
    );
  }
}
