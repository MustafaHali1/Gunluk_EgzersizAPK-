// lib/ozellikler/toplu_rutinler/sunum/bilesenler/kullanici_adi_secme_dialogu.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../kontrolculer/kullanici_profil_kontrolcusu.dart';

/// İlk açılışta veya profil düzenlerken benzersiz @username belirleten şık modal pencere.
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

    final basarili = await ref
        .read(aktifKullaniciProfiliSaglayici.notifier)
        .kullaniciAdiBelirle(ad);

    if (mounted) {
      setState(() => _yukleniyor = false);
      if (basarili) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Harika! Kullanıcı adın @$ad olarak belirlendi 🎉'),
            backgroundColor: Colors.teal.shade700,
          ),
        );
      } else {
        setState(() => _hataMesaji = 'Bu kullanıcı adı dolu veya geçersiz.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.teal.shade50,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_pin, color: Colors.teal, size: 28),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Kullanıcı Adı Seç',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
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
            style: tema.textTheme.bodyMedium?.copyWith(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _denetleyici,
            autofocus: true,
            decoration: InputDecoration(
              prefixText: '@',
              prefixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
              labelText: 'Kullanıcı Adı',
              hintText: 'örn: zeynep, mustafa',
              errorText: _hataMesaji,
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onSubmitted: (_) => _kaydet(),
          ),
        ],
      ),
      actions: [
        if (!widget.zorunluMu)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Vazgeç'),
          ),
        ElevatedButton(
          onPressed: _yukleniyor ? null : _kaydet,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
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
