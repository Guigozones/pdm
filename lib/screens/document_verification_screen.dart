import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DocumentVerificationScreen extends StatefulWidget {
  const DocumentVerificationScreen({Key? key}) : super(key: key);

  @override
  State<DocumentVerificationScreen> createState() => _DocumentVerificationScreenState();
}

class _DocumentVerificationScreenState extends State<DocumentVerificationScreen> {
  final List<Map<String, dynamic>> documents = [
    {'icon': Icons.card_membership, 'title': 'CNH (Carteira Nacional de Habilitação)', 'subtitle': 'Obrigatório', 'uploaded': false},
    {'icon': Icons.directions_car, 'title': 'CRV (Documento do Veículo)', 'subtitle': 'Obrigatório', 'uploaded': false},
    {'icon': Icons.camera_alt, 'title': 'Foto com Documento (Selfie)', 'subtitle': 'Obrigatório', 'uploaded': false},
    {'icon': Icons.home, 'title': 'Comprovante de Residência', 'subtitle': 'Obrigatório', 'uploaded': false},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.mainGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                _VerificationHeader(),
                SizedBox(height: 30),
                _VerificationForm(
                  documents: documents,
                  onUpload: (index) {
                    setState(() => documents[index]['uploaded'] = true);
                  },
                  onSubmit: () => _showSuccessDialog(context),
                  onSkip: () => Navigator.pushReplacementNamed(context, '/'),
                ),
                SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => _SuccessDialog(
        onConfirm: () {
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, '/');
        },
      ),
    );
  }
}

/// Cabeçalho com logo
class _VerificationHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 40),
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.white,
          child: ClipOval(
            child: Image.asset('assets/images/logorotas.jpg', width: 60, height: 60, fit: BoxFit.cover),
          ),
        ),
        SizedBox(height: 12),
        Text('GoRotas', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(height: 4),
        Text('Acesso para Motoristas', style: TextStyle(color: Colors.white70, fontSize: 14)),
      ],
    );
  }
}

/// Formulário de verificação de documentos
class _VerificationForm extends StatelessWidget {
  final List<Map<String, dynamic>> documents;
  final Function(int) onUpload;
  final VoidCallback onSubmit;
  final VoidCallback onSkip;

  const _VerificationForm({
    required this.documents,
    required this.onUpload,
    required this.onSubmit,
    required this.onSkip,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.95),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Verificação de Documentos', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
          SizedBox(height: 12),
          Text(
            'Para começar a oferecer suas viagens, precisamos verificar seus documentos. Este processo levará até 24 horas.',
            style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
          ),
          SizedBox(height: 24),
          ...documents.asMap().entries.map((entry) {
            int index = entry.key;
            Map<String, dynamic> doc = entry.value;
            return Column(
              children: [
                _DocumentCard(doc: doc, onUpload: () => onUpload(index)),
                if (index < documents.length - 1) SizedBox(height: 12),
              ],
            );
          }).toList(),
          SizedBox(height: 20),
          _PrimaryButton(label: 'Enviar Documentos para Análise', onPressed: onSubmit),
          SizedBox(height: 12),
          _SecondaryButton(label: 'Fazer isso Depois', onPressed: onSkip),
        ],
      ),
    );
  }
}

/// Card de documento individual
class _DocumentCard extends StatelessWidget {
  final Map<String, dynamic> doc;
  final VoidCallback onUpload;

  const _DocumentCard({required this.doc, required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: EdgeInsets.all(12),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(color: Colors.blue.shade100, borderRadius: BorderRadius.circular(8)),
                padding: EdgeInsets.all(8),
                child: Icon(doc['icon'], color: AppTheme.primaryStart, size: 24),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(doc['title'], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
                    SizedBox(height: 2),
                    Text(doc['subtitle'], style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _UploadButton(onPressed: onUpload),
        ],
      ),
    );
  }
}

/// Botão de upload
class _UploadButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _UploadButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accent,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload, size: 18),
            SizedBox(width: 6),
            Text('Anexar', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

/// Diálogo de sucesso
class _SuccessDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const _SuccessDialog({required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white.withOpacity(0.95),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(color: Color(0xFF4ADE80), shape: BoxShape.circle),
              padding: EdgeInsets.all(12),
              child: Icon(Icons.check, color: Colors.white, size: 32),
            ),
            SizedBox(height: 16),
            Text('Sucesso!', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
            SizedBox(height: 8),
            Text('Documentos Enviados com Sucesso!', style: TextStyle(fontSize: 13, color: Colors.grey.shade600), textAlign: TextAlign.center),
            SizedBox(height: 20),
            _PrimaryButton(label: 'OK', onPressed: onConfirm),
          ],
        ),
      ),
    );
  }
}

/// Botão primário
class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PrimaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accent,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}

/// Botão secundário
class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _SecondaryButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.textDark,
          side: BorderSide(color: AppTheme.textDark),
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
