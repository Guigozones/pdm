import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true;
  bool isLoading = false;
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  
  final AuthService _authService = AuthService();

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
                            isLoading: isLoading,
                            onLogin: _handleLogin,
                          )
                        : _RegisterForm(
                            nameController: nameController,
                            emailController: emailController,
                            passwordController: passwordController,
                            confirmPasswordController: confirmPasswordController,
                            isLoading: isLoading,
                            onRegister: _handleRegister,
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

  /// Processa o login
  Future<void> _handleLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    // Validações básicas
    if (email.isEmpty || password.isEmpty) {
      _showError('Preencha todos os campos');
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (user != null && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        _showError('Erro ao fazer login. Verifique suas credenciais.');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  /// Processa o cadastro
  Future<void> _handleRegister() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    // Validações
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showError('Preencha todos os campos');
      return;
    }

    if (password != confirmPassword) {
      _showError('As senhas não coincidem');
      return;
    }

    if (password.length < 6) {
      _showError('A senha deve ter pelo menos 6 caracteres');
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = await _authService.registerWithEmailAndPassword(
        name: name,
        email: email,
        password: password,
      );

      if (user != null && mounted) {
        Navigator.pushReplacementNamed(context, '/document-verification');
      } else {
        _showError('Erro ao criar conta. Tente novamente.');
      }
    } catch (e) {
      _showError(e.toString());
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  /// Exibe mensagem de erro
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
  final bool isLoading;
  final VoidCallback onLogin;

  const _LoginForm({
    required this.emailController,
    required this.passwordController,
    required this.isLoading,
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
          keyboardType: TextInputType.emailAddress,
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
          isLoading: isLoading,
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
  final bool isLoading;
  final VoidCallback onRegister;

  const _RegisterForm({
    required this.nameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.isLoading,
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
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 16),
        _FormField(
          label: 'Senha',
          controller: passwordController,
          hintText: 'Crie uma senha (mínimo 6 caracteres)',
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
          isLoading: isLoading,
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
  final TextInputType keyboardType;

  const _FormField({
    required this.label,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
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
          keyboardType: keyboardType,
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

/// Botão de envio com loading
class _SubmitButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onPressed;

  const _SubmitButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
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
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                label,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
