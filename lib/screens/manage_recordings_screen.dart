import 'package:flutter/material.dart';
import 'package:med_assistance_frontend/screens/profile_screen.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:permission_handler/permission_handler.dart';

class ManageRecordingsScreen extends StatefulWidget {
  ManageRecordingsScreen({super.key});

  @override
  _ManageRecordingsScreenState createState() => _ManageRecordingsScreenState();
}

class _ManageRecordingsScreenState extends State<ManageRecordingsScreen> {
  // Mock data
  final List<Map<String, String>> mockRecordings = [
    {
      "procedure": "Artroplastia",
      "patient": "Ricardo Queiroz",
      "date": "19/07/2022",
      "startTime": "14:37:12",
      "endTime": "17:25:48",
      "transcription": "Transcrição do áudio 1... (texto longo) Transcrição do áudio 1... (texto longo) Transcrição do áudio 1... (texto longo) Transcrição do áudio 1... (texto longo) Transcrição do áudio 1... (texto longo)",
    },
    {
      "procedure": "Cesarian",
      "patient": "Ângela Munhoz Souza",
      "date": "27/02/2022",
      "startTime": "16:26:49",
      "endTime": "18:57:13",
      "transcription": "Transcrição do áudio 2... (texto longo) Transcrição do áudio 2... (texto longo) Transcrição do áudio 2... (texto longo) Transcrição do áudio 2... (texto longo) Transcrição do áudio 2... (texto longo)",
    },
    {
      "procedure": "Apendicectomia",
      "patient": "Matheo Larevi",
      "date": "17/08/2023",
      "startTime": "05:33:43",
      "endTime": "12:10:01",
      "transcription": "Transcrição do áudio 3... (texto longo) Transcrição do áudio 3... (texto longo) Transcrição do áudio 3... (texto longo) Transcrição do áudio 3... (texto longo) Transcrição do áudio 3... (texto longo)",
    },
    {
      "procedure": "Rinoplastia",
      "patient": "Sarah Voracchi",
      "date": "21/01/2024",
      "startTime": "12:01:18",
      "endTime": "14:48:57",
      "transcription": "Transcrição do áudio 4... (texto longo) Transcrição do áudio 4... (texto longo) Transcrição do áudio 4... (texto longo) Transcrição do áudio 4... (texto longo) Transcrição do áudio 4... (texto longo)",
    },
    {
      "procedure": "Rinoplastia",
      "patient": "Sarah Voracchi",
      "date": "21/01/2024",
      "startTime": "12:01:18",
      "endTime": "14:48:57",
      "transcription": "Transcrição do áudio 4... (texto longo) Transcrição do áudio 4... (texto longo) Transcrição do áudio 4... (texto longo) Transcrição do áudio 4... (texto longo) Transcrição do áudio 4... (texto longo)",
    },
    {
      "procedure": "Rinoplastia",
      "patient": "Sarah Voracchi",
      "date": "21/01/2024",
      "startTime": "12:01:18",
      "endTime": "14:48:57",
      "transcription": "Transcrição do áudio 4... (texto longo) Transcrição do áudio 4... (texto longo) Transcrição do áudio 4... (texto longo) Transcrição do áudio 4... (texto longo) Transcrição do áudio 4... (texto longo)",
    },
    {
      "procedure": "Rinoplastia",
      "patient": "Sarah Voracchi",
      "date": "21/01/2024",
      "startTime": "12:01:18",
      "endTime": "14:48:57",
      "transcription": "Transcrição do áudio 4... (texto longo) Transcrição do áudio 4... (texto longo) Transcrição do áudio 4... (texto longo) Transcrição do áudio 4... (texto longo) Transcrição do áudio 4... (texto longo)",
    },
    {
      "procedure": "Rinoplastia",
      "patient": "Sarah Voracchi",
      "date": "21/01/2024",
      "startTime": "12:01:18",
      "endTime": "14:48:57",
      "transcription": "Transcrição do áudio 4... (texto longo) Transcrição do áudio 4... (texto longo) Transcrição do áudio 4... (texto longo) Transcrição do áudio 4... (texto longo) Transcrição do áudio 4... (texto longo)",
    },
    {
      "procedure": "Rinoplastia",
      "patient": "Sarah Voracchi",
      "date": "21/01/2024",
      "startTime": "12:01:18",
      "endTime": "14:48:57",
      "transcription": "Transcrição do áudio 4... (texto longo) Transcrição do áudio 4... (texto longo) Transcrição do áudio 4... (texto longo) Transcrição do áudio 4... (texto longo) Transcrição do áudio 4... (texto longo)",
    },
    {
      "procedure": "Rinoplastia",
      "patient": "Sarah Voracchi",
      "date": "21/01/2024",
      "startTime": "12:01:18",
      "endTime": "14:48:57",
      "transcription": "Transcrição do áudio 4... (texto longo) Transcrição do áudio 4... (texto longo) Transcrição do áudio 4... (texto longo) Transcrição do áudio 4... (texto longo) Transcrição do áudio 4... (texto longo)",
    },
    {
      "procedure": "Rinoplastia",
      "patient": "Sarah Voracchi",
      "date": "21/01/2024",
      "startTime": "12:01:18",
      "endTime": "14:48:57",
      "transcription": "Transcrição do áudio 4... (texto longo) Transcrição do áudio 4... (texto longo) Transcrição do áudio 4... (texto longo) Transcrição do áudio 4... (texto longo) Transcrição do áudio 4... (texto longo)",
    },
    {
      "procedure": "Rinoplastia",
      "patient": "Sarah Voracchi",
      "date": "21/01/2024",
      "startTime": "12:01:18",
      "endTime": "14:48:57",
      "transcription": "Transcrição do áudio 4... (texto longo) Transcrição do áudio 4... (texto longo) Transcrição do áudio 4... (texto longo) Transcrição do áudio 4... (texto longo) Transcrição do áudio 4... (texto longo)",
    },
  ];

  Future<void> _exportToPDF(String title, String content) async {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) => pw.Padding(
          padding: const pw.EdgeInsets.all(20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(title, style: pw.TextStyle(fontSize: 24)),
              pw.SizedBox(height: 20),
              pw.Text(content, style: pw.TextStyle(fontSize: 16)),
            ],
          ),
        ),
      ),
    );
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save());
  }

  Future<void> _requestPermissions() async {
    await [Permission.storage].request();
  }

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientContainer(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Buscar',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: mockRecordings.length,
                  itemBuilder: (context, index) {
                    final recording = mockRecordings[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      child: ExpansionTile(
                        leading: const Icon(Icons.info_outline),
                        title: Text(recording['procedure']!),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(recording['patient']!),
                            Text(recording['date']!),
                            Text(
                                'HIC: ${recording['startTime']} - HFC: ${recording['endTime']}'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            // Implement delete functionality
                          },
                        ),
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Transcrição:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  recording['transcription']!.length > 200
                                      ? '${recording['transcription']!.substring(0, 200)}...'
                                      : recording['transcription']!,
                                ),
                                const SizedBox(height: 5),
                                IconButton(
                                  icon: const Icon(Icons.picture_as_pdf),
                                  onPressed: () {
                                    _exportToPDF(recording['procedure']!,
                                        recording['transcription']!);
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/main');
                },
                child: const Text('Retornar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
