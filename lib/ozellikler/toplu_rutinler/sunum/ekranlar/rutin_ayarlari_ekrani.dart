// lib/ozellikler/toplu_rutinler/sunum/ekranlar/rutin_ayarlari_ekrani.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../alan/toplu_rutin_modeli.dart';
import '../kontrolculer/grup_kontrolcusu.dart';

/// WhatsApp "Grup Bilgisi" tarzı rutin yönetimi, üye listesi ve yetki ayarları ekranı.
class RutinAyarlariEkrani extends ConsumerStatefulWidget {
  final TopluRutinModeli rutin;

  const RutinAyarlariEkrani({
    super.key,
    required this.rutin,
  });

  @override
  ConsumerState<RutinAyarlariEkrani> createState() => _RutinAyarlariEkraniState();
}

class _RutinAyarlariEkraniState extends ConsumerState<RutinAyarlariEkrani> {
  late bool _yalnizcaYoneticiHareket;
  late bool _yalnizcaYoneticiDuzenleme;

  @override
  void initState() {
    super.initState();
    _yalnizcaYoneticiHareket = widget.rutin.yalnizcaYoneticiHareketEkleyebilir;
    _yalnizcaYoneticiDuzenleme = widget.rutin.yalnizcaYoneticiDuzenleyebilir;
  }

  void _izinleriKaydet() {
    final guncelRutin = widget.rutin.kopyala(
      yalnizcaYoneticiHareketEkleyebilir: _yalnizcaYoneticiHareket,
      yalnizcaYoneticiDuzenleyebilir: _yalnizcaYoneticiDuzenleme,
    );
    ref.read(topluRutinKontrolcusuSaglayici).rutinGuncelle(guncelRutin);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Rutin ayarları kaydedildi ✅')),
    );
  }

  void _rutindenAyrilOnay() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rutinden Ayrıl?'),
        content: Text('"${widget.rutin.baslik}" rutininden ayrılmak istediğine emin misin?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('İptal')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx); // Dialogu kapat
              Navigator.pop(context); // Ayarlar ekranını kapat
              Navigator.pop(context); // Detay ekranını kapatıp vitrine dön
              await ref.read(topluRutinKontrolcusuSaglayici).rutindenAyril(widget.rutin.id);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Ayrıl'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uyelerAsync = ref.watch(rutinUyeleriSaglayici(widget.rutin.id));
    final uid = ref.watch(mevcutKullaniciIdSaglayici).value ?? '';
    final yoneticiMi = widget.rutin.yoneticiIdleri.contains(uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutin Bilgisi & İzinler'),
        actions: [
          if (yoneticiMi)
            IconButton(
              icon: const Icon(Icons.check),
              tooltip: 'Kaydet',
              onPressed: _izinleriKaydet,
            ),
        ],
      ),
      body: ListView(
        children: [
          // ÜST BAŞLIK ALANI
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
            color: Colors.teal.shade50,
            alignment: Alignment.center,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.teal,
                  child: Text(
                    widget.rutin.baslik.isNotEmpty ? widget.rutin.baslik[0].toUpperCase() : 'R',
                    style: const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  widget.rutin.baslik,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Toplu Rutin • ${widget.rutin.uyeIdleri.length} Katılımcı',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: widget.rutin.davetKodu));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Davet kodu kopyalandı: ${widget.rutin.davetKodu}')),
                    );
                  },
                  icon: const Icon(Icons.copy, size: 16),
                  label: Text('Davet Kodu: ${widget.rutin.davetKodu}'),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // WHATSAPP TARZI RUTİN İZİNLERİ
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Rutin İzinleri (Yönetici Ayarları)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.teal),
            ),
          ),
          SwitchListTile(
            title: const Text('Yalnızca Yöneticiler Hareket Ekleyebilir'),
            subtitle: const Text('Kapalıysa tüm üyeler rutine yeni alt egzersiz ekleyebilir.'),
            value: _yalnizcaYoneticiHareket,
            onChanged: yoneticiMi ? (v) => setState(() => _yalnizcaYoneticiHareket = v) : null,
          ),
          SwitchListTile(
            title: const Text('Yalnızca Yöneticiler Bilgileri Düzenleyebilir'),
            subtitle: const Text('Başlık, açıklama ve kapak görselini sadece yöneticiler değiştirir.'),
            value: _yalnizcaYoneticiDuzenleme,
            onChanged: yoneticiMi ? (v) => setState(() => _yalnizcaYoneticiDuzenleme = v) : null,
          ),

          const Divider(),

          // SOHBETİ SESSİZE AL
          ListTile(
            leading: const Icon(Icons.notifications_off_outlined),
            title: const Text('Bildirimleri Sessize Al'),
            subtitle: const Text('Sohbet mesajlarını sessize al'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sohbet bildirimleri 8 saat sessize alındı 🔕')),
              );
            },
          ),

          const Divider(),

          // KATILIMCILAR LİSTESİ
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Katılımcılar (${widget.rutin.uyeIdleri.length})',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.teal),
            ),
          ),

          uyelerAsync.when(
            data: (uyeler) {
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: uyeler.length,
                itemBuilder: (context, index) {
                  final uye = uyeler[index];
                  final buUyeYoneticiMi = widget.rutin.yoneticiIdleri.contains(uye.kullaniciId);

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal.shade100,
                      child: Text(
                        uye.gorunenAd.isNotEmpty ? uye.gorunenAd[0].toUpperCase() : 'U',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
                      ),
                    ),
                    title: Text('@${uye.gorunenAd}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${uye.toplamPuan} Puan • 🔥 ${uye.mevcutSeri} Gün'),
                    trailing: buUyeYoneticiMi
                        ? const Chip(label: Text('Yönetici', style: TextStyle(fontSize: 10, color: Colors.teal)))
                        : (yoneticiMi && uye.kullaniciId != uid)
                            ? IconButton(
                                icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                                tooltip: 'Üyeyi Çıkar',
                                onPressed: () {
                                  ref.read(topluRutinKontrolcusuSaglayici).uyeCikar(widget.rutin.id, uye.kullaniciId);
                                },
                              )
                            : null,
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Hata: $e')),
          ),

          const SizedBox(height: 20),

          // RUTİNDEN AYRIL BUTONU
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ElevatedButton.icon(
              onPressed: _rutindenAyrilOnay,
              icon: const Icon(Icons.exit_to_app),
              label: const Text('Rutinden Ayrıl'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade50,
                foregroundColor: Colors.red,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
