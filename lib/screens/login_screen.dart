import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final confirmPasswordController = TextEditingController();

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
                  _LoginHeader(),
                  SizedBox(height: 40),
                  _AuthContainer(
                    isLogin: isLogin,
                    onToggle: (value) => setState(() => isLogin = value),
                    child: isLogin
                        ? _LoginForm(
                            emailController: emailController,
                            passwordController: passwordController,
                            onLogin: () => Navigator.pushReplacementNamed(context, '/home'),
                          )
                        : _RegisterForm(
                            nameController: nameController,
                            emailController: emailController,
                            passwordController: passwordController,
                            confirmPasswordController: confirmPasswordController,
                            onRegister: () => Navigator.pushReplacementNamed(context, '/document-verification'),
                          ),
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
    passwordController.dispose();
    nameController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}

/// Cabeçalho com logo e título
class _LoginHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(height: 40),
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.white,
          child: ClipOval(
            child: Image.asset(
              'assets/images/logorotas.jpg',
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
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

/// Container com abas de login/cadastro
class _AuthContainer extends StatelessWidget {
  final bool isLogin;
  final Function(bool) onToggle;
  final Widget child;

  const _AuthContainer({
    required this.isLogin,
    required this.onToggle,
    required this.child,
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
            'Acesse sua conta',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          SizedBox(height: 16),
          _AuthToggleButton(
            isLogin: isLogin,
            onToggle: onToggle,
          ),
          SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

/// Botões de alternância entre Login e Cadastro
class _AuthToggleButton extends StatelessWidget {
  final bool isLogin;
  final Function(bool) onToggle;

  const _AuthToggleButton({
    required this.isLogin,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ToggleTab(
          label: 'Entrar',
          isActive: isLogin,
          onTap: () => onToggle(true),
        ),
        SizedBox(width: 12),
        _ToggleTab(
          label: 'Cadastro',
          isActive: !isLogin,
          onTap: () => onToggle(false),
        ),
      ],
    );
  }
}

/// Abas individuais do toggle
class _ToggleTab extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const _ToggleTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isActive ? AppTheme.primaryStart : Colors.grey.shade300,
              width: 1.5,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isActive ? AppTheme.primaryStart : Colors.grey.shade600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Formulário de Login
class _LoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLogin;

  const _LoginForm({
    required this.emailController,
    required this.passwordController,
    required this.onLogin,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FormField(
          label: 'E-mail',
          controller: emailController,
          hintText: 'seu@email.com',
        ),
        SizedBox(height: 16),
        _FormField(
          label: 'Senha',
          controller: passwordController,
          hintText: 'Sua senha',
          obscureText: true,
        ),
        SizedBox(height: 20),
        _SubmitButton(
          label: 'Entrar',
          onPressed: onLogin,
        ),
        SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () => Navigator.pushNamed(context, '/recover'),
            child: Text(
              'Esqueceu a senha?',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ),
      ],
    );
  }
}

/// Formulário de Cadastro
class _RegisterForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onRegister;

  const _RegisterForm({
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _FormField(
          label: 'Nome Completo',
          controller: nameController,
          hintText: 'Seu nome completo',
        ),
        SizedBox(height: 16),
        _FormField(
          label: 'E-mail',
          controller: emailController,
          hintText: 'seu@email.com',
        ),
        SizedBox(height: 16),
        _FormField(
          label: 'Senha',
          controller: passwordController,
          hintText: 'Crie uma senha',
          obscureText: true,
        ),
        SizedBox(height: 16),
        _FormField(
          label: 'Confirmar Senha',
          controller: confirmPasswordController,
          hintText: 'Repita a senha',
          obscureText: true,
        ),
        SizedBox(height: 20),
        _SubmitButton(
          label: 'Cadastrar',
          onPressed: onRegister,
        ),
      ],
    );
  }
}

/// Campo de formulário reutilizável
class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  const _FormField({
    required this.label,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textDark,
          ),
        ),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: obscureText,
          decoration: InputDecoration(
            hintText: hintText,
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

/// Botão de envio
class _SubmitButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _SubmitButton({
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
