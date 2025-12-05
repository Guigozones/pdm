import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String selectedViacao = 'Selecione uma viação';

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
                  _RegisterHeader(),
                  SizedBox(height: 40),
                  _RegisterForm(
                    nameController: nameController,
                    phoneController: phoneController,
                    emailController: emailController,
                    passwordController: passwordController,
                    selectedViacao: selectedViacao,
                    onViacaoChanged: (value) {
                      setState(() => selectedViacao = value);
                    },
                    onConfirm: () {
                      Navigator.pushReplacementNamed(context, '/document-verification');
                    },
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
    nameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

/// Cabeçalho com logo e título
class _RegisterHeader extends StatelessWidget {
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

/// Formulário de cadastro
class _RegisterForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final String selectedViacao;
  final ValueChanged<String> onViacaoChanged;
  final VoidCallback onConfirm;
  final VoidCallback onBack;

  const _RegisterForm({
    required this.nameController,
    required this.phoneController,
    required this.emailController,
    required this.passwordController,
    required this.selectedViacao,
    required this.onViacaoChanged,
    required this.onConfirm,
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
        children: [
          Text(
            'Realizar Cadastro',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          SizedBox(height: 16),
          _ToggleButtons(onBack: onBack),
          SizedBox(height: 20),
          _FormField(label: 'Nome Completo', controller: nameController, hint: 'ex. Seu nome completo'),
          SizedBox(height: 16),
          _FormField(label: 'Telefone', controller: phoneController, hint: '(11) 99999-9999'),
          SizedBox(height: 16),
          _FormField(label: 'E-mail', controller: emailController, hint: 'seu@email.com'),
          SizedBox(height: 16),
          _FormField(label: 'Senha', controller: passwordController, hint: 'Crie uma senha', isPassword: true),
          SizedBox(height: 16),
          _ViacaoDropdown(
            selectedViacao: selectedViacao,
            onChanged: onViacaoChanged,
          ),
          SizedBox(height: 20),
          _PrimaryButton(label: 'Confirmar', onPressed: onConfirm),
        ],
      ),
    );
  }
}

/// Botões de alternância entre Entrar e Cadastrar
class _ToggleButtons extends StatelessWidget {
  final VoidCallback onBack;

  const _ToggleButtons({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.primaryStart, width: 1.5),
            ),
            child: Center(
              child: Text(
                'Entrar',
                style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.primaryStart),
              ),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: onBack,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300, width: 1.5),
              ),
              child: Center(
                child: Text(
                  'Cadastrar',
                  style: TextStyle(fontWeight: FontWeight.w600, color: Colors.grey.shade600),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Campo de formulário reutilizável
class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final bool isPassword;

  const _FormField({
    required this.label,
    required this.controller,
    required this.hint,
    this.isPassword = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          ),
        ),
      ],
    );
  }
}

/// Dropdown de viações
class _ViacaoDropdown extends StatelessWidget {
  final String selectedViacao;
  final ValueChanged<String> onChanged;

  const _ViacaoDropdown({
    required this.selectedViacao,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Viação',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButton<String>(
            value: selectedViacao,
            isExpanded: true,
            underline: SizedBox(),
            items: [
              'Selecione uma viação',
              'Viação A',
              'Viação B',
              'Viação C',
            ].map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(value),
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              onChanged(newValue ?? 'Selecione uma viação');
            },
          ),
        ),
      ],
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: onPressed,
        child: Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
