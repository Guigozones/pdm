import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RecoverScreen extends StatefulWidget {
  const RecoverScreen({Key? key}) : super(key: key);

  @override
  State<RecoverScreen> createState() => _RecoverScreenState();
}

class _RecoverScreenState extends State<RecoverScreen> {
  final emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.mainGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _RecoverHeader(),
                  SizedBox(height: 40),
                  _RecoverForm(
                    emailController: emailController,
                    onSend: () => _showSuccessDialog(context),
                    onBack: () => Navigator.pop(context),
                  ),
                  SizedBox(height: 40),
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
    emailController.dispose();
    super.dispose();
  }

  void _showSuccessDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _SuccessDialog(
          onConfirm: () {
            Navigator.pop(context);
            Navigator.pop(context);
          },
        );
      },
    );
  }
}

/// Cabeçalho com logo e título
class _RecoverHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 40),
        CircleAvatar(
          radius: 36,
          backgroundColor: Colors.white,
          child: Icon(
            Icons.directions_car,
            size: 36,
            color: AppTheme.primaryStart,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'GoRotas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Acesso para Motoristas',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}

/// Formulário de recuperação
class _RecoverForm extends StatelessWidget {
  final TextEditingController emailController;
  final VoidCallback onSend;
  final VoidCallback onBack;

  const _RecoverForm({
    required this.emailController,
    required this.onSend,
    required this.onBack,
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
          Text(
            'Recuperar Senha',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Digite o e-mail cadastrado',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          SizedBox(height: 8),
          TextField(
            controller: emailController,
            decoration: InputDecoration(
              hintText: 'seu@email.com',
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            ),
          ),
          SizedBox(height: 20),
          _PrimaryButton(
            label: 'Enviar',
            onPressed: onSend,
          ),
          SizedBox(height: 12),
          _SecondaryButton(
            label: 'Voltar',
            onPressed: onBack,
          ),
        ],
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
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Color(0xFF4ADE80),
                shape: BoxShape.circle,
              ),
              padding: EdgeInsets.all(12),
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: 32,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Sucesso!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Solicitação de recuperação enviada.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            _PrimaryButton(
              label: 'OK',
              onPressed: onConfirm,
            ),
          ],
        ),
      ),
    );
  }
}

/// Botão primário reutilizável
class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.accent,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

/// Botão secundário reutilizável
class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _SecondaryButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppTheme.textDark,
          side: BorderSide(color: AppTheme.textDark),
          padding: EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
