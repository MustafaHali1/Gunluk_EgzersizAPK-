// lib/ozellikler/toplu_rutinler/sunum/ekranlar/grup_sohbet_ekrani.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../alan/grup_modeli.dart';
import '../bilesenler/kanit_karti_bileseni.dart';
import '../kontrolculer/grup_kontrolcusu.dart';
import '../kontrolculer/grup_sohbet_kontrolcusu.dart';

/// WhatsApp benzeri canlı grup sohbeti ve onaylı kanıt kartları akış ekranı.
class GrupSohbetEkrani extends ConsumerStatefulWidget {
  final GrupModeli grup;
  final String kullaniciAdi;

  const GrupSohbetEkrani({
    super.key,
    required this.grup,
    required this.kullaniciAdi,
  });

  @override
  ConsumerState<GrupSohbetEkrani> createState() => _GrupSohbetEkraniState();
}

class _GrupSohbetEkraniState extends ConsumerState<GrupSohbetEkrani> {
  final TextEditingController _metinKontrolcusu = TextEditingController();

  @override
  void dispose() {
    _metinKontrolcusu.dispose();
    super.dispose();
  }

  void _mesajGonder() {
    final metin = _metinKontrolcusu.text;
    if (metin.trim().isEmpty) return;

    ref.read(grupSohbetKontrolcusuSaglayici).mesajGonder(
          grupId: widget.grup.id,
          metin: metin,
          gonderenAdi: widget.kullaniciAdi,
        );
    _metinKontrolcusu.clear();
  }

  @override
  Widget build(BuildContext context) {
    final mesajlarAsync = ref.watch(grupMesajlariSaglayici(widget.grup.id));
    final kullaniciIdAsync = ref.watch(mevcutKullaniciIdSaglayici);
    final tema = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.grup.ad, style: const TextStyle(fontSize: 16)),
            Text(
              'Davet Kodu: ${widget.grup.davetKodu}',
              style: TextStyle(fontSize: 11, color: tema.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // 1. Canlı Mesaj Listesi
          Expanded(
            child: mesajlarAsync.when(
              data: (mesajlar) {
                if (mesajlar.isEmpty) {
                  return const Center(
                    child: Text('Henüz mesaj yok. İlk mesajı sen yaz veya rutinini kanıtla!'),
                  );
                }

                final mevcutKullaniciId = kullaniciIdAsync.value ?? '';

                return ListView.builder(
                  reverse: true, // En yeni mesaj en altta görünür
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: mesajlar.length,
                  itemBuilder: (context, index) {
                    final mesaj = mesajlar[index];

                    // Kanıt Kartı ise
                    if (mesaj.tur == 'kanit_karti') {
                      return KanitKartiBileseni(
                        mesaj: mesaj,
                        mevcutKullaniciId: mevcutKullaniciId,
                        onTepkiVer: (emoji) {
                          ref.read(grupSohbetKontrolcusuSaglayici).tepkiVer(
                                grupId: widget.grup.id,
                                mesajId: mesaj.id,
                                emoji: emoji,
                              );
                        },
                      );
                    }

                    // Sistem Duyurusu ise
                    if (mesaj.tur == 'sistem') {
                      return Center(
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: tema.colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            mesaj.metin,
                            style: TextStyle(
                              fontSize: 12,
                              color: tema.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      );
                    }

                    // Normal Kullanıcı Metin Mesajı
                    final benimMesajim = mesaj.gonderenId == mevcutKullaniciId;
                    return Align(
                      alignment: benimMesajim ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: benimMesajim
                              ? tema.colorScheme.primary
                              : tema.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: benimMesajim
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            if (!benimMesajim)
                              Text(
                                mesaj.gonderenAdi,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                  color: tema.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            Text(
                              mesaj.metin,
                              style: TextStyle(
                                color: benimMesajim ? Colors.white : tema.colorScheme.onSurface,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (hata, _) => Center(child: Text('Mesajlar yüklenemedi: $hata')),
            ),
          ),

          // 2. Alt Mesaj Yazma Alanı
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: tema.colorScheme.surface,
                border: Border(top: BorderSide(color: tema.dividerColor, width: 0.5)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _metinKontrolcusu,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _mesajGonder(),
                      decoration: const InputDecoration(
                        hintText: 'Mesaj yaz...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: tema.colorScheme.primary,
                    onPressed: _mesajGonder,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
