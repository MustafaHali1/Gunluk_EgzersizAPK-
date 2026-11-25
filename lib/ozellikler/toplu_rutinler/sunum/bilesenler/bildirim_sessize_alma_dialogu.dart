// lib/ozellikler/toplu_rutinler/sunum/bilesenler/bildirim_sessize_alma_dialogu.dart

import 'package:flutter/material.dart';
import '../../../../cekirdek/tema/uygulama_renkleri.dart';
import '../../veri/rutin_bildirim_ayarlari_servisi.dart';

enum SessizeAlmaSecenegi {
  sekizSaat,
  birHafta,
  surekli,
  ozelTarih,
}

/// WhatsApp tarzı süreli / süresiz bildirim sessize alma modal penceresi.
/// Renkler doğrudan UygulamaRenkleri sınıfından çağrılır.
class BildirimSessizeAlmaDialogu extends StatefulWidget {
  final String rutinId;
  final bool suAnSessizde;
  final RutinBildirimAyarlariServisi servis;
  final VoidCallback onGuncellendi;

  const BildirimSessizeAlmaDialogu({
    super.key,
    required this.rutinId,
    required this.suAnSessizde,
    required this.servis,
    required this.onGuncellendi,
  });

  static Future<void> goster(
    BuildContext context, {
    required String rutinId,
    required bool suAnSessizde,
    required RutinBildirimAyarlariServisi servis,
    required VoidCallback onGuncellendi,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => BildirimSessizeAlmaDialogu(
        rutinId: rutinId,
        suAnSessizde: suAnSessizde,
        servis: servis,
        onGuncellendi: onGuncellendi,
      ),
    );
  }

  @override
  State<BildirimSessizeAlmaDialogu> createState() => _BildirimSessizeAlmaDialoguState();
}

class _BildirimSessizeAlmaDialoguState extends State<BildirimSessizeAlmaDialogu> {
  SessizeAlmaSecenegi _secenek = SessizeAlmaSecenegi.sekizSaat;
  DateTime? _secilenOzelTarih;

  Future<void> _ozelTarihSec() async {
    final bugun = DateTime.now();
    final secilenGun = await showDatePicker(
      context: context,
      initialDate: bugun.add(const Duration(days: 1)),
      firstDate: bugun,
      lastDate: bugun.add(const Duration(days: 365)),
    );

    if (secilenGun != null && mounted) {
      final secilenSaat = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(bugun),
      );

      if (secilenSaat != null) {
        setState(() {
          _secilenOzelTarih = DateTime(
            secilenGun.year,
            secilenGun.month,
            secilenGun.day,
            secilenSaat.hour,
            secilenSaat.minute,
          );
          _secenek = SessizeAlmaSecenegi.ozelTarih;
        });
      }
    }
  }

  Future<void> _kaydet() async {
    DateTime? bitis;
    final simdikiZaman = DateTime.now();

    switch (_secenek) {
      case SessizeAlmaSecenegi.sekizSaat:
        bitis = simdikiZaman.add(const Duration(hours: 8));
        break;
      case SessizeAlmaSecenegi.birHafta:
        bitis = simdikiZaman.add(const Duration(days: 7));
        break;
      case SessizeAlmaSecenegi.surekli:
        bitis = null;
        break;
      case SessizeAlmaSecenegi.ozelTarih:
        bitis = _secilenOzelTarih ?? simdikiZaman.add(const Duration(days: 1));
        break;
    }

    await widget.servis.sessizeAl(widget.rutinId, bitis);
    widget.onGuncellendi();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _sesiAc() async {
    await widget.servis.sessizdenCikar(widget.rutinId);
    widget.onGuncellendi();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final birincil = UygulamaRenkleri.birincil(context);
    final kartZemin = UygulamaRenkleri.kartZemini(context);
    final metinBirincil = UygulamaRenkleri.metinBirincil(context);
    final metinIkincil = UygulamaRenkleri.metinIkincil(context);

    return AlertDialog(
      backgroundColor: kartZemin,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Icon(Icons.notifications_off_outlined, color: birincil, size: 26),
          const SizedBox(width: 10),
          Text(
            'Bildirimleri Sessize Al',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: metinBirincil,
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Bu rutinden gelen mesaj ve kanıt bildirimlerini ne kadar süreyle sessize almak istersin?',
            style: TextStyle(fontSize: 13, color: metinIkincil),
          ),
          const SizedBox(height: 12),
          RadioGroup<SessizeAlmaSecenegi>(
            groupValue: _secenek,
            onChanged: (v) {
              if (v != null) setState(() => _secenek = v);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RadioListTile<SessizeAlmaSecenegi>(
                  title: Text('8 Saat', style: TextStyle(color: metinBirincil, fontSize: 14)),
                  value: SessizeAlmaSecenegi.sekizSaat,
                  activeColor: birincil,
                ),
                RadioListTile<SessizeAlmaSecenegi>(
                  title: Text('1 Hafta (7 Gün)', style: TextStyle(color: metinBirincil, fontSize: 14)),
                  value: SessizeAlmaSecenegi.birHafta,
                  activeColor: birincil,
                ),
                RadioListTile<SessizeAlmaSecenegi>(
                  title: Text('Her Zaman (Süresiz)', style: TextStyle(color: metinBirincil, fontSize: 14)),
                  value: SessizeAlmaSecenegi.surekli,
                  activeColor: birincil,
                ),
                RadioListTile<SessizeAlmaSecenegi>(
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _secilenOzelTarih == null
                              ? 'Belirli Bir Süre Seç...'
                              : 'Bitiş: ${_secilenOzelTarih!.day}.${_secilenOzelTarih!.month} ${_secilenOzelTarih!.hour}:${_secilenOzelTarih!.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(color: metinBirincil, fontSize: 14),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.calendar_month, color: birincil, size: 20),
                        onPressed: _ozelTarihSec,
                      ),
                    ],
                  ),
                  value: SessizeAlmaSecenegi.ozelTarih,
                  activeColor: birincil,
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        if (widget.suAnSessizde)
          TextButton(
            onPressed: _sesiAc,
            child: const Text('Sesi Aç 🔔', style: TextStyle(color: Colors.green)),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Vazgeç', style: TextStyle(color: metinIkincil)),
        ),
        ElevatedButton(
          onPressed: _kaydet,
          style: ElevatedButton.styleFrom(
            backgroundColor: birincil,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: const Text('Tamam'),
        ),
      ],
    );
  }
}
