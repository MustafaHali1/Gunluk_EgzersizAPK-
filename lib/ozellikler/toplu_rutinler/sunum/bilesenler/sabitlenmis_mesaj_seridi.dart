// lib/ozellikler/toplu_rutinler/sunum/bilesenler/sabitlenmis_mesaj_seridi.dart

import 'package:flutter/material.dart';

/// Sohbette başa sabitlenen mesajı gösteren ve tıklandığında o mesaja kaydıran şerit.
class SabitlenmisMesajSeridi extends StatelessWidget {
  final Map<String, dynamic> sabitlenmisMesaj;
  final VoidCallback onTiklandi;
  final VoidCallback? onSabitlemeKaldir;

  const SabitlenmisMesajSeridi({
    super.key,
    required this.sabitlenmisMesaj,
    required this.onTiklandi,
    this.onSabitlemeKaldir,
  });

  @override
  Widget build(BuildContext context) {
    final gonderen = sabitlenmisMesaj['gonderenKullaniciAdi'] as String? ?? 'Yönetici';
    final metin = sabitlenmisMesaj['metin'] as String? ?? '';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.teal.shade50,
        border: Border(
          bottom: BorderSide(color: Colors.teal.shade200, width: 1),
        ),
      ),
      child: InkWell(
        onTap: onTiklandi,
        child: Row(
          children: [
            const Icon(Icons.push_pin, size: 18, color: Colors.teal),
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
                      color: Colors.teal.shade900,
                    ),
                  ),
                  Text(
                    metin,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: Colors.black87),
                  ),
                ],
              ),
            ),
            if (onSabitlemeKaldir != null)
              IconButton(
                icon: const Icon(Icons.close, size: 16, color: Colors.grey),
                onPressed: onSabitlemeKaldir,
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
