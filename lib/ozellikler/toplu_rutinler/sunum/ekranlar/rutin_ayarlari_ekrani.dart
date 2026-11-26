// lib/ozellikler/toplu_rutinler/sunum/ekranlar/rutin_ayarlari_ekrani.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../cekirdek/tema/uygulama_renkleri.dart';
import '../../alan/rutin_hareketi_modeli.dart';
import '../../alan/toplu_rutin_modeli.dart';
import '../../veri/rutin_bildirim_ayarlari_servisi.dart';
import '../bilesenler/bildirim_sessize_alma_dialogu.dart';
import '../kontrolculer/grup_kontrolcusu.dart';

/// WhatsApp "Grup Bilgisi" tarzı rutin yönetimi, gerçek başlık/açıklama düzenleme,
/// görev yönetimi, üye listesi ve yetki ayarları ekranı.
/// Renkler doğrudan UygulamaRenkleri sınıfından çağrılır.
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
  late TopluRutinModeli _aktifRutin;
  late bool _yalnizcaYoneticiHareket;
  String _sessizDurumu = 'Kontrol ediliyor...';
  bool _suAnSessizde = false;

  @override
  void initState() {
    super.initState();
    _aktifRutin = widget.rutin;
    _yalnizcaYoneticiHareket = _aktifRutin.yalnizcaYoneticiHareketEkleyebilir;
    _yerelOnbellekKontrolEt();
    _sessizDurumunuYukle();
  }

  Future<void> _yerelOnbellekKontrolEt() async {
    final servis = ref.read(firestoreGrupServisiSaglayici);
    final yerel = await servis.yerelRutinOnbellegiGetir(widget.rutin.id);
    if (yerel != null && mounted) {
      setState(() {
        _aktifRutin = yerel;
        _yalnizcaYoneticiHareket = yerel.yalnizcaYoneticiHareketEkleyebilir;
      });
    }
  }

  Future<void> _sessizDurumunuYukle() async {
    final servis = ref.read(rutinBildirimAyarlariServisiSaglayici);
    final (sessizde, aciklama) = await servis.sessizDurumunuGetir(_aktifRutin.id);
    if (mounted) {
      setState(() {
        _suAnSessizde = sessizde;
        _sessizDurumu = aciklama;
      });
    }
  }

  Future<void> _rutiniKaydetVeSenkronizeEt(TopluRutinModeli yeniRutin, {String? bildirimMesaji}) async {
    setState(() {
      _aktifRutin = yeniRutin;
      _yalnizcaYoneticiHareket = yeniRutin.yalnizcaYoneticiHareketEkleyebilir;
    });

    await ref.read(topluRutinKontrolcusuSaglayici).rutinGuncelle(yeniRutin);

    if (mounted && bildirimMesaji != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bildirimMesaji),
          backgroundColor: UygulamaRenkleri.basariRengi(context),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _rutinBilgileriniDuzenleDialogu() {
    final baslikDenetleyici = TextEditingController(text: _aktifRutin.baslik);
    final aciklamaDenetleyici = TextEditingController(text: _aktifRutin.aciklama);
    String secilenKategori = _aktifRutin.kategori;

    final birincil = UygulamaRenkleri.birincil(context);
    final birincilMetin = UygulamaRenkleri.birincilUzeriMetin(context);
    final kartZemin = UygulamaRenkleri.kartZemini(context);
    final metinBirincil = UygulamaRenkleri.metinBirincil(context);
    final metinIkincil = UygulamaRenkleri.metinIkincil(context);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDState) => AlertDialog(
          backgroundColor: kartZemin,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.edit_note, color: birincil, size: 26),
              const SizedBox(width: 8),
              Text(
                'Rutin Bilgilerini Düzenle',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: metinBirincil),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: baslikDenetleyici,
                  style: TextStyle(color: metinBirincil, fontWeight: FontWeight.w600),
                  decoration: const InputDecoration(
                    labelText: 'Rutin Başlığı',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: aciklamaDenetleyici,
                  style: TextStyle(color: metinBirincil, fontSize: 13),
                  maxLines: 2,
                  decoration: const InputDecoration(
                    labelText: 'Rutin Açıklaması',
                    hintText: 'Rutin hedefini veya kurallarını yazın...',
                  ),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: secilenKategori,
                  dropdownColor: kartZemin,
                  style: TextStyle(color: metinBirincil, fontSize: 14),
                  decoration: const InputDecoration(labelText: 'Kategori / İkon'),
                  items: [
                    DropdownMenuItem(value: 'Sabah', child: Text('🌅 Sabah', style: TextStyle(color: metinBirincil))),
                    DropdownMenuItem(value: 'Fitness', child: Text('💪 Fitness', style: TextStyle(color: metinBirincil))),
                    DropdownMenuItem(value: 'Esneme', child: Text('🧘 Esneme / Yoga', style: TextStyle(color: metinBirincil))),
                    DropdownMenuItem(value: 'Gece', child: Text('🌙 Gece', style: TextStyle(color: metinBirincil))),
                    DropdownMenuItem(value: 'Saglik', child: Text('🥗 Sağlık', style: TextStyle(color: metinBirincil))),
                    DropdownMenuItem(value: 'Zihin', child: Text('🧠 Zihin', style: TextStyle(color: metinBirincil))),
                  ],
                  onChanged: (v) => setDState(() => secilenKategori = v ?? 'Sabah'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Vazgeç', style: TextStyle(color: metinIkincil)),
            ),
            ElevatedButton(
              onPressed: () async {
                final yeniBaslik = baslikDenetleyici.text.trim();
                if (yeniBaslik.isEmpty) return;

                Navigator.pop(ctx);
                final guncel = _aktifRutin.kopyala(
                  baslik: yeniBaslik,
                  aciklama: aciklamaDenetleyici.text.trim(),
                  kategori: secilenKategori,
                );
                await _rutiniKaydetVeSenkronizeEt(
                  guncel,
                  bildirimMesaji: 'Rutin bilgileri güncellendi ✅',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: birincil,
                foregroundColor: birincilMetin,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Kaydet', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _yeniGorevEkleDialogu() {
    final baslikController = TextEditingController();
    String tur = 'kontrol';
    int puan = 15;
    bool nesneGerekli = false;
    final nesneController = TextEditingController();

    final birincil = UygulamaRenkleri.birincil(context);
    final birincilMetin = UygulamaRenkleri.birincilUzeriMetin(context);
    final kartZemin = UygulamaRenkleri.kartZemini(context);
    final metinBirincil = UygulamaRenkleri.metinBirincil(context);
    final metinIkincil = UygulamaRenkleri.metinIkincil(context);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDState) => AlertDialog(
          backgroundColor: kartZemin,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Rutine Yeni Görev Ekle',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: metinBirincil),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: baslikController,
                  style: TextStyle(color: metinBirincil),
                  decoration: const InputDecoration(labelText: 'Görev Adı (örn: 20 Şınav)'),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: tur,
                  dropdownColor: kartZemin,
                  style: TextStyle(color: metinBirincil, fontSize: 14),
                  decoration: const InputDecoration(labelText: 'Ölçüm Türü'),
                  items: [
                    DropdownMenuItem(value: 'kontrol', child: Text('☑️ Kontrol / Tamamlandı', style: TextStyle(color: metinBirincil))),
                    DropdownMenuItem(value: 'sureli', child: Text('⏱️ Süre Bazlı (Saniye)', style: TextStyle(color: metinBirincil))),
                    DropdownMenuItem(value: 'tekrarli', child: Text('🔢 Tekrar Bazlı', style: TextStyle(color: metinBirincil))),
                  ],
                  onChanged: (v) => setDState(() => tur = v ?? 'kontrol'),
                ),
                const SizedBox(height: 12),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: birincil,
                  title: Text('Doğal Nesne Var mı?', style: TextStyle(color: metinBirincil, fontSize: 14)),
                  subtitle: Text('Kitap, su bardağı, dambıl vb.', style: TextStyle(color: metinIkincil, fontSize: 12)),
                  value: nesneGerekli,
                  onChanged: (v) => setDState(() => nesneGerekli = v),
                ),
                if (nesneGerekli)
                  TextField(
                    controller: nesneController,
                    style: TextStyle(color: metinBirincil),
                    decoration: const InputDecoration(
                      labelText: 'Beklenen Nesne Adı (örn: Kitap)',
                    ),
                  ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Vazgeç', style: TextStyle(color: metinIkincil)),
            ),
            ElevatedButton(
              onPressed: () async {
                final ad = baslikController.text.trim();
                if (ad.isEmpty) return;

                Navigator.pop(ctx);
                final yeniHareket = RutinHareketiModeli(
                  id: 'h_${DateTime.now().millisecondsSinceEpoch}',
                  baslik: ad,
                  tur: tur,
                  puan: puan,
                  nesneGerektirirMi: nesneGerekli,
                  beklenenNesneAdi: nesneGerekli ? nesneController.text.trim() : null,
                  siraIndeksi: _aktifRutin.hareketler.length,
                );

                final guncelHareketler = [..._aktifRutin.hareketler, yeniHareket];
                final guncelRutin = _aktifRutin.kopyala(hareketler: guncelHareketler);
                await _rutiniKaydetVeSenkronizeEt(
                  guncelRutin,
                  bildirimMesaji: '"$ad" görevi rutine eklendi ✅',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: birincil,
                foregroundColor: birincilMetin,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Ekle', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _rutindenAyrilOnay() {
    final kartZemin = UygulamaRenkleri.kartZemini(context);
    final metinBirincil = UygulamaRenkleri.metinBirincil(context);
    final metinIkincil = UygulamaRenkleri.metinIkincil(context);
    final tehlike = UygulamaRenkleri.tehlikeRengi(context);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: kartZemin,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Rutinden Ayrıl?', style: TextStyle(color: metinBirincil, fontWeight: FontWeight.bold)),
        content: Text(
          '"${_aktifRutin.baslik}" rutininden ayrılmak istediğine emin misin?',
          style: TextStyle(color: metinIkincil),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('İptal', style: TextStyle(color: metinIkincil)),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              Navigator.pop(context);
              Navigator.pop(context);
              await ref.read(topluRutinKontrolcusuSaglayici).rutindenAyril(_aktifRutin.id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: tehlike,
              foregroundColor: Colors.white,
            ),
            child: const Text('Ayrıl'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uyelerAsync = ref.watch(rutinUyeleriSaglayici(_aktifRutin.id));
    final uid = ref.watch(mevcutKullaniciIdSaglayici).value ?? '';
    final yoneticiMi = _aktifRutin.yoneticiIdleri.contains(uid) ||
        _aktifRutin.kurucuKullaniciId == uid ||
        _aktifRutin.uyeIdleri.length <= 1;

    final birincil = UygulamaRenkleri.birincil(context);
    final birincilMetin = UygulamaRenkleri.birincilUzeriMetin(context);
    final tehlike = UygulamaRenkleri.tehlikeRengi(context);
    final metinBirincil = UygulamaRenkleri.metinBirincil(context);
    final metinIkincil = UygulamaRenkleri.metinIkincil(context);
    final kartZemin = UygulamaRenkleri.kartZemini(context);
    final yukseltilmis = UygulamaRenkleri.yukseltilmisZemin(context);
    final kenarlik = UygulamaRenkleri.kenarlik(context);

    final gorevEkleyebilirMi = !_yalnizcaYoneticiHareket || yoneticiMi;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop(_aktifRutin);
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(_aktifRutin),
          ),
          title: const Text('Rutin Bilgisi & Yönetimi'),
          actions: [
            if (yoneticiMi)
              IconButton(
                icon: Icon(Icons.edit_outlined, color: birincil),
                tooltip: 'Başlık ve Açıklamayı Düzenle',
                onPressed: _rutinBilgileriniDuzenleDialogu,
              ),
          ],
        ),
        body: ListView(
          children: [
            // ÜST BAŞLIK VE DAVET KODU ALANI
            Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              decoration: BoxDecoration(
                color: kartZemin,
                border: Border(bottom: BorderSide(color: kenarlik)),
              ),
              alignment: Alignment.center,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: birincil,
                    child: Text(
                      _aktifRutin.baslik.isNotEmpty ? _aktifRutin.baslik[0].toUpperCase() : 'R',
                      style: TextStyle(fontSize: 32, color: birincilMetin, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          _aktifRutin.baslik,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: metinBirincil),
                        ),
                      ),
                      if (yoneticiMi) ...[
                        const SizedBox(width: 6),
                        InkWell(
                          onTap: _rutinBilgileriniDuzenleDialogu,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(Icons.edit, size: 18, color: birincil),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (_aktifRutin.aciklama.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      _aktifRutin.aciklama,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: metinIkincil, fontSize: 13),
                    ),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    'Kategori: ${_aktifRutin.kategori} • ${_aktifRutin.uyeIdleri.length} Katılımcı',
                    style: TextStyle(color: metinIkincil, fontSize: 12),
                  ),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: _aktifRutin.davetKodu));
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Davet kodu kopyalandı: ${_aktifRutin.davetKodu}')),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: birincil,
                      side: BorderSide(color: birincil.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.copy, size: 16),
                    label: Text(
                      'Davet Kodu: ${_aktifRutin.davetKodu}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // 1. GERÇEK RUTİN DÜZENLEME & YETKİ AYARLARI
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Text(
                'Rutin Yönetimi & Yetkiler',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: birincil),
              ),
            ),

            if (yoneticiMi)
              ListTile(
                leading: Icon(Icons.edit_note, color: birincil),
                title: Text(
                  'Başlık, Açıklama ve Kategoriyi Değiştir',
                  style: TextStyle(fontWeight: FontWeight.w600, color: metinBirincil, fontSize: 14),
                ),
                subtitle: Text(
                  'Rutin adını veya açıklamasını anında güncelle',
                  style: TextStyle(fontSize: 12, color: metinIkincil),
                ),
                trailing: Icon(Icons.chevron_right, color: metinIkincil),
                onTap: _rutinBilgileriniDuzenleDialogu,
              ),

            SwitchListTile(
              activeThumbColor: birincil,
              title: Text(
                'Yalnızca Yöneticiler Görev Ekleyebilir',
                style: TextStyle(fontWeight: FontWeight.w600, color: metinBirincil, fontSize: 14),
              ),
              subtitle: Text(
                _yalnizcaYoneticiHareket
                    ? 'Açık: Sadece yöneticiler rutine yeni hareket ekleyebilir.'
                    : 'Kapalı: Gruptaki tüm üyeler rutine yeni hareket ekleyebilir.',
                style: TextStyle(fontSize: 12, color: metinIkincil),
              ),
              value: _yalnizcaYoneticiHareket,
              onChanged: yoneticiMi
                  ? (yeniDeger) async {
                      final guncel = _aktifRutin.kopyala(
                        yalnizcaYoneticiHareketEkleyebilir: yeniDeger,
                      );
                      await _rutiniKaydetVeSenkronizeEt(
                        guncel,
                        bildirimMesaji: yeniDeger
                            ? 'Görev ekleme yetkisi sadece yöneticilere kısıtlandı 🔒'
                            : 'Tüm üyeler artık rutine görev ekleyebilir 🔓',
                      );
                    }
                  : null,
            ),

            Divider(color: kenarlik),

            // 2. RUTİNDEKİ GÖREVLER (EKLE / SİL)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Rutindeki Görevler (${_aktifRutin.hareketler.length})',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: birincil),
                  ),
                  if (gorevEkleyebilirMi)
                    TextButton.icon(
                      onPressed: _yeniGorevEkleDialogu,
                      icon: Icon(Icons.add_circle_outline, size: 16, color: birincil),
                      label: Text(
                        'Görev Ekle',
                        style: TextStyle(color: birincil, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),

            ..._aktifRutin.hareketler.asMap().entries.map((entry) {
              final idx = entry.key;
              final h = entry.value;
              return ListTile(
                dense: true,
                leading: CircleAvatar(
                  radius: 13,
                  backgroundColor: yukseltilmis,
                  child: Text(
                    '${idx + 1}',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: birincil),
                  ),
                ),
                title: Text(
                  h.baslik,
                  style: TextStyle(fontWeight: FontWeight.w600, color: metinBirincil, fontSize: 13),
                ),
                subtitle: Text(
                  '${h.puan} Puan ${h.nesneGerektirirMi && h.beklenenNesneAdi != null ? '• 📦 ${h.beklenenNesneAdi}' : ''}',
                  style: TextStyle(fontSize: 11, color: metinIkincil),
                ),
                trailing: (gorevEkleyebilirMi && _aktifRutin.hareketler.length > 1)
                    ? IconButton(
                        icon: Icon(Icons.delete_outline, size: 18, color: tehlike),
                        tooltip: 'Görevi Sil',
                        onPressed: () async {
                          final kalanlar = List<RutinHareketiModeli>.from(_aktifRutin.hareketler)
                            ..removeAt(idx);
                          final guncel = _aktifRutin.kopyala(hareketler: kalanlar);
                          await _rutiniKaydetVeSenkronizeEt(
                            guncel,
                            bildirimMesaji: '"${h.baslik}" görevi kaldırıldı.',
                          );
                        },
                      )
                    : null,
              );
            }),

            Divider(color: kenarlik),

            // 3. BİLDİRİMLERİ SESSİZE AL
            ListTile(
              leading: Icon(
                _suAnSessizde ? Icons.notifications_off : Icons.notifications_none,
                color: _suAnSessizde ? tehlike : birincil,
              ),
              title: Text(
                'Bildirimleri Sessize Al',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: metinBirincil,
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                _sessizDurumu,
                style: TextStyle(
                  fontSize: 12,
                  color: _suAnSessizde ? tehlike : metinIkincil,
                ),
              ),
              trailing: Icon(Icons.chevron_right, color: metinIkincil),
              onTap: () {
                BildirimSessizeAlmaDialogu.goster(
                  context,
                  rutinId: _aktifRutin.id,
                  suAnSessizde: _suAnSessizde,
                  servis: ref.read(rutinBildirimAyarlariServisiSaglayici),
                  onGuncellendi: _sessizDurumunuYukle,
                );
              },
            ),

            Divider(color: kenarlik),

            // 4. KATILIMCILAR LİSTESİ
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Katılımcılar (${_aktifRutin.uyeIdleri.length})',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: birincil),
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
                    final buUyeYoneticiMi = _aktifRutin.yoneticiIdleri.contains(uye.kullaniciId) ||
                        _aktifRutin.kurucuKullaniciId == uye.kullaniciId;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: birincil.withValues(alpha: 0.15),
                        child: Text(
                          uye.gorunenAd.isNotEmpty ? uye.gorunenAd[0].toUpperCase() : 'U',
                          style: TextStyle(fontWeight: FontWeight.bold, color: birincil),
                        ),
                      ),
                      title: Text('@${uye.gorunenAd}', style: TextStyle(fontWeight: FontWeight.bold, color: metinBirincil)),
                      subtitle: Text('${uye.toplamPuan} Puan • 🔥 ${uye.mevcutSeri} Gün', style: TextStyle(color: metinIkincil)),
                      trailing: buUyeYoneticiMi
                          ? Chip(
                              backgroundColor: birincil.withValues(alpha: 0.12),
                              side: BorderSide(color: birincil.withValues(alpha: 0.3)),
                              label: Text('Yönetici', style: TextStyle(fontSize: 10, color: birincil, fontWeight: FontWeight.bold)),
                            )
                          : (yoneticiMi && uye.kullaniciId != uid)
                              ? IconButton(
                                  icon: Icon(Icons.remove_circle_outline, color: tehlike),
                                  tooltip: 'Üyeyi Çıkar',
                                  onPressed: () {
                                    ref.read(topluRutinKontrolcusuSaglayici).uyeCikar(_aktifRutin.id, uye.kullaniciId);
                                  },
                                )
                              : null,
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Hata: $e', style: TextStyle(color: metinIkincil))),
            ),

            const SizedBox(height: 20),

            // 5. RUTİNDEN AYRIL BUTONU
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: ElevatedButton.icon(
                onPressed: _rutindenAyrilOnay,
                icon: const Icon(Icons.exit_to_app),
                label: const Text('Rutinden Ayrıl', style: TextStyle(fontWeight: FontWeight.bold)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: tehlike.withValues(alpha: 0.12),
                  foregroundColor: tehlike,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: tehlike.withValues(alpha: 0.3)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }
}
