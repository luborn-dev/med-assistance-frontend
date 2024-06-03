import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Import para SharedPreferences

import '../widget/gradient_container.dart';

class ManageRecordingsScreen extends StatefulWidget {
  ManageRecordingsScreen({super.key});

  @override
  _ManageRecordingsScreenState createState() => _ManageRecordingsScreenState();
}

class _ManageRecordingsScreenState extends State<ManageRecordingsScreen> {
  List<dynamic> recordings = [];
  bool isLoading = true;
  String? doctorId;
  String? errorMessage; // Novo estado para armazenar a mensagem de erro

  @override
  void initState() {
    super.initState();
    _requestPermissions();
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

  Future<void> showDeleteConfirmationDialog(String recordingId) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirmar Exclusão'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Você tem certeza que deseja excluir este procedimento?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Confirmar'),
              onPressed: () {
                Navigator.of(context).pop();
                deleteRecording(recordingId);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> deleteRecording(String recordingId) async {
    final response = await http.delete(
      Uri.parse('http://10.0.2.2:8000/api/procedures/$recordingId'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );

    if (response.statusCode == 200) {
      setState(() {
        recordings.removeWhere((recording) => recording['_id'] == recordingId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Procedimento deletado com sucesso')),
      );
      await fetchRecordings();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Falha ao deletar o procedimento')),
      );
    }
  }

  Future<void> fetchRecordings() async {
    if (doctorId == null) {
      // Trate o caso onde doctorId não está definido
      setState(() {
        isLoading = false;
        errorMessage = 'Doctor ID não está definido';
      });
      return;
    }

    final response = await http.get(
      Uri.parse('http://10.0.2.2:8000/api/procedures?doctor_id=$doctorId'),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
    );
    if (response.statusCode == 200) {
      setState(() {
        recordings = json.decode(utf8.decode(response.bodyBytes));

        isLoading = false;
      });
    } else if (response.statusCode == 404) {
      // Handle 404 status
      setState(() {
        isLoading = false;
        errorMessage =
            'Você não tem nenhum procedimento registrado em seu nome.';
      });
    } else {
      // Handle other errors
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load recordings';
      });
    }
  }

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
    await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save());
  }

  Future<void> _requestPermissions() async {
    await [Permission.storage].request();
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
                            style: const TextStyle(
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, "/main"),
                              child: const Text("Voltar"))
                        ],
                      ),
                    )
                  : Column(
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
                            itemCount: recordings.length,
                            itemBuilder: (context, index) {
                              final recording = recordings[index];
                              return Card(
                                margin:
                                    const EdgeInsets.symmetric(vertical: 10),
                                child: ExpansionTile(
                                  leading: const Icon(Icons.info_outline),
                                  title: Text(
                                      recording['exact_procedure_name'] ?? ''),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(recording['patient_name'] ?? ''),
                                      Text(recording['procedure_type'] ?? ''),
                                    ],
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    onPressed: () {
                                      final recordingId = recording['id'];
                                      showDeleteConfirmationDialog(recordingId);
                                    },
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Transcrição:',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          const SizedBox(height: 5),
                                          Text(
                                            recording['transcription']?.length >
                                                    200
                                                ? '${recording['transcription'].substring(0, 200)}...'
                                                : recording['transcription'] ??
                                                    '',
                                          ),
                                          const SizedBox(height: 5),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.picture_as_pdf),
                                            onPressed: () {
                                              _exportToPDF(
                                                recording[
                                                        'exact_procedure_name'] ??
                                                    '',
                                                recording['transcription'] ??
                                                    '',
                                              );
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
