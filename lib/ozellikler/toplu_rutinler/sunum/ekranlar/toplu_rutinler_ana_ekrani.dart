// lib/ozellikler/toplu_rutinler/sunum/ekranlar/toplu_rutinler_ana_ekrani.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../alan/kullanici_profili_modeli.dart';
import '../../alan/rutin_hareketi_modeli.dart';
import '../bilesenler/kullanici_adi_secme_dialogu.dart';
import '../bilesenler/rutin_akordiyon_karti.dart';
import '../bilesenler/rutin_olusturma_formu.dart';
import '../kontrolculer/grup_kontrolcusu.dart';
import '../kontrolculer/kullanici_profil_kontrolcusu.dart';
import 'kanit_kamera_ekrani.dart';
import 'rutin_detay_merkezi_ekrani.dart';

/// Toplu rutinler ana vitrin ekranı.
/// Thin UI prensibine uygundur; tüm durum ve veri kontrolcüler tarafından sağlanır.
class TopluRutinlerAnaEkrani extends ConsumerStatefulWidget {
  const TopluRutinlerAnaEkrani({super.key});

  @override
  ConsumerState<TopluRutinlerAnaEkrani> createState() => _TopluRutinlerAnaEkraniState();
}

class _TopluRutinlerAnaEkraniState extends ConsumerState<TopluRutinlerAnaEkrani> {
  bool _dialogGosterildi = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _profilKontrolEt();
  }

  void _profilKontrolEt() {
    final profilAsync = ref.read(aktifKullaniciProfiliSaglayici);
    profilAsync.whenData((profil) {
      if (profil == null && !_dialogGosterildi && mounted) {
        _dialogGosterildi = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) KullaniciAdiSecmeDialogu.goster(context, zorunluMu: true);
        });
      }
    });
  }

  void _kodaGoreKatilDialogu() {
    final kodDenetleyici = TextEditingController();
    bool yukleniyor = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.key, color: Colors.teal),
              SizedBox(width: 8),
              Text('Koda Göre Rutine Katıl'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Arkadaşının paylaştığı 6 haneli davet kodunu gir:'),
              const SizedBox(height: 12),
              TextField(
                controller: kodDenetleyici,
                textCapitalization: TextCapitalization.characters,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 4),
                decoration: InputDecoration(
                  hintText: 'SNAV26',
                  counterText: '',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Vazgeç'),
            ),
            ElevatedButton(
              onPressed: yukleniyor
                  ? null
                  : () async {
                      final kod = kodDenetleyici.text.trim();
                      if (kod.length < 6) return;
                      setDState(() => yukleniyor = true);

                      final rutin = await ref.read(topluRutinKontrolcusuSaglayici).kodaGoreKatil(kod);
                      if (context.mounted) {
                        Navigator.pop(ctx);
                        if (rutin != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Tebrikler! "${rutin.baslik}" rutinine katıldın 🎉'),
                              backgroundColor: Colors.teal.shade700,
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Davet kodu bulunamadı veya geçersiz.')),
                          );
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, foregroundColor: Colors.white),
              child: yukleniyor
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : const Text('Katıl'),
            ),
          ],
        ),
      ),
    );
  }

  void _rutinOlusturModal() {
    RutinOlusturmaFormu.goster(
      context,
      onKaydet: ({
        required String baslik,
        required String aciklama,
        required String kategori,
        required List<RutinHareketiModeli> hareketler,
      }) async {
        await ref.read(topluRutinKontrolcusuSaglayici).rutinKur(
              baslik: baslik,
              aciklama: aciklama,
              kategori: kategori,
              hareketler: hareketler,
            );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"$baslik" toplu rutini oluşturuldu! 🚀'),
              backgroundColor: Colors.teal.shade700,
            ),
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<KullaniciProfiliModeli?>>(aktifKullaniciProfiliSaglayici, (onceki, sonraki) {
      if (!_dialogGosterildi && sonraki.hasValue && sonraki.value == null && mounted) {
        _dialogGosterildi = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) KullaniciAdiSecmeDialogu.goster(context, zorunluMu: true);
        });
      }
    });

    final profilAsync = ref.watch(aktifKullaniciProfiliSaglayici);
    final rutinlerAsync = ref.watch(kullaniciRutinleriSaglayici);
    final uid = ref.watch(mevcutKullaniciIdSaglayici).value ?? '';

    final profil = profilAsync.value;
    final kullaniciAdi = profil?.kullaniciAdi ?? 'Kullanıcı';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Toplu Rutinler'),
        actions: [
          // Kullanıcı Adı ve Profil Rozeti
          InkWell(
            onTap: () => KullaniciAdiSecmeDialogu.goster(context, zorunluMu: false, mevcutAd: kullaniciAdi),
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.teal.shade100,
                    child: Text(
                      kullaniciAdi.isNotEmpty ? kullaniciAdi[0].toUpperCase() : 'U',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '@$kullaniciAdi',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: rutinlerAsync.when(
        data: (rutinler) {
          if (rutinler.isEmpty) {
            return _bosDurumEkrani();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(kullaniciRutinleriSaglayici);
            },
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 8, bottom: 90),
              itemCount: rutinler.length,
              itemBuilder: (context, index) {
                final rutin = rutinler[index];
                return RutinAkordiyonKarti(
                  rutin: rutin,
                  mevcutKullaniciId: uid,
                  onKanitlaTiklandi: (hareket) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => KanitKameraEkrani(
                          rutin: rutin,
                          hareket: hareket,
                        ),
                      ),
                    );
                  },
                  onHizliTikTiklandi: (hareket) {
                    ref.read(topluRutinKontrolcusuSaglayici).hareketTamamla(
                          rutinId: rutin.id,
                          hareketId: hareket.id,
                          puan: hareket.puan,
                        );
                  },
                  onDetayaGitTiklandi: () {
                    ref.read(seciliTopluRutinSaglayici.notifier).sec(rutin);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => RutinDetayMerkeziEkrani(rutin: rutin),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Yükleme hatası: $e')),
      ),
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'kodla_katil',
            onPressed: _kodaGoreKatilDialogu,
            icon: const Icon(Icons.key),
            label: const Text('Koda Göre Katıl'),
            backgroundColor: Colors.teal.shade700,
            foregroundColor: Colors.white,
          ),
          const SizedBox(width: 12),
          FloatingActionButton.extended(
            heroTag: 'yeni_rutin',
            onPressed: _rutinOlusturModal,
            icon: const Icon(Icons.add),
            label: const Text('Yeni Rutin'),
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
          ),
        ],
      ),
    );
  }

  Widget _bosDurumEkrani() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.teal.shade50,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.groups_3_outlined, size: 64, color: Colors.teal),
            ),
            const SizedBox(height: 20),
            const Text(
              'Henüz Bir Toplu Rutinin Yok!',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Ailen veya arkadaşlarınla birlikte hedeflere koşmak için yeni bir rutin kurabilir veya paylaşılan 6 haneli kodla bir rutine katılabilirsin.',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _kodaGoreKatilDialogu,
                  icon: const Icon(Icons.key),
                  label: const Text('Koda Göre Katıl'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  onPressed: _rutinOlusturModal,
                  icon: const Icon(Icons.add),
                  label: const Text('Yeni Rutin Kur'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
