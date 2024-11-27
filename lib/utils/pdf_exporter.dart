import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PDFExporter {
  static Future<void> exportToPDF(
    String procedureType,
    String exactProcedureName,
    String patientName,
    String patientBirthdate,
    String patientStreet,
    String patientCity,
    String patientState,
    String patientCep,
    String patientNumber,
    String patientCpf,
    String patientPhone,
    String doctorName,
    String doctorEmail,
    String doctorAffiliation,
    String transcription,
    String summarize,
  ) async {
    final pdf = pw.Document();
    final String date = DateFormat('dd/MM/yyyy').format(DateTime.now());

    final image = await imageFromAssetBundle('assets/logo.png');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              image != null ? pw.Image(image, height: 50) : pw.SizedBox(),
              pw.Text(
                'Relatório de Procedimento',
                style: pw.TextStyle(
                  fontSize: 20,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue,
                ),
              ),
              pw.Text(
                'Data: $date',
                style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey),
              ),
            ],
          ),
          pw.SizedBox(height: 10),
          pw.Divider(),
          pw.SizedBox(height: 10),
          _buildSectionTitle('Informações do Paciente:'),
          pw.SizedBox(height: 5),
          pw.Text('Nome: $patientName'),
          pw.Text('Data de Nascimento: $patientBirthdate'),
          pw.Text(
              'Endereço: $patientStreet, $patientNumber - $patientCity/$patientState'),
          pw.Text('CPF: $patientCpf'),
          pw.Text('Telefone: $patientPhone'),
          pw.SizedBox(height: 10),
          pw.Divider(),
          _buildSectionTitle('Informações do Médico:'),
          pw.SizedBox(height: 5),
          pw.Text('Nome: $doctorName'),
          pw.Text('Email: $doctorEmail'),
          pw.Text('Afiliação: $doctorAffiliation'),
          pw.SizedBox(height: 10),
          pw.Divider(),
          _buildSectionTitle('Informações do Procedimento:'),
          pw.SizedBox(height: 5),
          pw.Text('Tipo de Procedimento: $procedureType'),
          pw.Text('Nome Exato do Procedimento: $exactProcedureName'),
          pw.SizedBox(height: 10),
          pw.Divider(),
          _buildSectionTitle('Sumário do Procedimento:'),
          pw.SizedBox(height: 10),
          pw.Text(summarize.isNotEmpty ? summarize : 'Sem sumário disponível'),
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'Gerado em: $date',
              style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey),
            ),
          ),
        ],
        footer: (pw.Context context) {
          return pw.Container(
            alignment: pw.Alignment.centerRight,
            margin: const pw.EdgeInsets.only(top: 1.0 * PdfPageFormat.cm),
            child: pw.Text(
              'Página ${context.pageNumber} de ${context.pagesCount}',
              style: const pw.TextStyle(color: PdfColors.grey, fontSize: 12),
            ),
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  static pw.Widget _buildSectionTitle(String title) {
    return pw.Text(
      title,
      style: pw.TextStyle(
        fontSize: 18,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.blueAccent,
      ),
    );
  }
}
