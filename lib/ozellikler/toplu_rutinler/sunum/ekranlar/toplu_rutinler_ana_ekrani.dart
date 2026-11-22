// lib/ozellikler/toplu_rutinler/sunum/ekranlar/toplu_rutinler_ana_ekrani.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../alan/grup_modeli.dart';
import '../../alan/grup_rutin_modeli.dart';
import '../kontrolculer/grup_kontrolcusu.dart';
import 'grup_liderlik_ekrani.dart';
import 'grup_sohbet_ekrani.dart';
import 'kanit_kamera_ekrani.dart';

/// Toplu rutinler ana yönetim ve gün içi esnek tamamlama ekranı.
/// İnce Ekran kuralına uygundur; tüm veri ve durum yönetimini GrupKontrolcusu sağlar.
class TopluRutinlerAnaEkrani extends ConsumerStatefulWidget {
  const TopluRutinlerAnaEkrani({super.key});

  @override
  ConsumerState<TopluRutinlerAnaEkrani> createState() => _TopluRutinlerAnaEkraniState();
}

class _TopluRutinlerAnaEkraniState extends ConsumerState<TopluRutinlerAnaEkrani> {
  final String _kullaniciAdi = 'Mustafa';

  @override
  Widget build(BuildContext context) {
    final gruplarAsync = ref.watch(kullaniciGruplariSaglayici);
    final seciliGrup = ref.watch(seciliGrupSaglayici);
    final rutinlerAsync = ref.watch(seciliGrupRutinleriSaglayici);
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Toplu Rutinler'),
        actions: [
          if (seciliGrup != null) ...[
            IconButton(
              icon: const Icon(Icons.share),
              tooltip: 'Davet Kodunu Kopyala',
              onPressed: () {
                Clipboard.setData(ClipboardData(text: seciliGrup.davetKodu));
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Davet kodu kopyalandı: ${seciliGrup.davetKodu}')),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.leaderboard),
              tooltip: 'Sıralama ve Rapor',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GrupLiderlikEkrani(grup: seciliGrup),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.chat_bubble_outline),
              tooltip: 'Grup Sohbeti',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GrupSohbetEkrani(
                      grup: seciliGrup,
                      kullaniciAdi: _kullaniciAdi,
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
      body: gruplarAsync.when(
        data: (gruplar) {
          if (gruplar.isEmpty) {
            return _grupBulunamadiGorunumu(context);
          }

          final aktifGrup = seciliGrup ?? gruplar.first;
          if (seciliGrup == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ref.read(grupKontrolcusuSaglayici).grubuSec(aktifGrup);
            });
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // 1. Grup Seçici & Değiştirici Kart
              _grupSeciciKarti(context, gruplar, aktifGrup),

              const SizedBox(height: 16),

              // 2. Rutin Listesi Başlığı
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '📌 Grubun Günlük Rutinleri',
                    style: tema.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Rutin Ekle'),
                    onPressed: () => _rutinEkleDiyalogu(context, aktifGrup.id),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // 3. Rutin Kartları (Saat Kısıtsız - Anında "Yaptım" Butonu)
              rutinlerAsync.when(
                data: (rutinler) {
                  if (rutinler.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text('Bu grupta henüz bir rutin tanımlanmamış. "Rutin Ekle" butonuna basarak ilk rutini oluşturabilirsiniz!'),
                      ),
                    );
                  }

                  return Column(
                    children: rutinler
                        .map((rutin) => _rutinKarti(context, rutin))
                        .toList(),
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (hata, _) => Text('Rutinler yüklenemedi: $hata'),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (hata, _) => Center(child: Text('Gruplar yüklenemedi: $hata')),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.group_add),
        label: const Text('Grup İşlemleri'),
        onPressed: () => _grupIslemleriSayfasi(context),
      ),
    );
  }

  Widget _grupSeciciKarti(BuildContext context, List<GrupModeli> gruplar, GrupModeli aktifGrup) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.groups, color: Colors.indigo, size: 28),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<GrupModeli>(
                      value: aktifGrup,
                      isExpanded: true,
                      items: gruplar
                          .map((g) => DropdownMenuItem(
                                value: g,
                                child: Text(g.ad, style: const TextStyle(fontWeight: FontWeight.bold)),
                              ))
                          .toList(),
                      onChanged: (yeni) {
                        if (yeni != null) {
                          ref.read(grupKontrolcusuSaglayici).grubuSec(yeni);
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              aktifGrup.aciklama,
              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  Widget _rutinKarti(BuildContext context, GrupRutinModeli rutin) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.indigo.withValues(alpha: 0.15),
              child: const Icon(Icons.check_circle_outline, color: Colors.indigo),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    rutin.baslik,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  if (rutin.aciklama.isNotEmpty)
                    Text(
                      rutin.aciklama,
                      style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant),
                    ),
                  const SizedBox(height: 2),
                  Text(
                    '🏆 +${rutin.puanDegeri} Puan',
                    style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              icon: const Icon(Icons.camera_alt, size: 16),
              label: const Text('Yaptım'),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => KanitKameraEkrani(
                      rutin: rutin,
                      kullaniciAdi: _kullaniciAdi,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _grupBulunamadiGorunumu(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.people_outline, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Henüz bir gruba dahil değilsiniz',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ailenizle veya arkadaşlarınızla ortak rutinler yapmak için yeni bir grup oluşturun veya 6 haneli kod ile katılın.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('Grup Kur'),
                  onPressed: () => _grupKurDiyalogu(context),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  icon: const Icon(Icons.login),
                  label: const Text('Koda Göre Katıl'),
                  onPressed: () => _kodaGoreKatilDiyalogu(context),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _grupIslemleriSayfasi(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add_circle, color: Colors.indigo),
              title: const Text('Yeni Grup Kur'),
              onTap: () {
                Navigator.pop(ctx);
                _grupKurDiyalogu(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.vpn_key, color: Colors.green),
              title: const Text('Davet Koduyla Katıl'),
              onTap: () {
                Navigator.pop(ctx);
                _kodaGoreKatilDiyalogu(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _grupKurDiyalogu(BuildContext context) {
    final adKontrolcusu = TextEditingController();
    final aciklamaKontrolcusu = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Yeni Grup Kur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: adKontrolcusu,
              decoration: const InputDecoration(labelText: 'Grup Adı (Örn: Hali Ailesi)'),
            ),
            TextField(
              controller: aciklamaKontrolcusu,
              decoration: const InputDecoration(labelText: 'Açıklama (Örn: Sağlıklı Yaşam Grubu)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () async {
              if (adKontrolcusu.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              await ref.read(grupKontrolcusuSaglayici).grupOlustur(
                    ad: adKontrolcusu.text.trim(),
                    aciklama: aciklamaKontrolcusu.text.trim(),
                    kurucuAdi: _kullaniciAdi,
                  );
            },
            child: const Text('Oluştur'),
          ),
        ],
      ),
    );
  }

  void _kodaGoreKatilDiyalogu(BuildContext context) {
    final kodKontrolcusu = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Davet Koduyla Katıl'),
        content: TextField(
          controller: kodKontrolcusu,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: '6 Haneli Davet Kodu (Örn: HL8924)',
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () async {
              if (kodKontrolcusu.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              try {
                await ref.read(grupKontrolcusuSaglayici).davetKoduylaKatil(
                      kod: kodKontrolcusu.text.trim(),
                      kullaniciAdi: _kullaniciAdi,
                    );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Gruba başarıyla katıldınız!')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Hata: $e'), backgroundColor: Colors.red),
                  );
                }
              }
            },
            child: const Text('Katıl'),
          ),
        ],
      ),
    );
  }

  void _rutinEkleDiyalogu(BuildContext context, String grupId) {
    final baslikKontrolcusu = TextEditingController();
    final aciklamaKontrolcusu = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Gruba Rutin Ekle'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: baslikKontrolcusu,
              decoration: const InputDecoration(labelText: 'Rutin Adı (Örn: Diş Fırçalama)'),
            ),
            TextField(
              controller: aciklamaKontrolcusu,
              decoration: const InputDecoration(labelText: 'Açıklama (Örn: Sabah ve akşam 2 dk)'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () async {
              if (baslikKontrolcusu.text.trim().isEmpty) return;
              Navigator.pop(ctx);
              await ref.read(grupKontrolcusuSaglayici).grubaRutinEkle(
                    grupId: grupId,
                    baslik: baslikKontrolcusu.text.trim(),
                    aciklama: aciklamaKontrolcusu.text.trim(),
                  );
            },
            child: const Text('Ekle'),
          ),
        ],
      ),
    );
  }
}
