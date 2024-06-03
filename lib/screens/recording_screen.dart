import 'package:flutter/material.dart';
import 'package:med_assistance_frontend/screens/profile_screen.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:http_parser/http_parser.dart'; // Import necessário
import 'package:shared_preferences/shared_preferences.dart'; // Import para SharedPreferences

class RecordingScreen extends StatefulWidget {
  final Map<String, dynamic> procedureData; // Recebe os dados do procedimento

  const RecordingScreen({Key? key, required this.procedureData})
      : super(key: key);

  @override
  _RecordingScreenState createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  final record = AudioRecorder();
  bool isRecording = false;
  String? recordingPath;
  String? doctorId;

  @override
  void initState() {
    super.initState();
    prepareRecordingPath().then((_) {
      requestPermission();
    });
    _loadDoctorId(); // Carrega o doctorId
  }

  Future<void> prepareRecordingPath() async {
    final directory = await getApplicationDocumentsDirectory();
    recordingPath = '${directory.path}/myRecording.m4a';
  }

  Future<void> requestPermission() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Permissão necessária"),
          content: const Text(
              "Esse app requer acesso ao microfone para gravar aúdio."),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  Future<void> _loadDoctorId() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      doctorId = prefs.getString('doctorId') ?? '';
    });
  }

  Future<void> toggleRecording() async {
    final isCurrentlyRecording = await record.isRecording();
    if (!isCurrentlyRecording) {
      if (await record.hasPermission()) {
        if (recordingPath == null) {
          await prepareRecordingPath();
        }
        await record.start(const RecordConfig(), path: recordingPath!);

        setState(() => isRecording = true);
      }
    } else {
      final path = await record.stop();
      setState(() => isRecording = false);
      print('Recording stopped! File saved at: $path');
      if (path != null && await File(path).length() > 0) {
        await _sendRecording(path);
      } else {
        print('Recording file is empty or does not exist.');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Recording file is empty or does not exist.")),
        );
      }
    }
  }

  Future<void> _sendRecording(String filePath) async {
    try {
      print({
        'procedure_type': widget.procedureData['procedure_type'],
        'patient_name': widget.procedureData['patient_name'],
        'exact_procedure_name': widget.procedureData['exact_procedure_name'],
        'doctor_id': doctorId,
      });

      var url = Uri.parse('http://10.0.2.2:8000/api/procedures/upload');
      var request = http.MultipartRequest('POST', url)
        ..fields['procedure_type'] = widget.procedureData['procedure_type']
        ..fields['patient_name'] = widget.procedureData['patient_name']
        ..fields['exact_procedure_name'] = widget.procedureData['exact_procedure_name']
        ..fields['doctor_id'] = doctorId ?? '' // Adiciona o doctorId
        ..files.add(await http.MultipartFile.fromPath(
          'file',
          filePath,
          contentType: MediaType('audio', 'mp4'),
        ));

      var response = await request.send();

      if (response.statusCode == 200) {
        print(await response.stream.bytesToString());
        print('Upload completo.');
        _showSuccessPopup();
      } else {
        print('Erro ao enviar o arquivo.');
        print('Status Code: ${response.statusCode}');
        print('Response: ${await response.stream.bytesToString()}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao realizar gravação, tente novamente mais tarde ou entre em contato com a nossa equipe.')),
        );
      }
    } catch (e) {
      print('Erro ao enviar o arquivo: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro subindo a gravação:  $e')),
      );
    }
  }

  void _showSuccessPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sucesso"),
        content: const Text("Gravação realizada com sucesso."),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/main');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        GradientContainer(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                IconButton(
                  icon: Icon(isRecording ? Icons.stop : Icons.mic),
                  onPressed: toggleRecording,
                  color: !isRecording ? Colors.black : Colors.red,
                  iconSize: 100,
                ),
                const SizedBox(height: 24),
                Text(isRecording ? "Toque para Parar" : "Toque para Iniciar"),
              ],
            ),
          ),
        ),
        Positioned(
          top: 32,
          left: 16,
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/preRecording');
            },
          ),
        ),
      ]),
    );
  }

  @override
  void dispose() {
    record.dispose();
    super.dispose();
  }
}
