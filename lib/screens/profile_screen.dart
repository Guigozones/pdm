import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../widgets/index.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();

  /// Formata a data de criação do usuário
  String _formatMemberSince(DateTime date) {
    final months = [
      'janeiro', 'fevereiro', 'março', 'abril', 'maio', 'junho',
      'julho', 'agosto', 'setembro', 'outubro', 'novembro', 'dezembro'
    ];
    return 'Membro desde ${months[date.month - 1]} de ${date.year}';
  }

  /// Retorna a cor e texto do status
  (String, Color) _getStatusInfo(String status) {
    switch (status.toLowerCase()) {
      case 'ativo':
        return ('Ativo Frequente', Color(0xFF10B981));
      case 'pendente':
        return ('Pendente', Color(0xFFFB923C));
      case 'inativo':
        return ('Inativo', Color(0xFFEF4444));
      default:
        return ('Ativo', Color(0xFF10B981));
    }
  }

  /// Faz logout do usuário
  Future<void> _handleLogout() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao sair: $e')),
      );
    }
  }

  /// Abre o modal de edição de perfil
  void _showEditProfileModal(UserModel? user) {
    final nameController = TextEditingController(text: user?.name ?? '');
    final phoneController = TextEditingController(text: user?.phone ?? '');
    final locationController = TextEditingController();
    bool isLoading = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Editar Perfil',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),

                    // Campo Nome
                    _buildTextField(
                      controller: nameController,
                      label: 'Nome Completo',
                      icon: Icons.person,
                    ),
                    SizedBox(height: 12),

                    // Campo Telefone
                    _buildTextField(
                      controller: phoneController,
                      label: 'Telefone',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      hintText: '(99) 99999-9999',
                    ),
                    SizedBox(height: 12),

                    // Campo Localização
                    _buildTextField(
                      controller: locationController,
                      label: 'Localização',
                      icon: Icons.location_on,
                      hintText: 'Cidade, Estado',
                    ),
                    SizedBox(height: 24),

                    // Botão Salvar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryStart,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: isLoading
                            ? null
                            : () async {
                                setDialogState(() => isLoading = true);
                                
                                try {
                                  final uid = _authService.currentUser?.uid;
                                  if (uid != null) {
                                    // Atualiza os dados no Firestore
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(uid)
                                        .update({
                                      'name': nameController.text.trim(),
                                      'phone': phoneController.text.trim(),
                                    });

                                    if (mounted) {
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Perfil atualizado com sucesso!'),
                                          backgroundColor: Color(0xFF10B981),
                                        ),
                                      );
                                    }
                                  }
                                } catch (e) {
                                  setDialogState(() => isLoading = false);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text('Erro ao atualizar: $e'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
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
                                'Salvar Alterações',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Widget de campo de texto reutilizável
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? hintText,
  }) {
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
        SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hintText,
            prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade600),
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

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.currentUser;
    
    // Se não houver usuário logado, redireciona para login
    if (currentUser == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushReplacementNamed('/');
      });
      return const Center(child: CircularProgressIndicator());
    }

    // StreamBuilder para ouvir mudanças nos dados do usuário em tempo real
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .snapshots(),
      builder: (context, snapshot) {
        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Erro
        if (snapshot.hasError) {
          return Center(child: Text('Erro ao carregar perfil'));
        }

        // Dados do usuário
        UserModel? user;
        if (snapshot.hasData && snapshot.data!.exists) {
          user = UserModel.fromFirestore(snapshot.data!);
        }

        // Fallback para dados do Firebase Auth se Firestore não tiver dados
        final userName = user?.name ?? currentUser.displayName ?? 'Usuário';
        final userEmail = user?.email ?? currentUser.email ?? '';
        final userPhone = user?.phone ?? 'Não informado';
        final memberSince = user?.createdAt ?? DateTime.now();
        final status = user?.status ?? 'ativo';
        final (statusText, statusColor) = _getStatusInfo(status);

        return SingleChildScrollView(
          child: Column(
            children: [
              // Perfil Header
              Container(
                color: AppTheme.primaryStart,
                padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          // Avatar com inicial do nome
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryStart,
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Center(
                              child: Text(
                                userName.isNotEmpty 
                                    ? userName[0].toUpperCase() 
                                    : 'U',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Nome do usuário
                                Text(
                                  userName,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppTheme.textDark,
                                  ),
                                ),
                                SizedBox(height: 4),
                                // Data de cadastro
                                Text(
                                  _formatMemberSince(memberSince),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                SizedBox(height: 8),
                                // Badge de status
                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    statusText,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                      color: statusColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16),

              // Informações Pessoais
              SectionCard(
                title: 'Informações Pessoais',
                child: Column(
                  children: [
                    InfoRow(
                      icon: Icons.email,
                      label: 'Email',
                      value: userEmail,
                    ),
                    SizedBox(height: 12),
                    InfoRow(
                      icon: Icons.phone,
                      label: 'Telefone',
                      value: userPhone,
                    ),
                    SizedBox(height: 12),
                    InfoRow(
                      icon: Icons.location_on,
                      label: 'Localização',
                      value: 'Não informado',
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.edit, size: 18, color: AppTheme.primaryStart),
                    onPressed: () => _showEditProfileModal(user),
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Documentos
              SectionCard(
                title: 'Documentos',
                child: Column(
                  children: [
                    DocumentRow(
                      label: 'CNH',
                      status: 'Pendente',
                      statusColor: Color(0xFFFB923C),
                    ),
                    SizedBox(height: 12),
                    DocumentRow(
                      label: 'RG',
                      status: 'Pendente',
                      statusColor: Color(0xFFFB923C),
                    ),
                    SizedBox(height: 12),
                    DocumentRow(
                      label: 'CRL-V',
                      status: 'Pendente',
                      statusColor: Color(0xFFFB923C),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12),

              // Menu
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    MenuItem(
                      icon: Icons.credit_card,
                      label: 'Planos e Assinatura',
                      onTap: () {},
                    ),
                    Divider(height: 1),
                    MenuItem(
                      icon: Icons.settings,
                      label: 'Configurações',
                      onTap: () {},
                    ),
                    Divider(height: 1),
                    MenuItem(
                      icon: Icons.help,
                      label: 'Ajuda e Suporte',
                      onTap: () {},
                    ),
                    Divider(height: 1),
                    MenuItem(
                      icon: Icons.logout,
                      label: 'Sair da Conta',
                      onTap: _handleLogout,
                      iconColor: Color(0xFFEF4444),
                      textColor: Color(0xFFEF4444),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}
