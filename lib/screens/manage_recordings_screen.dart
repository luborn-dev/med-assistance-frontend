import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/recording_service.dart';
import '../widget/gradient_container.dart';
import '../utils/pdf_exporter.dart';
import '../widget/recording_card.dart';
import '../widget/search_field.dart';

class ManageRecordingsScreen extends StatefulWidget {
  @override
  _ManageRecordingsScreenState createState() => _ManageRecordingsScreenState();
}

class _ManageRecordingsScreenState extends State<ManageRecordingsScreen> {
  List<dynamic> recordings = [];
  bool isLoading = true;
  String? doctorId;
  String? errorMessage;

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

  Future<void> deleteRecording(String recordingId) async {
    try {
      await RecordingService.deleteRecording(recordingId);
      setState(() {
        recordings.removeWhere((recording) => recording['id'] == recordingId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Procedimento deletado com sucesso')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha ao deletar o procedimento')),
      );
    }
  }

  Future<void> fetchRecordings() async {
    if (doctorId == null) {
      setState(() {
        isLoading = false;
        errorMessage = 'Doctor ID não está definido';
      });
      return;
    }

    try {
      final recordingsData = await RecordingService.fetchRecordings(doctorId!);

      setState(() {
        if (recordingsData.isEmpty) {
          errorMessage = 'Nenhum procedimento encontrado para este médico.';
        } else {
          recordings = recordingsData;
          errorMessage = null;
        }
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage =
            'Erro ao se conectar ao servidor. Verifique sua conexão ou tente novamente mais tarde.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientContainer(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            errorMessage!,
                            style: const TextStyle(fontSize: 22),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () =>
                                Navigator.pushNamed(context, "/main"),
                            child: const Text("Voltar"),
                          ),
                        ],
                      ),
                    )
                  : recordings.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                'Nenhum procedimento encontrado para este médico.',
                                style: TextStyle(fontSize: 22),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () =>
                                    Navigator.pushNamed(context, "/main"),
                                child: const Text("Voltar"),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            const SizedBox(height: 10),
                            SearchField(
                              onSearch: (value) {
                                setState(() {
                                  recordings = recordings.where((recording) {
                                    final patientName =
                                        recording['patient_name']
                                                ?.toLowerCase() ??
                                            '';
                                    final procedureName =
                                        recording['exact_procedure_name']
                                                ?.toLowerCase() ??
                                            '';
                                    final searchTerm = value.toLowerCase();
                                    return patientName.contains(searchTerm) ||
                                        procedureName.contains(searchTerm);
                                  }).toList();
                                });
                              },
                            ),
                            const SizedBox(height: 10),
                            Expanded(
                              child: ListView.builder(
                                itemCount: recordings.length,
                                itemBuilder: (context, index) {
                                  final recording = recordings[index];
                                  return RecordingCard(
                                    recording: recording,
                                    onDelete: (id) => deleteRecording(id),
                                    onExportPDF: (title, content) {
                                      PDFExporter.exportToPDF(
                                        recording['procedure_type'] ?? '',
                                        recording['exact_procedure_name'] ?? '',
                                        recording['patient_name'] ?? '',
                                        recording['patient_birthdate'] ?? '',
                                        recording['patient_address'] ?? '',
                                        recording['patient_cpf'] ?? '',
                                        recording['patient_phone'] ?? '',
                                        recording['doctor_name'] ?? '',
                                        recording['doctor_email'] ?? '',
                                        recording['doctor_affiliation'] ?? '',
                                        recording['transcription'] ?? '',
                                        recording['summarize'] ?? '',
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: 200,
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                      context, '/main');
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue.shade700,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: const RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(12)),
                                  ),
                                ),
                                child: const Text('Retornar',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
        ),
      ),
    );
  }
}
