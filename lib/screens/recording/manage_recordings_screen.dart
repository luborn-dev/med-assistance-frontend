import 'package:flutter/material.dart';
import 'package:med_assistance_frontend/components/background_container.dart';
import 'package:med_assistance_frontend/services/recording_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/recording_card.dart';
import '../../components/search_field.dart';

class ManageRecordingsScreen extends StatefulWidget {
  const ManageRecordingsScreen({Key? key}) : super(key: key);

  @override
  _ManageRecordingsScreenState createState() => _ManageRecordingsScreenState();
}

class _ManageRecordingsScreenState extends State<ManageRecordingsScreen> {
  final RecordingService recordingService = RecordingService();
  List<dynamic> recordings = [];
  List<dynamic> filteredRecordings = [];
  bool isLoading = true;
  String? doctorId;
  String? errorMessage;
  String searchQuery = '';

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

  Future<void> generateMedicalHistory(
      String patientId, List<dynamic> transcriptions) async {
    try {
      await recordingService.generateMedicalHistory(
          patientId: patientId, transcriptions: transcriptions);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Histórico médico gerado com sucesso'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao gerar histórico médico'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void fetchRecordings() async {
    try {
      final proceduresData = await recordingService.fetchRecordings();
      setState(() {
        recordings = proceduresData;
        filteredRecordings = proceduresData;
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
          "Gerenciar Gravações",
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
        final transcriptions = gravacoes.map((g) => g['transcricao']).toList();

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
              trailing: IconButton(
                icon: Icon(Icons.history, color: Colors.blue.shade700),
                onPressed: () =>
                    generateMedicalHistory(pacienteInfo['id'], transcriptions),
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
