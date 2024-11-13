import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:med_assistance_frontend/services/recording_service.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:med_assistance_frontend/components/background_container.dart';

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
  bool _isProcessing = false;
  String? _recordingPath;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _initializeRecording();
  }

  Future<void> _initializeRecording() async {
    await _requestPermission();
    await _prepareRecordingPath();
  }

  Future<void> _requestPermission() async {
    PermissionStatus status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permissão Necessária"),
        content: const Text(
            "Este aplicativo precisa de acesso ao microfone para gravar áudio."),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text("Abrir Configurações"),
          ),
        ],
      ),
    );
  }

  Future<void> _prepareRecordingPath() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final String fileName =
          'recording_${DateTime.now().millisecondsSinceEpoch}.m4a';
      _recordingPath = '${directory.path}/$fileName';
    } catch (e) {
      _showError('Erro ao preparar o caminho de gravação: $e');
    }
  }

  Future<void> _toggleRecording() async {
    try {
      if (!_isRecording) {
        if (await _record.hasPermission()) {
          if (_recordingPath == null) {
            await _prepareRecordingPath();
          }
          await _record.start(
            const RecordConfig(encoder: AudioEncoder.aacLc),
            path: _recordingPath!,
          );

          setState(() {
            _isRecording = true;
          });
        } else {
          _showError('Permissão para gravação negada.');
        }
      } else {
        await _record.stop();

        setState(() {
          _isRecording = false;
          _isProcessing = true;
        });

        if (_recordingPath != null &&
            await File(_recordingPath!).length() > 0) {
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
        content: const Text(
            "Deseja enviar a gravação? Você não poderá gravar novamente."),
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
    setState(() {
      _isProcessing = true;
    });

    try {
      final recordingService = RecordingService();
      final recordingFile = File(_recordingPath!);
      await recordingService.sendRecording(
        procedureData: widget.procedureData,
        recordingFile: recordingFile,
        context: context,
      );
    } catch (e) {
      _showError('Erro ao enviar a gravação: $e');
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _cancelRecording() async {
    try {
      bool isRecording = await _record.isRecording();
      if (isRecording) {
        await _record.stop();
        if (_recordingPath != null) {
          await File(_recordingPath!).delete();
        }

        setState(() {
          _isRecording = false;
          _recordingPath = null;
        });
      }
    } catch (e) {
      _showError('Erro ao cancelar a gravação: $e');
    }
  }

  void _resetRecording() {
    if (_recordingPath != null) {
      File(_recordingPath!).deleteSync();
    }
    setState(() {
      _recordingPath = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Novo Procedimento"),
        centerTitle: true,
      ),
      body: BackgroundContainer(
        child: SafeArea(
          child: Center(
            child: _isProcessing
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 20),
                      Text(
                        'Enviando gravação...',
                        style: TextStyle(fontSize: 18),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  )
                : Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_isRecording) ...[
                          // Exibir botão de parar gravação
                          ElevatedButton.icon(
                            onPressed: _toggleRecording,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 24.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            icon: const Icon(Icons.stop),
                            label: const Text('Parar Gravação'),
                          ),
                          const SizedBox(height: 20),
                          // Botão para cancelar a gravação
                          ElevatedButton.icon(
                            onPressed: _cancelRecording,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 24.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            icon: const Icon(Icons.cancel),
                            label: const Text('Cancelar Gravação'),
                          ),
                        ],
                        if (!_isRecording) ...[
                          // Exibir botão para iniciar a gravação
                          ElevatedButton.icon(
                            onPressed: _toggleRecording,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 24.0),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                            ),
                            icon: const Icon(Icons.mic),
                            label: const Text('Iniciar Gravação'),
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
