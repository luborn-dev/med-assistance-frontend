import 'package:flutter/material.dart';

class RecordingCard extends StatelessWidget {
  final dynamic recording;
  final Function onDelete;
  final Function onExportPDF;

  const RecordingCard({
    super.key,
    required this.recording,
    required this.onDelete,
    required this.onExportPDF,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ExpansionTile(
          leading: const Icon(Icons.info_outline, color: Colors.blue),
          title: Text(
            recording['exact_procedure_name'] ?? '',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(recording['patient_name'] ?? ''),
              Text(recording['procedure_type'] ?? ''),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => onDelete(recording['id']),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Transcrição:',
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 5),
                  Text(
                    recording['transcription']?.length > 200
                        ? '${recording['transcription'].substring(0, 200)}...'
                        : recording['transcription'] ?? '',
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () => onExportPDF(
                      recording['exact_procedure_name'] ?? '',
                      recording['transcription'] ?? '',
                    ),
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text("Exportar para PDF"),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
