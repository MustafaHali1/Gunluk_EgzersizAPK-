// lib/ozellikler/bugun/sunum/bugun_hareket_karti.dart

import 'package:flutter/material.dart';
import '../../../cekirdek/sabitler/uygulama_sabitleri.dart';
import '../../../cekirdek/veritabani/uygulama_veritabani.dart';

// Bugün ekranındaki her bir egzersiz satırını, durum butonlarını ve notunu gösteren kart bileşeni.
class BugunHareketKarti extends StatelessWidget {
  final EgzersizKayitlariData kayit;
  final EgzersizlerData? egzersizDetayi;
  final ValueChanged<String> durumDegistirildiginde;
  final ValueChanged<String> notKaydedildiginde;
  final bool isaretlemeAcikMi;
  final String? kilitMesaji;

  const BugunHareketKarti({
    super.key,
    required this.kayit,
    required this.egzersizDetayi,
    required this.durumDegistirildiginde,
    required this.notKaydedildiginde,
    this.isaretlemeAcikMi = true,
    this.kilitMesaji,
  });

  String _hedefBilgisiOlustur() {
    final detay = egzersizDetayi;
    if (detay == null) return 'Kayıtlı görev';
    if (detay.aciklama.trim().isNotEmpty) {
      return detay.aciklama.trim();
    }
    return detay.kategori;
  }

  Future<void> _notDuzenlemePenceresiAc(BuildContext context) async {
    final yazici = TextEditingController(text: kayit.notMetni ?? '');
    final sonuc = await showDialog<String>(
      context: context,
      builder: (baglam) => AlertDialog(
        title: Text('${kayit.egzersizAdiKopyasi} — Not'),
        content: TextField(
          controller: yazici,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Örn: Sağ dizde hafif ağrı oldu, 2 set yaptım...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(baglam).pop(),
            child: const Text(UygulamaMetinleri.iptal),
          ),
          FilledButton(
            onPressed: () => Navigator.of(baglam).pop(yazici.text),
            child: const Text(UygulamaMetinleri.kaydet),
          ),
        ],
      ),
    );
    yazici.dispose();
    if (sonuc != null) {
      notKaydedildiginde(sonuc);
    }
  }

  @override
  Widget build(BuildContext context) {
    final yapildiMi = kayit.durum == 'yapildi';
    final atlandiMi = kayit.durum == 'atlandi';
    final notVarMi =
        kayit.notMetni != null && kayit.notMetni!.trim().isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: UygulamaBoyutlari.altBosluk),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(UygulamaBoyutlari.kartYaricapi),
        side: BorderSide(
          color: yapildiMi
              ? UygulamaRenkleri.basariYesili.withValues(alpha: 0.6)
              : atlandiMi
                  ? UygulamaRenkleri.hataKirmizisi.withValues(alpha: 0.6)
                  : Colors.transparent,
          width: 1.5,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(UygulamaBoyutlari.kartIcBosluk),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HareketBaslikSatiri(
              baslik: kayit.egzersizAdiKopyasi,
              altBaslik: _hedefBilgisiOlustur(),
              yapildiMi: yapildiMi,
              atlandiMi: atlandiMi,
              notTiklandiginda: () => _notDuzenlemePenceresiAc(context),
            ),
            if (notVarMi) ...[
              const SizedBox(height: 8),
              InkWell(
                onTap: () => _notDuzenlemePenceresiAc(context),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.sticky_note_2_outlined, size: 16),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          kayit.notMetni!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            if (!isaretlemeAcikMi && kilitMesaji != null) ...[
              Row(
                children: [
                  Icon(
                    yapildiMi ? Icons.lock_outline : Icons.notifications_paused,
                    size: 15,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      kilitMesaji!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            _DurumButonlariSatiri(
              yapildiMi: yapildiMi,
              atlandiMi: atlandiMi,
              etkinMi: isaretlemeAcikMi,
              yapildiTiklandiginda: () => durumDegistirildiginde('yapildi'),
              atlandiTiklandiginda: () => durumDegistirildiginde('atlandi'),
            ),
          ],
        ),
      ),
    );
  }
}

// Hareket kartının başlık, hedef bilgisi ve not ikonunu gösteren alt bileşen.
class _HareketBaslikSatiri extends StatelessWidget {
  final String baslik;
  final String altBaslik;
  final bool yapildiMi;
  final bool atlandiMi;
  final VoidCallback notTiklandiginda;

  const _HareketBaslikSatiri({
    required this.baslik,
    required this.altBaslik,
    required this.yapildiMi,
    required this.atlandiMi,
    required this.notTiklandiginda,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          backgroundColor: yapildiMi
              ? UygulamaRenkleri.basariYesili.withValues(alpha: 0.15)
              : atlandiMi
                  ? UygulamaRenkleri.hataKirmizisi.withValues(alpha: 0.15)
                  : Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Icon(
            yapildiMi
                ? Icons.check_circle
                : atlandiMi
                    ? Icons.cancel
                    : Icons.radio_button_unchecked,
            color: yapildiMi
                ? UygulamaRenkleri.basariYesili
                : atlandiMi
                    ? UygulamaRenkleri.hataKirmizisi
                    : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                baslik,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      decoration: yapildiMi ? TextDecoration.lineThrough : null,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                altBaslik,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: 'Not ekle / düzenle',
          onPressed: notTiklandiginda,
          icon: const Icon(Icons.edit_note),
        ),
      ],
    );
  }
}

// "Yaptım" ve "Yapmadım" geri alınabilir aksiyon butonlarını barındıran alt bileşen.
class _DurumButonlariSatiri extends StatelessWidget {
  final bool yapildiMi;
  final bool atlandiMi;
  final bool etkinMi;
  final VoidCallback yapildiTiklandiginda;
  final VoidCallback atlandiTiklandiginda;

  const _DurumButonlariSatiri({
    required this.yapildiMi,
    required this.atlandiMi,
    required this.etkinMi,
    required this.yapildiTiklandiginda,
    required this.atlandiTiklandiginda,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Semantics(
            button: true,
            selected: yapildiMi,
            label: yapildiMi ? 'Yapıldı (Kilitli)' : 'Yaptım olarak işaretle',
            child: SizedBox(
              height: UygulamaBoyutlari.dokunmaHedefiMin,
              child: yapildiMi
                  ? FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: UygulamaRenkleri.basariYesili,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: UygulamaRenkleri.basariYesili
                            .withValues(alpha: 0.85),
                        disabledForegroundColor: Colors.white,
                      ),
                      onPressed: null,
                      icon: const Icon(Icons.lock),
                      label: const Text('Yapıldı (Kilitli)'),
                    )
                  : OutlinedButton.icon(
                      onPressed: etkinMi ? yapildiTiklandiginda : null,
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text(UygulamaMetinleri.yaptim),
                    ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Semantics(
            button: true,
            selected: atlandiMi,
            label: atlandiMi
                ? 'Yapmadım olarak işaretli'
                : 'Yapmadım olarak işaretle',
            child: SizedBox(
              height: UygulamaBoyutlari.dokunmaHedefiMin,
              child: atlandiMi
                  ? FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: UygulamaRenkleri.hataKirmizisi,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: etkinMi ? atlandiTiklandiginda : null,
                      icon: const Icon(Icons.close),
                      label: const Text('Yapmadım'),
                    )
                  : OutlinedButton.icon(
                      onPressed: etkinMi ? atlandiTiklandiginda : null,
                      icon: const Icon(Icons.cancel_outlined),
                      label: const Text(UygulamaMetinleri.atladim),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
