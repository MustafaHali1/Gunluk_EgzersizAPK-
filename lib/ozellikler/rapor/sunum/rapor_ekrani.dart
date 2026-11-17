// lib/ozellikler/rapor/sunum/rapor_ekrani.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../cekirdek/sabitler/uygulama_sabitleri.dart';
import '../../gecmis/sunum/gecmis_ekrani.dart';
import '../alan/rapor_olusturucu.dart';
import 'rapor_kontrolcusu.dart';

// Her rutini kendi açılır-kapanır tablosuyla gösteren, PDF paylaşımı ve geçmiş takvimi sunan ekran.
class RaporEkrani extends ConsumerWidget {
  const RaporEkrani({super.key});

  Future<void> _ozelTarihAraligiSeciciAc(
    BuildContext context,
    RaporKontrolcusu kontrolcu,
    RaporDurumu mevcutDurum,
  ) async {
    final secilen = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      initialDateRange: DateTimeRange(
        start: mevcutDurum.baslangic,
        end: mevcutDurum.bitis,
      ),
      helpText: 'Rapor Tarih Aralığını Seçin',
    );
    if (secilen != null) {
      await kontrolcu.ozelTarihAraligiSec(secilen.start, secilen.end);
    }
  }

  Future<void> _pdfPaylas(
    BuildContext context,
    RaporKontrolcusu kontrolcu, {
    RutinRaporGrubu? grup,
  }) async {
    final basarili = await kontrolcu.pdfOlarakPaylas(grup: grup);
    if (!basarili && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PDF paylaşılırken bir sorun oluştu.')),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final raporDurumu = ref.watch(raporKontrolcusuSaglayici);
    final kontrolcu = ref.read(raporKontrolcusuSaglayici.notifier);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(UygulamaSabitleri.sekmeRapor),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.table_chart_outlined),
                text: 'Rapor',
              ),
              Tab(
                icon: Icon(Icons.calendar_month_outlined),
                text: 'Takvim & Geçmiş',
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            raporDurumu.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (h, _) => Center(child: Text('Rapor oluşturulamadı: $h')),
              data: (durum) => ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  _AralikSeciciSatiri(
                    seciliTur: durum.aralikTuru,
                    turSecildiginde: (tur) {
                      if (tur == RaporAralikTuru.ozel) {
                        _ozelTarihAraligiSeciciAc(context, kontrolcu, durum);
                      } else {
                        kontrolcu.aralikTuruSec(tur);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  _RaporOzetKarti(tablo: durum.tablo),
                  const SizedBox(height: 14),
                  Text(
                    'Rutin Tabloları',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  if (durum.rutinGruplari.isEmpty)
                    _RaporMatrisKarti(
                      baslik: 'Günlük Takip Tablosu',
                      tablo: durum.tablo,
                      pdfPaylasTiklandiginda: () =>
                          _pdfPaylas(context, kontrolcu),
                    )
                  else
                    ...durum.rutinGruplari.map(
                      (grup) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _RaporMatrisKarti(
                          baslik:
                              '${grup.rutinAdi} (%${grup.tablo.genelTamamlanmaYuzdesi})',
                          tablo: grup.tablo,
                          pdfPaylasTiklandiginda: () =>
                              _pdfPaylas(context, kontrolcu, grup: grup),
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Text(
                    UygulamaMetinleri.tibbiUyariNotu,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const GecmisGorunumu(),
          ],
        ),
      ),
    );
  }
}

// 7 gün, 30 gün veya özel tarih aralığı seçimini sağlayan bileşen.
class _AralikSeciciSatiri extends StatelessWidget {
  final RaporAralikTuru seciliTur;
  final ValueChanged<RaporAralikTuru> turSecildiginde;

  const _AralikSeciciSatiri({
    required this.seciliTur,
    required this.turSecildiginde,
  });

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<RaporAralikTuru>(
      segments: const [
        ButtonSegment(
          value: RaporAralikTuru.son7Gun,
          label: Text('7 Gün'),
        ),
        ButtonSegment(
          value: RaporAralikTuru.son30Gun,
          label: Text('30 Gün'),
        ),
        ButtonSegment(
          value: RaporAralikTuru.ozel,
          label: Text('Özel Aralık'),
        ),
      ],
      selected: {seciliTur},
      onSelectionChanged: (secim) => turSecildiginde(secim.first),
    );
  }
}

// Genel tamamlanma yüzdesini, en uzun seriyi ve açılır-kapanır özeti gösteren kart.
class _RaporOzetKarti extends StatelessWidget {
  final RaporTablosu tablo;

  const _RaporOzetKarti({required this.tablo});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text(
          '${tablo.baslangicTarihi} — ${tablo.bitisTarihi}',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Text(
          'Genel Tamamlanma: %${tablo.genelTamamlanmaYuzdesi} • En Uzun Seri: ${tablo.enUzunSeri} Gün',
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        children: const [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              '✅ Yaptım   ❌ Yapmadım   ➖ Planlı Değil',
              style: TextStyle(fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// Her rutin için ayrı açılıp kapanabilir tırnağa ve PDF paylaşma butonuna sahip rapor tablosu kartı.
class _RaporMatrisKarti extends StatelessWidget {
  final String baslik;
  final RaporTablosu tablo;
  final VoidCallback pdfPaylasTiklandiginda;

  const _RaporMatrisKarti({
    required this.baslik,
    required this.tablo,
    required this.pdfPaylasTiklandiginda,
  });

  String _kisaGunBasligi(String tarihMetni) {
    final parcalar = tarihMetni.split('-');
    if (parcalar.length != 3) return tarihMetni;
    return '${parcalar[2]}/${parcalar[1]}';
  }

  @override
  Widget build(BuildContext context) {
    if (tablo.satirlar.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
          child: Row(
            children: [
              Expanded(
                child: Text('$baslik: Bu aralıkta kayıtlı görev yok.'),
              ),
              TextButton.icon(
                onPressed: pdfPaylasTiklandiginda,
                icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
                label: const Text('PDF Paylaş'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Row(
          children: [
            Expanded(
              child: Text(
                baslik,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            TextButton.icon(
              onPressed: pdfPaylasTiklandiginda,
              icon: const Icon(Icons.picture_as_pdf_outlined, size: 18),
              label: const Text('PDF Paylaş'),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ],
        ),
        subtitle: Text('${tablo.satirlar.length} görev'),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 8),
            child: DataTable(
              columnSpacing: 16,
              headingRowHeight: 42,
              dataRowMinHeight: 40,
              dataRowMaxHeight: 48,
              columns: [
                const DataColumn(label: Text('Görev')),
                ...tablo.gunler.map(
                  (g) => DataColumn(label: Text(_kisaGunBasligi(g))),
                ),
                const DataColumn(label: Text('Oran')),
              ],
              rows: tablo.satirlar.map((satir) {
                return DataRow(
                  cells: [
                    DataCell(
                      Text(
                        satir.egzersizAdi,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    ...tablo.gunler.map((gun) {
                      final durum =
                          satir.gunlukDurumlar[gun] ??
                          RaporHucreDurumu.planliDegil;
                      return DataCell(Center(child: Text(durum.sembol)));
                    }),
                    DataCell(
                      Text(
                        '%${satir.tamamlanmaYuzdesi}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
