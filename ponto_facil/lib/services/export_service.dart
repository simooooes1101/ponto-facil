import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import '../models/registro_ponto.dart';
import 'ponto_service.dart';

class ExportService {
  final PontoService _pontoService = PontoService();

  Future<String> exportarCSV(List<RegistroPonto> registros) async {
    final List<List<dynamic>> rows = [
      ['Data', 'Hora', 'Tipo', 'Observação'],
    ];

    for (final r in registros) {
      rows.add([r.data, r.hora, r.tipo.label, r.observacao ?? '']);
    }

    final csv = const ListToCsvConverter().convert(rows);
    final dir = await getApplicationDocumentsDirectory();
    final file = File(
        '${dir.path}/ponto_facil_${DateTime.now().millisecondsSinceEpoch}.csv');
    await file.writeAsString(csv);
    return file.path;
  }

  Future<String> exportarPDF(
      List<RegistroPonto> registros, String nomeUsuario) async {
    final pdf = pw.Document();
    final agrupado = _agruparPorDia(registros);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        header: (context) => _buildHeader(nomeUsuario),
        footer: (context) => _buildFooter(context),
        build: (context) => [
          pw.SizedBox(height: 20),
          ...agrupado.entries.map((entry) =>
              _buildDaySection(entry.key, entry.value)),
        ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
        '${dir.path}/ponto_facil_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());
    return file.path;
  }

  pw.Widget _buildHeader(String nomeUsuario) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'PONTO FÁCIL',
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.indigo700,
              ),
            ),
            pw.Text(
              'Gerado em: ${_formatarDataHoje()}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600),
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          'Relatório de Ponto — $nomeUsuario',
          style: const pw.TextStyle(fontSize: 13, color: PdfColors.grey700),
        ),
        pw.Divider(color: PdfColors.indigo200),
      ],
    );
  }

  pw.Widget _buildFooter(pw.Context context) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text('Ponto Fácil — Relatório Offline',
            style:
                const pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
        pw.Text('Página ${context.pageNumber} de ${context.pagesCount}',
            style:
                const pw.TextStyle(fontSize: 9, color: PdfColors.grey500)),
      ],
    );
  }

  pw.Widget _buildDaySection(String data, List<RegistroPonto> registros) {
    final sorted = List<RegistroPonto>.from(registros)
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    Duration horasTrabalhadas = Duration.zero;
    if (sorted.length >= 2) {
      horasTrabalhadas = sorted[1].dateTime.difference(sorted[0].dateTime);
    }
    if (sorted.length >= 4) {
      horasTrabalhadas +=
          sorted[3].dateTime.difference(sorted[2].dateTime);
    }

    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 16),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                _formatarDataBR(data),
                style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 13,
                    color: PdfColors.indigo700),
              ),
              if (horasTrabalhadas != Duration.zero)
                pw.Text(
                  'Total: ${_formatarDuracao(horasTrabalhadas)}',
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.green700),
                ),
            ],
          ),
          pw.SizedBox(height: 8),
          ...sorted.map((r) => pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Row(children: [
                  pw.Container(
                    width: 90,
                    child: pw.Text(r.hora,
                        style: const pw.TextStyle(fontSize: 11)),
                  ),
                  pw.Text(r.tipo.label,
                      style: const pw.TextStyle(fontSize: 11)),
                  if (r.observacao != null && r.observacao!.isNotEmpty)
                    pw.Text(' — ${r.observacao}',
                        style: const pw.TextStyle(
                            fontSize: 10, color: PdfColors.grey600)),
                ]),
              )),
        ],
      ),
    );
  }

  Future<void> compartilhar(String caminho) async {
    await Share.shareXFiles([XFile(caminho)]);
  }

  Map<String, List<RegistroPonto>> _agruparPorDia(
      List<RegistroPonto> registros) {
    final Map<String, List<RegistroPonto>> agrupado = {};
    for (final r in registros) {
      agrupado.putIfAbsent(r.data, () => []).add(r);
    }
    return Map.fromEntries(
        agrupado.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
  }

  String _formatarDataHoje() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  String _formatarDataBR(String dataISO) {
    final partes = dataISO.split('-');
    return '${partes[2]}/${partes[1]}/${partes[0]}';
  }

  String _formatarDuracao(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return '${h.toString().padLeft(2, '0')}h${m.toString().padLeft(2, '0')}min';
  }
}
