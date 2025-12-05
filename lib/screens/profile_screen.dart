import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/index.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Meu Perfil'),
        backgroundColor: AppTheme.primaryStart,
        elevation: 0,
        centerTitle: false,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(
              child: Icon(Icons.notifications, size: 20),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
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
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryStart,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.person,
                              size: 32,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'João Gomes',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Membro desde janeiro de 2025',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              SizedBox(height: 8),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xFF10B981).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Ativo Frequente',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF10B981),
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
                    value: 'joao.gomes@email.com',
                  ),
                  SizedBox(height: 12),
                  InfoRow(
                    icon: Icons.phone,
                    label: 'Telefone',
                    value: '[55] 99999-9999',
                  ),
                  SizedBox(height: 12),
                  InfoRow(
                    icon: Icons.location_on,
                    label: 'Localização',
                    value: 'Caxias, MA',
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.edit, size: 18, color: AppTheme.primaryStart),
                  onPressed: () {},
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
                    status: 'Válido',
                    statusColor: Color(0xFF10B981),
                  ),
                  SizedBox(height: 12),
                  DocumentRow(
                    label: 'RG',
                    status: 'Válido',
                    statusColor: Color(0xFF10B981),
                  ),
                  SizedBox(height: 12),
                  DocumentRow(
                    label: 'CRL-V',
                    status: 'Vence em breve',
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
                    onTap: () {
                      Navigator.of(context).pushReplacementNamed('/');
                    },
                    iconColor: Color(0xFFEF4444),
                    textColor: Color(0xFFEF4444),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
