import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'relatorio_service.dart';

/// Gera o PDF do relatório e baixa no navegador.
class RelatorioPdf {
  RelatorioPdf._();

  static const _laranja = PdfColor.fromInt(0xFFE67818);
  static const _escuro = PdfColor.fromInt(0xFF2C3E50);
  static const _verde = PdfColor.fromInt(0xFF2ECC71);

  static String _dois(int n) => n.toString().padLeft(2, '0');

  static String formatarData(DateTime d) =>
      '${_dois(d.day)}/${_dois(d.month)}/${d.year} ${_dois(d.hour)}:${_dois(d.minute)}';

  static String _nomeArquivo(RelatorioDados d) {
    final base = d.titulo
        .toLowerCase()
        .replaceAll(RegExp(r'[áàâã]'), 'a')
        .replaceAll(RegExp(r'[éê]'), 'e')
        .replaceAll('í', 'i')
        .replaceAll(RegExp(r'[óôõ]'), 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ç', 'c')
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-');
    final g = d.geradoEm;
    return 'relatorio-$base-${g.year}${_dois(g.month)}${_dois(g.day)}.pdf';
  }

  static Future<void> baixar(RelatorioDados d) async {
    final bytes = await _montar(d);
    await Printing.sharePdf(bytes: bytes, filename: _nomeArquivo(d));
  }

  static Future<Uint8List> _montar(RelatorioDados d) async {
    final doc = pw.Document(title: d.titulo, author: 'G.R.U');

    pw.Widget celula(String texto,
            {bool cabecalho = false, pw.Alignment? alinhamento}) =>
        pw.Container(
          alignment: alinhamento ?? pw.Alignment.centerLeft,
          padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          color: cabecalho ? _laranja : null,
          child: pw.Text(
            texto,
            style: pw.TextStyle(
              fontSize: 10,
              color: cabecalho ? PdfColors.white : _escuro,
              fontWeight: cabecalho ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        footer: (ctx) => pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Text(
            'G.R.U - Gerenciador de Resíduos Urbanos   |   Página ${ctx.pageNumber}/${ctx.pagesCount}',
            style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600),
          ),
        ),
        build: (ctx) => [
          pw.Text(d.titulo,
              style: pw.TextStyle(
                  fontSize: 22,
                  fontWeight: pw.FontWeight.bold,
                  color: _laranja)),
          pw.SizedBox(height: 4),
          pw.Text('${d.instituicao}  -  gerado em ${formatarData(d.geradoEm)}',
              style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700)),
          pw.Divider(color: _laranja, thickness: 1.2),
          pw.SizedBox(height: 8),
          if (d.aviso != null)
            pw.Text(d.aviso!,
                style: const pw.TextStyle(fontSize: 11, color: PdfColors.grey700)),
          if (d.resumo.isNotEmpty)
            pw.Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final r in d.resumo)
                  pw.Container(
                    width: 160,
                    padding: const pw.EdgeInsets.all(10),
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey400),
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(r.rotulo,
                            style: const pw.TextStyle(
                                fontSize: 9, color: PdfColors.grey700)),
                        pw.SizedBox(height: 3),
                        pw.Text(r.valor,
                            style: pw.TextStyle(
                                fontSize: 13,
                                fontWeight: pw.FontWeight.bold,
                                color: _escuro)),
                      ],
                    ),
                  ),
              ],
            ),
          if (d.barras.isNotEmpty && !d.vazio) ...[
            pw.SizedBox(height: 18),
            pw.Text(d.tituloBarras,
                style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: _escuro)),
            pw.SizedBox(height: 6),
            for (final b in d.barras)
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 3),
                child: pw.Row(children: [
                  pw.SizedBox(
                    width: 130,
                    child: pw.Text(b.rotulo,
                        maxLines: 1,
                        style: const pw.TextStyle(fontSize: 9)),
                  ),
                  pw.Stack(children: [
                    pw.Container(
                        width: 280,
                        height: 9,
                        decoration: pw.BoxDecoration(
                            color: PdfColors.grey200,
                            borderRadius: pw.BorderRadius.circular(5))),
                    pw.Container(
                        width: 280 * b.fracao.clamp(0.0, 1.0).toDouble(),
                        height: 9,
                        decoration: pw.BoxDecoration(
                            color: _verde,
                            borderRadius: pw.BorderRadius.circular(5))),
                  ]),
                  pw.SizedBox(width: 8),
                  pw.Text(b.valor, style: const pw.TextStyle(fontSize: 9)),
                ]),
              ),
          ],
          if (!d.vazio) ...[
            pw.SizedBox(height: 18),
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              children: [
                pw.TableRow(children: [
                  for (final c in d.colunas) celula(c, cabecalho: true),
                ]),
                for (final linha in d.linhas)
                  pw.TableRow(children: [for (final c in linha) celula(c)]),
              ],
            ),
          ],
          if (d.eventos.isNotEmpty) ...[
            pw.SizedBox(height: 18),
            pw.Text(d.tituloEventos,
                style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: _escuro)),
            pw.SizedBox(height: 6),
            for (final e in d.eventos)
              pw.Padding(
                padding: const pw.EdgeInsets.symmetric(vertical: 2),
                child: pw.Text('- ${e.texto}  (${e.quando})',
                    style: const pw.TextStyle(fontSize: 9)),
              ),
          ],
        ],
      ),
    );

    return doc.save();
  }
}
