// lib/ozellikler/toplu_rutinler/sunum/ekranlar/rutin_sohbet_ekrani.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../cekirdek/tema/uygulama_renkleri.dart';
import '../../alan/toplu_rutin_modeli.dart';
import '../../alan/grup_mesaj_modeli.dart';
import '../bilesenler/sabitlenmis_mesaj_seridi.dart';
import '../bilesenler/kanit_karti_bileseni.dart';
import '../kontrolculer/grup_kontrolcusu.dart';
import '../kontrolculer/grup_sohbet_kontrolcusu.dart';

/// WhatsApp tarzı mesajlaşma, sabitlenmiş mesaj şeridi ve çift tik göstergeli bağımsız sohbet ekranı.
/// Renkler doğrudan UygulamaRenkleri sınıfından çağrılır (Thin UI).
class RutinSohbetEkrani extends ConsumerStatefulWidget {
  final TopluRutinModeli rutin;

  const RutinSohbetEkrani({
    super.key,
    required this.rutin,
  });

  @override
  ConsumerState<RutinSohbetEkrani> createState() => _RutinSohbetEkraniState();
}

class _RutinSohbetEkraniState extends ConsumerState<RutinSohbetEkrani> {
  final TextEditingController _mesajDenetleyici = TextEditingController();
  final ScrollController _sohbetKaydirici = ScrollController();

  @override
  void dispose() {
    _mesajDenetleyici.dispose();
    _sohbetKaydirici.dispose();
    super.dispose();
  }

  void _mesajGonder() {
    final metin = _mesajDenetleyici.text.trim();
    if (metin.isEmpty) return;

    _mesajDenetleyici.clear();
    ref.read(grupSohbetKontrolcusuSaglayici).mesajGonder(
          rutinId: widget.rutin.id,
          metin: metin,
        );

    // En alta kaydır
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_sohbetKaydirici.hasClients) {
        _sohbetKaydirici.animateTo(
          _sohbetKaydirici.position.maxScrollExtent + 80,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _mesajSecenekleri(GrupMesajModeli mesaj) {
    final metinBirincil = UygulamaRenkleri.metinBirincil(context);
    final kartZemin = UygulamaRenkleri.kartZemini(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: kartZemin,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: Icon(
                mesaj.sabitlendiMi ? Icons.push_pin_outlined : Icons.push_pin,
                color: UygulamaRenkleri.birincil(context),
              ),
              title: Text(
                mesaj.sabitlendiMi ? 'Sabitlemeyi Kaldır' : 'Mesajı Sabitle 📌',
                style: TextStyle(color: metinBirincil),
              ),
              onTap: () {
                Navigator.pop(ctx);
                if (mesaj.sabitlendiMi) {
                  ref.read(grupSohbetKontrolcusuSaglayici).mesajSabitlemeKaldir(widget.rutin.id);
                } else {
                  ref.read(grupSohbetKontrolcusuSaglayici).mesajSabitle(
                        rutinId: widget.rutin.id,
                        mesaj: mesaj,
                      );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _tikIkonu(BuildContext context, MesajGonderimDurumu durum) {
    final birincil = UygulamaRenkleri.birincil(context);
    final metinIkincil = UygulamaRenkleri.metinIkincil(context);

    switch (durum) {
      case MesajGonderimDurumu.beklemede:
        return Icon(Icons.access_time, size: 12, color: metinIkincil);
      case MesajGonderimDurumu.gonderildi:
        return Icon(Icons.check, size: 13, color: metinIkincil);
      case MesajGonderimDurumu.iletildi:
        return Icon(Icons.done_all, size: 13, color: birincil);
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = ref.watch(mevcutKullaniciIdSaglayici).value ?? '';
    final mesajlarAsync = ref.watch(rutinMesajlariSaglayici(widget.rutin.id));

    final birincil = UygulamaRenkleri.birincil(context);
    final kartZemin = UygulamaRenkleri.kartZemini(context);
    final arkaPlan = UygulamaRenkleri.arkaPlan(context);
    final metinBirincil = UygulamaRenkleri.metinBirincil(context);
    final metinIkincil = UygulamaRenkleri.metinIkincil(context);
    final kenarlik = UygulamaRenkleri.kenarlik(context);

    final benimBalon = UygulamaRenkleri.benimBalonZemin(context);
    final benimMetin = UygulamaRenkleri.benimBalonMetin(context);
    final baskasiBalon = UygulamaRenkleri.baskasiBalonZemin(context);
    final baskasiMetin = UygulamaRenkleri.baskasiBalonMetin(context);

    return Container(
      color: arkaPlan,
      child: Column(
        children: [
          // SABİTLENMİŞ MESAJ ŞERİDİ
          SabitlenmisMesajSeridi(
            sabitlenmisMesaj: widget.rutin.sabitlenmisMesaj,
            onKaldirTiklandi: () {
              ref.read(grupSohbetKontrolcusuSaglayici).mesajSabitlemeKaldir(widget.rutin.id);
            },
          ),

          // MESAJ LİSTESİ
          Expanded(
            child: mesajlarAsync.when(
              data: (mesajlar) {
                if (mesajlar.isEmpty) {
                  return Center(
                    child: Text(
                      'Sohbet odasına ilk mesajı sen yaz! 👋',
                      style: TextStyle(color: metinIkincil),
                    ),
                  );
                }

                return ListView.builder(
                  controller: _sohbetKaydirici,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: mesajlar.length,
                  itemBuilder: (context, index) {
                    final m = mesajlar[index];
                    final benimMi = m.gonderenId == uid;

                    if (m.tur == 'kanit_karti') {
                      return KanitKartiBileseni(
                        mesaj: m,
                        mevcutKullaniciId: uid,
                        onTepkiVer: (_) {},
                      );
                    }

                    return InkWell(
                      onLongPress: () => _mesajSecenekleri(m),
                      borderRadius: BorderRadius.circular(16),
                      child: Align(
                        alignment: benimMi ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.78,
                          ),
                          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: benimMi ? benimBalon : baskasiBalon,
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(16),
                              topRight: const Radius.circular(16),
                              bottomLeft: Radius.circular(benimMi ? 16 : 4),
                              bottomRight: Radius.circular(benimMi ? 4 : 16),
                            ),
                            border: Border.all(
                              color: benimMi ? Colors.transparent : kenarlik,
                              width: 0.8,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 3,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: benimMi ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              if (!benimMi)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 2),
                                  child: Text(
                                    '@${m.gonderenAdi}',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: birincil,
                                    ),
                                  ),
                                ),
                              Text(
                                m.metin,
                                style: TextStyle(
                                  color: benimMi ? benimMetin : baskasiMetin,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (m.sabitlendiMi)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 4),
                                      child: Icon(Icons.push_pin, size: 10, color: metinIkincil),
                                    ),
                                  Text(
                                    '${m.tarih.hour.toString().padLeft(2, '0')}:${m.tarih.minute.toString().padLeft(2, '0')}',
                                    style: TextStyle(fontSize: 10, color: metinIkincil),
                                  ),
                                  if (benimMi) ...[
                                    const SizedBox(width: 4),
                                    _tikIkonu(context, m.durum),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Hata: $e', style: TextStyle(color: metinIkincil))),
            ),
          ),

          // MESAJ YAZMA ÇUBUĞU
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: kartZemin,
              border: Border(top: BorderSide(color: kenarlik, width: 0.8)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: arkaPlan,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: kenarlik, width: 0.8),
                      ),
                      child: TextField(
                        controller: _mesajDenetleyici,
                        style: TextStyle(color: metinBirincil, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Bir mesaj yaz...',
                          hintStyle: TextStyle(color: metinIkincil, fontSize: 13),
                          border: InputBorder.none,
                        ),
                        onSubmitted: (_) => _mesajGonder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: birincil,
                    radius: 20,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white, size: 18),
                      onPressed: _mesajGonder,
                    ),
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
