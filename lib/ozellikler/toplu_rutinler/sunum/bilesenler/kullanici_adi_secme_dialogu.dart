// lib/ozellikler/toplu_rutinler/sunum/bilesenler/kullanici_adi_secme_dialogu.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../cekirdek/tema/uygulama_renkleri.dart';
import '../kontrolculer/kullanici_profil_kontrolcusu.dart';

/// İlk açılışta veya profil düzenlerken benzersiz @username belirleten şık modal pencere.
/// Renkler doğrudan UygulamaRenkleri sınıfından çağrılır.
class KullaniciAdiSecmeDialogu extends ConsumerStatefulWidget {
  final bool zorunluMu;
  final String? mevcutAd;

  const KullaniciAdiSecmeDialogu({
    super.key,
    this.zorunluMu = true,
    this.mevcutAd,
  });

  static Future<void> goster(BuildContext context, {bool zorunluMu = true, String? mevcutAd}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: !zorunluMu,
      builder: (ctx) => PopScope(
        canPop: !zorunluMu,
        child: KullaniciAdiSecmeDialogu(zorunluMu: zorunluMu, mevcutAd: mevcutAd),
      ),
    );
  }

  @override
  ConsumerState<KullaniciAdiSecmeDialogu> createState() => _KullaniciAdiSecmeDialoguState();
}

class _KullaniciAdiSecmeDialoguState extends ConsumerState<KullaniciAdiSecmeDialogu> {
  late final TextEditingController _denetleyici;
  bool _yukleniyor = false;
  String? _hataMesaji;

  @override
  void initState() {
    super.initState();
    _denetleyici = TextEditingController(text: widget.mevcutAd ?? '');
  }

  @override
  void dispose() {
    _denetleyici.dispose();
    super.dispose();
  }

  Future<void> _kaydet() async {
    final ad = _denetleyici.text.trim().replaceAll('@', '');
    if (ad.length < 3) {
      setState(() => _hataMesaji = 'Kullanıcı adı en az 3 karakter olmalıdır.');
      return;
    }

    setState(() {
      _yukleniyor = true;
      _hataMesaji = null;
    });

    final (basarili, hata) = await ref
        .read(aktifKullaniciProfiliSaglayici.notifier)
        .kullaniciAdiBelirle(ad);

    if (mounted) {
      setState(() => _yukleniyor = false);
      if (basarili) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Harika! Kullanıcı adın @$ad olarak belirlendi 🎉'),
            backgroundColor: UygulamaRenkleri.basariRengi(context),
          ),
        );
      } else {
        setState(() => _hataMesaji = hata ?? 'Bu kullanıcı adı belirlenemedi.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final birincil = UygulamaRenkleri.birincil(context);
    final kartZemin = UygulamaRenkleri.kartZemini(context);
    final arkaPlan = UygulamaRenkleri.arkaPlan(context);
    final metinBirincil = UygulamaRenkleri.metinBirincil(context);
    final metinIkincil = UygulamaRenkleri.metinIkincil(context);
    final kenarlik = UygulamaRenkleri.kenarlik(context);

    return AlertDialog(
      backgroundColor: kartZemin,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: birincil.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_pin, color: birincil, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Kullanıcı Adı Seç',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: metinBirincil),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Toplu rutinlerde, sohbette ve liderlik sıralamasında arkadaşlarına nasıl görünmek istersin?',
            style: TextStyle(color: metinIkincil, fontSize: 13),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _denetleyici,
            autofocus: true,
            style: TextStyle(color: metinBirincil),
            decoration: InputDecoration(
              prefixText: '@',
              prefixStyle: TextStyle(fontWeight: FontWeight.bold, color: birincil),
              labelText: 'Kullanıcı Adı',
              labelStyle: TextStyle(color: metinIkincil),
              hintText: 'örn: zeynep, mustafa',
              hintStyle: TextStyle(color: metinIkincil.withValues(alpha: 0.7)),
              errorText: _hataMesaji,
              filled: true,
              fillColor: arkaPlan,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: kenarlik),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: birincil, width: 2),
              ),
            ),
            onSubmitted: (_) => _kaydet(),
          ),
        ],
      ),
      actions: [
        if (!widget.zorunluMu)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Vazgeç', style: TextStyle(color: metinIkincil)),
          ),
        ElevatedButton(
          onPressed: _yukleniyor ? null : _kaydet,
          style: ElevatedButton.styleFrom(
            backgroundColor: birincil,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          child: _yukleniyor
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text('Devam Et'),
        ),
      ],
    );
  }
}
