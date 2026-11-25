// lib/ozellikler/toplu_rutinler/sunum/bilesenler/sabitlenmis_mesaj_seridi.dart

import 'package:flutter/material.dart';
import '../../../../cekirdek/tema/uygulama_renkleri.dart';

/// Sohbette başa sabitlenen mesajı gösteren ve tıklandığında o mesaja kaydıran şerit.
/// Renkler doğrudan UygulamaRenkleri sınıfından çağrılır.
class SabitlenmisMesajSeridi extends StatelessWidget {
  final Map<String, dynamic>? sabitlenmisMesaj;
  final VoidCallback? onTiklandi;
  final VoidCallback? onKaldirTiklandi;

  const SabitlenmisMesajSeridi({
    super.key,
    required this.sabitlenmisMesaj,
    this.onTiklandi,
    this.onKaldirTiklandi,
  });

  @override
  Widget build(BuildContext context) {
    if (sabitlenmisMesaj == null) return const SizedBox.shrink();

    final gonderen = sabitlenmisMesaj!['gonderenKullaniciAdi'] as String? ?? 'Yönetici';
    final metin = sabitlenmisMesaj!['metin'] as String? ?? '';

    final birincil = UygulamaRenkleri.birincil(context);
    final kartZemin = UygulamaRenkleri.kartZemini(context);
    final metinBirincil = UygulamaRenkleri.metinBirincil(context);
    final metinIkincil = UygulamaRenkleri.metinIkincil(context);
    final kenarlik = UygulamaRenkleri.kenarlik(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: kartZemin,
        border: Border(
          bottom: BorderSide(color: kenarlik, width: 1),
        ),
      ),
      child: InkWell(
        onTap: onTiklandi,
        child: Row(
          children: [
            Icon(Icons.push_pin, size: 18, color: birincil),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Sabitlenmiş Mesaj: @$gonderen',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: birincil,
                    ),
                  ),
                  Text(
                    metin,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, color: metinBirincil),
                  ),
                ],
              ),
            ),
            if (onKaldirTiklandi != null)
              IconButton(
                icon: Icon(Icons.close, size: 16, color: metinIkincil),
                onPressed: onKaldirTiklandi,
                tooltip: 'Sabitlemeyi Kaldır',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
      ),
    );
  }
}
