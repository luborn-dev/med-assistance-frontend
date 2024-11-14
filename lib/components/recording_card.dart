import 'package:flutter/material.dart';
import 'package:med_assistance_frontend/utils/pdf_exporter.dart';

class RecordingCard extends StatelessWidget {
  final dynamic recording;
  final dynamic pacienteInfo;
  final Function onDelete;

  const RecordingCard({
    super.key,
    required this.pacienteInfo,
    required this.recording,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Icon(Icons.description, color: Colors.blue.shade700),
      title: Text(
        recording['procedimento'] ?? 'Procedimento não especificado',
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        '${recording['tipo'] ?? 'Tipo não especificado'} • '
        '${recording['data_gravacao'] ?? ''}',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.delete, color: Colors.red),
        onPressed: () => onDelete(recording['id']),
      ),
      onTap: () => _showRecordingDetails(context),
    );
  }

  void _showRecordingDetails(BuildContext context) {
    recording['procedimento'] ?? 'Procedimento não especificado';
    final dataGravacao = recording['data_gravacao'] ?? 'Data não especificada';
    final nomePaciente =
        pacienteInfo['name'] ?? 'Nome do paciente não especificado';
    final cpfPaciente = pacienteInfo['cpf'] ?? 'CPF não especificado';

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      builder: (context) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height *
                0.7, // Altura máxima de 70% da tela
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Gerar relatório dessa consulta',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      Text(
                        dataGravacao,
                        style:
                            const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Text(
                    'Paciente: $nomePaciente',
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'CPF: $cpfPaciente',
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () => _onExportPDF(),
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text("Exportar para PDF"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 12),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _onExportPDF() {
    PDFExporter.exportToPDF(
      recording['tipo'] ?? '',
      recording['procedimento'] ?? '',
      pacienteInfo['name'] ?? '',
      pacienteInfo['birth_date'] ?? '',
      pacienteInfo['address']["street"] ?? '',
      pacienteInfo['address']["city"] ?? '',
      pacienteInfo['address']["state"] ?? '',
      pacienteInfo['address']["cep"] ?? '',
      pacienteInfo['address']["number"] ?? '',
      pacienteInfo['cpf'] ?? '',
      pacienteInfo['contact'] ?? '',
      recording['medico_info']?['name'] ?? '',
      recording['medico_info']?['email'] ?? '',
      recording['medico_info']?['professional_id'] ?? '',
      recording['transcricao'] ?? '',
      recording['sumarizacao'] ?? '',
    );
  }
}
