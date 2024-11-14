import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:med_assistance_frontend/components/background_container.dart';
import 'package:med_assistance_frontend/services/recording_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/recording_card.dart';
import '../../components/search_field.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ManageRecordingsScreen extends StatefulWidget {
  const ManageRecordingsScreen({Key? key}) : super(key: key);

  @override
  _ManageRecordingsScreenState createState() => _ManageRecordingsScreenState();
}

Future<void> generatePdf(String patientName, String medicalSummary) async {
  final pdf = pw.Document();
  final String date = DateFormat('dd/MM/yyyy').format(DateTime.now());

  final fontData = await rootBundle.load('assets/Roboto-Regular.ttf');
  final fontBoldData = await rootBundle.load('assets/Roboto-Bold.ttf');
  final font = pw.Font.ttf(fontData);
  final fontBold = pw.Font.ttf(fontBoldData);

  final summaryLines = medicalSummary.split('\n');

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
              'Resumo Médico',
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
        _buildSectionTitle('Dados do Paciente:', fontBold),
        pw.SizedBox(height: 5),
        pw.Text('Nome: $patientName',
            style: pw.TextStyle(font: font, fontSize: 16)),
        pw.SizedBox(height: 10),
        pw.Divider(),
        _buildSectionTitle('Resumo Médico Geral:', fontBold),
        pw.SizedBox(height: 10),
        ...summaryLines.map((line) => pw.Text(
              line,
              style: pw.TextStyle(font: font, fontSize: 14),
            )),
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

pw.Widget _buildSectionTitle(String title, pw.Font fontBold) {
  return pw.Text(
    title,
    style: pw.TextStyle(
      font: fontBold,
      fontSize: 18,
      fontWeight: pw.FontWeight.bold,
      color: PdfColors.blueAccent,
    ),
  );
}

class _ManageRecordingsScreenState extends State<ManageRecordingsScreen> {
  final RecordingService recordingService = RecordingService();
  List<dynamic> recordings = [];
  List<dynamic> filteredRecordings = [];
  bool isLoading = true;
  String? doctorId;
  String? errorMessage;
  String searchQuery = '';
  bool isGeneratingHistory = false;
  String patientId = '';
  Map<String, bool> isGeneratingHistoryMap = {};

  @override
  void initState() {
    super.initState();
    _loadDoctorId().then((_) {
      fetchRecordings();
    });
  }

  Future<void> _loadDoctorId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      doctorId = prefs.getString('doctorId');
    });
  }

  Future<void> deleteRecording(String procedureId, String recordingId) async {
    try {
      await recordingService.deleteRecording(procedureId, recordingId);
      setState(() {
        recordings = recordings.map((procedure) {
          if (procedure['procedure_id'] == procedureId) {
            procedure['gravacoes'] = procedure['gravacoes']
                .where((g) => g['id'] != recordingId)
                .toList();
          }
          return procedure;
        }).toList();
        _filterRecordings();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Gravação deletada com sucesso'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Falha ao deletar a gravação'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<String> generateMedicalHistory(
      String patientId, List<dynamic> sumarizacoes) async {
    setState(() {
      isGeneratingHistoryMap[patientId] = true;
    });
    try {
      final history = await recordingService.generateMedicalHistory(
        patientId: patientId,
        sumarizacoes: sumarizacoes,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Histórico médico gerado com sucesso'),
          backgroundColor: Colors.green,
        ),
      );

      return history;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao gerar histórico médico'),
          backgroundColor: Colors.red,
        ),
      );
      return ''; // Retorna uma string vazia em caso de erro
    } finally {
      setState(() {
        isGeneratingHistoryMap[patientId] = false;
      });
    }
  }

  void fetchRecordings() async {
    try {
      final proceduresData = await recordingService.fetchRecordings();
      setState(() {
        recordings = proceduresData;
        filteredRecordings = proceduresData;
        patientId = recordings[0]["gravacoes"][0]["paciente_id"];
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Erro ao se conectar ao servidor.';
      });
    }
  }

  void _filterRecordings() {
    setState(() {
      if (searchQuery.isEmpty) {
        filteredRecordings = recordings;
      } else {
        filteredRecordings = recordings
            .where((procedure) =>
                procedure['paciente_info']['name']
                    ?.toLowerCase()
                    .contains(searchQuery.toLowerCase()) ??
                false)
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Histórico de Pacientes",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ),
      body: BackgroundContainer(
        child: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
                  ? _buildErrorContent()
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: SearchField(
                            onSearch: (value) {
                              setState(() {
                                searchQuery = value;
                                _filterRecordings();
                              });
                            },
                            label: "Buscar por nome",
                          ),
                        ),
                        Expanded(
                          child: filteredRecordings.isEmpty
                              ? _buildNoRecordingsContent()
                              : _buildMinimalistRecordingsContent(),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }

  Widget _buildMinimalistRecordingsContent() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filteredRecordings.length,
      itemBuilder: (context, index) {
        final procedure = filteredRecordings[index];
        final pacienteInfo = procedure['paciente_info'];
        final gravacoes = procedure['gravacoes'] as List<dynamic>;
        final sumarizacoes = gravacoes.map((g) => g['sumarizacao']).toList();

        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 1,
            child: ListTile(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              title: Text(
                pacienteInfo['name'] ?? 'Paciente desconhecido',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                'Procedimentos: ${gravacoes.length}',
                style: const TextStyle(color: Colors.black54),
              ),
              trailing: FittedBox(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(Icons.history, color: Colors.blue.shade700),
                      onPressed: () async {
                        final historyText = await generateMedicalHistory(
                            patientId, sumarizacoes);

                        if (historyText.isNotEmpty) {
                          generatePdf(
                            pacienteInfo['name'] ?? 'Paciente desconhecido',
                            historyText,
                          );
                        }
                      },
                    ),
                    const Text(
                      'Gerar resumo clínico',
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (_) {
                    return ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: gravacoes.map((gravacao) {
                        return RecordingCard(
                          pacienteInfo: pacienteInfo,
                          recording: gravacao,
                          onDelete: () => deleteRecording(
                              procedure['procedure_id'], gravacao['id']),
                        );
                      }).toList(),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorContent() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              errorMessage!,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, "/main"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
              child: const Text('Voltar',
                  style: TextStyle(fontSize: 18, color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoRecordingsContent() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.no_accounts,
              size: 80,
            ),
            SizedBox(height: 16),
            Text(
              'Nenhum paciente encontrado',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
