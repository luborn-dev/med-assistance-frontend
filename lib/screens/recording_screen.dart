import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:med_assistance_frontend/widget/gradient_container.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class RecordingScreen extends StatefulWidget {
  final Map<String, dynamic> procedureData;

  const RecordingScreen({Key? key, required this.procedureData})
      : super(key: key);

  @override
  _RecordingScreenState createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen> {
  final AudioRecorder _record = AudioRecorder();
  bool _isRecording = false;
  bool _isProcessing = false; // Indicador de processamento (carregando)
  String? _recordingPath;
  String? _doctorId;
  String? _patientId;
  Duration _duration = Duration();
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _prepareRecordingPath().then((_) {
      _requestPermission();
    });
    _loadDoctorId();
    _loadPatientId();
  }

  Future<void> _prepareRecordingPath() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      _recordingPath = '${directory.path}/myRecording.m4a';
    } catch (e) {
      _showError('Erro ao preparar o caminho de gravação: $e');
    }
  }

  Future<void> _requestPermission() async {
    var status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permissão necessária"),
        content:
        const Text("Este app requer acesso ao microfone para gravar áudio."),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  Future<void> _loadDoctorId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _doctorId = prefs.getString('doctorId') ?? '';
      });
    } catch (e) {
      _showError('Erro ao carregar o ID do médico: $e');
    }
  }

  Future<void> _loadPatientId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _patientId = prefs.getString('patientId') ?? '';
      });
    } catch (e) {
      _showError('Erro ao carregar o ID do paciente: $e');
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
      setState(() {
        _duration = Duration(seconds: _duration.inSeconds + 1);
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _duration = Duration();
    });
  }

  Future<void> _toggleRecording() async {
    try {
      final isCurrentlyRecording = await _record.isRecording();
      if (!isCurrentlyRecording) {
        if (await _record.hasPermission()) {
          if (_recordingPath == null) {
            await _prepareRecordingPath();
          }
          await _record.start(
            const RecordConfig(),
            path: _recordingPath!,
          );

          setState(() {
            _isRecording = true;
          });
          _startTimer();
        } else {
          _showError('Permissão para gravação negada.');
        }
      } else {
        await _record.stop();

        setState(() {
          _isRecording = false;
          _isProcessing = true;
        });
        _stopTimer();

        if (_recordingPath != null && await File(_recordingPath!).length() > 0) {
          _showSendConfirmationDialog();
        } else {
          _showError("Arquivo de gravação está vazio ou não existe.");
          setState(() {
            _isProcessing = false;
          });
        }
      }
    } catch (e) {
      _showError('Erro durante a gravação: $e');
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showSendConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text("Enviar Gravação"),
        content: const Text("Deseja enviar a gravação?"),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetRecording();
              setState(() {
                _isProcessing = false;
              });
            },
            child: const Text("Não"),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _sendRecording();
            },
            child: const Text("Sim"),
          ),
        ],
      ),
    );
  }

  Future<void> _sendRecording() async {
    if (_recordingPath == null) {
      _showError('Nenhuma gravação disponível para enviar.');
      setState(() {
        _isProcessing = false;
      });
      return;
    }

    try {
      var url = Uri.parse('http://172.20.10.3:8000/api/procedures/upload');
      var request = http.MultipartRequest('POST', url)
        ..fields['procedure_type'] = widget.procedureData['procedure_type']
        ..fields['patient_name'] = widget.procedureData['patient_name']
        ..fields['exact_procedure_name'] =
        widget.procedureData['exact_procedure_name']
        ..fields['doctor_id'] = _doctorId ?? ''
        ..files.add(await http.MultipartFile.fromPath(
          'file',
          _recordingPath!,
          contentType: MediaType('audio', 'mp4'),
        ));

      var response = await request.send();

      if (response.statusCode == 200) {
        _showSuccessPopup();
      } else {
        final responseBody = await response.stream.bytesToString();
        final decodedResponse = jsonDecode(responseBody);

        String errorMessage = 'Erro ao enviar a gravação.';

        if (decodedResponse != null && decodedResponse['detail'] != null) {
          errorMessage = decodedResponse['detail'];
        } else {
          switch (response.statusCode) {
            case 400:
              errorMessage =
              'Requisição inválida. Verifique os dados e tente novamente.';
              break;
            case 422:
              errorMessage =
              'Dados inválidos. Por favor, corrija e tente novamente.';
              break;
            case 500:
              errorMessage =
              'Erro no servidor. Por favor, tente novamente mais tarde.';
              break;
            case 503:
              errorMessage =
              'Serviço indisponível. Tente novamente mais tarde.';
              break;
            default:
              errorMessage =
              'Erro inesperado. Código: ${response.statusCode}';
          }
        }

        _showError(errorMessage);
      }
    } catch (e) {
      _showError('Erro ao enviar a gravação: $e');
    } finally {
      setState(() {
        _isProcessing = false;
        _recordingPath = null;
      });
    }
  }

  void _showSuccessPopup() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sucesso"),
        content: const Text("Gravação enviada com sucesso."),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.pushReplacementNamed(context, '/main');
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _cancelRecording() async {
    try {
      final isCurrentlyRecording = await _record.isRecording();
      if (isCurrentlyRecording) {
        await _record.cancel();

        setState(() {
          _isRecording = false;
          _recordingPath = null;
        });
        _stopTimer();

      }
    } catch (e) {
      _showError('Erro ao cancelar a gravação: $e');
    }
  }

  void _resetRecording() {
    setState(() {
      _recordingPath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientContainer(
        child: SafeArea(
          child: Center(
            child: _isProcessing
                ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 20),
                const Text(
                  'Processando...',
                  style: TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),
              ],
            )
                : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (_isRecording) ...[
                    const Icon(
                      Icons.mic,
                      color: Colors.red,
                      size: 50,
                    ),
                    const SizedBox(height: 20),
                  ],
                  if (_isRecording) ...[
                    Text(
                      _duration
                          .toString()
                          .split('.')
                          .first
                          .padLeft(8, "0"),
                      style: const TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                  ],

                  GestureDetector(
                    onTap: _toggleRecording,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: _isRecording ? 80 : 100,
                      height: _isRecording ? 80 : 100,
                      decoration: BoxDecoration(
                        color: _isRecording ? Colors.red : Colors.blue,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _isRecording ? Icons.stop : Icons.mic,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  if (_isRecording) ...[
                    ElevatedButton(
                      onPressed: _cancelRecording,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                            vertical: 12.0, horizontal: 24.0),
                      ),
                      child: const Text('Cancelar Gravação'),
                    ),
                  ],

                  if (!_isRecording && _recordingPath == null) ...[
                    const Text(
                      'Toque no botão para iniciar a gravação',
                      style: TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _record.dispose();
    _timer?.cancel();
    super.dispose();
  }
}
