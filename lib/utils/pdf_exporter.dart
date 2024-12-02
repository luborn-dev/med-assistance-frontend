import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PDFExporter {
  static Future<void> exportToPDF({
    required String procedureType,
    required String exactProcedureName,
    required String patientName,
    required String patientBirthdate,
    required String patientStreet,
    required String patientCity,
    required String patientState,
    required String patientCep,
    required String patientNumber,
    required String patientCpf,
    required String patientPhone,
    required String doctorName,
    required String doctorEmail,
    required String doctorAffiliation,
    required String transcription,
    required Map<String, String> summarize, // Sumário estruturado
  }) async {
    final pdf = pw.Document();
    final String date = DateFormat('dd/MM/yyyy').format(DateTime.now());

    final image = await imageFromAssetBundle('assets/logo.png');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) => [
          _buildHeader(image, date),
          pw.SizedBox(height: 10),
          _buildPatientInfo(
            patientName,
            patientBirthdate,
            patientStreet,
            patientCity,
            patientState,
            patientCep,
            patientNumber,
            patientCpf,
            patientPhone,
          ),
          pw.Divider(),
          _buildDoctorInfo(doctorName, doctorEmail, doctorAffiliation),
          pw.Divider(),
          _buildProcedureInfo(procedureType, exactProcedureName),
          pw.Divider(),
          _buildSummarizeSection(summarize),
          pw.Divider(),
          _buildTranscriptionSection(transcription),
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

  static pw.Widget _buildHeader(pw.ImageProvider? image, String date) {
    return pw.Row(
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
    );
  }

  static pw.Widget _buildPatientInfo(
      String name,
      String birthdate,
      String street,
      String city,
      String state,
      String cep,
      String number,
      String cpf,
      String phone,
      ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Informações do Paciente:'),
        pw.Text('Nome: $name'),
        pw.Text('Data de Nascimento: $birthdate'),
        pw.Text('Endereço: $street, $number - $city/$state'),
        pw.Text('CPF: $cpf'),
        pw.Text('Telefone: $phone'),
      ],
    );
  }

  static pw.Widget _buildDoctorInfo(String name, String email, String affiliation) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Informações do Médico:'),
        pw.Text('Nome: $name'),
        pw.Text('Email: $email'),
        pw.Text('Afiliação: $affiliation'),
      ],
    );
  }

  static pw.Widget _buildProcedureInfo(String type, String name) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Informações do Procedimento:'),
        pw.Text('Tipo de Procedimento: $type'),
        pw.Text('Nome Exato do Procedimento: $name'),
      ],
    );
  }

  static pw.Widget _buildSummarizeSection(Map<String, String> summarize) {
    final sections = {
      'Sintomas e Queixas': summarize['symptoms_and_complaints'] ?? '',
      'Histórico Médico': summarize['medical_history'] ?? '',
      'Diagnóstico': summarize['diagnosis'] ?? '',
      'Tratamentos e Procedimentos': summarize['treatments_and_procedures'] ?? '',
      'Recomendações': summarize['recommendations'] ?? '',
    };

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Sumário do Procedimento:'),
        ...sections.entries.map((entry) {
          return pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 8),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  entry.key,
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.black,
                  ),
                ),
                pw.Text(
                  entry.value.isNotEmpty ? entry.value : 'Sem informações disponíveis',
                  style: const pw.TextStyle(fontSize: 14, color: PdfColors.grey800),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  static pw.Widget _buildTranscriptionSection(String transcription) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Transcrição do Procedimento:'),
        pw.Text(transcription.isNotEmpty
            ? transcription
            : 'Sem transcrição disponível'),
      ],
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
