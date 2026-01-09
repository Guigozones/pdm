import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/index.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../models/route_model.dart';
import 'profile_screen.dart';
import 'vehicles_screen.dart';
import 'routes_screen.dart';
import 'agenda_screen.dart';
import 'conversas_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int tabIndex = 0;
  final tabs = <Widget>[
    const _OverviewTab(),
    const VehiclesScreen(),
    const RoutesScreen(),
    const ConversasScreen(),
    const ProfileScreen(),
  ];

  void _onBottomTap(int idx) {
    setState(() => tabIndex = idx);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      currentIndex: tabIndex,
      onTab: _onBottomTap,
      child: tabs[tabIndex],
    );
  }
}

class _OverviewTab extends StatefulWidget {
  const _OverviewTab({Key? key}) : super(key: key);

  @override
  State<_OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<_OverviewTab> {
  final AuthService _authService = AuthService();

  /// Retorna a abreviação do dia da semana atual
  String _getTodayWeekDay() {
    final now = DateTime.now();
    final weekDays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab'];
    return weekDays[now.weekday % 7];
  }

  /// Formata a data de hoje
  String _formatToday() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.currentUser;
    final todayWeekDay = _getTodayWeekDay();

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Cards de estatísticas em grid 2x2
          Row(
            children: [
              Expanded(
                child: StatBox(
                  title: 'Receita Hoje',
                  value: 'R\$ 0,00',
                  diff: '-',
                  icon: Icons.attach_money,
                  iconColor: Color(0xFF10B981),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: StatBox(
                  title: 'Passageiros',
                  value: '0',
                  diff: '-',
                  icon: Icons.people,
                  iconColor: Color(0xFF3B82F6),
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          // Stream para contar viagens de hoje
          StreamBuilder<QuerySnapshot>(
            stream: currentUser != null
                ? FirebaseFirestore.instance
                    .collection('routes')
                    .where('ownerId', isEqualTo: currentUser.uid)
                    .where('status', isEqualTo: 'Ativa')
                    .snapshots()
                : null,
            builder: (context, snapshot) {
              int viagensHoje = 0;
              if (snapshot.hasData) {
                final routes = snapshot.data!.docs
                    .map((doc) => RouteModel.fromFirestore(doc))
                    .where((route) => route.weekDays.contains(todayWeekDay))
                    .toList();
                viagensHoje = routes.length;
              }

              return Row(
                children: [
                  Expanded(
                    child: StatBox(
                      title: 'Viagens Hoje',
                      value: viagensHoje.toString(),
                      diff: todayWeekDay,
                      icon: Icons.directions_car,
                      iconColor: Color(0xFF06B6D4),
                    ),
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: StatBox(
                      title: 'Taxa de Ocupação',
                      value: '-',
                      diff: '-',
                      icon: Icons.trending_up,
                      iconColor: Color(0xFFF59E0B),
                    ),
                  ),
                ],
              );
            },
          ),

          SizedBox(height: 16),

          // Botão de relatórios
          SizedBox(
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pushNamed('/relatorios');
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.file_present, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Ver Relatórios Completos',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          SizedBox(height: 16),

          // Seção de viagens de hoje (baseado nas rotas com dia da semana atual)
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: AppTheme.textDark,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Viagens de Hoje (${_formatToday()} - $todayWeekDay)',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const AgendaScreen(),
                          ),
                        );
                      },
                      child: Text(
                        'Ver agenda →',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.primaryStart,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                
                // Stream de rotas do motorista para o dia de hoje
                StreamBuilder<QuerySnapshot>(
                  stream: currentUser != null
                      ? FirebaseFirestore.instance
                          .collection('routes')
                          .where('ownerId', isEqualTo: currentUser.uid)
                          .where('status', isEqualTo: 'Ativa')
                          .snapshots()
                      : null,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Erro ao carregar viagens'),
                      );
                    }

                    final allRoutes = snapshot.data?.docs
                            .map((doc) => RouteModel.fromFirestore(doc))
                            .toList() ??
                        [];

                    // Filtra apenas as rotas que têm o dia da semana de hoje
                    final todaysRoutes = allRoutes
                        .where((route) => route.weekDays.contains(todayWeekDay))
                        .toList();

                    if (todaysRoutes.isEmpty) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: Column(
                          children: [
                            Icon(
                              Icons.event_busy,
                              size: 48,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 12),
                            Text(
                              'Nenhuma viagem para hoje',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              'Cadastre rotas com o dia "$todayWeekDay"',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    // Exibe as viagens de hoje
                    return Column(
                      children: todaysRoutes.asMap().entries.map((entry) {
                        final index = entry.key;
                        final route = entry.value;
                        
                        // Define status baseado nos assentos disponíveis
                        String status;
                        Color statusColor;
                        if (route.availableSeats == 0) {
                          status = 'Lotada';
                          statusColor = Color(0xFF10B981);
                        } else if (route.availableSeats < route.capacity ~/ 2) {
                          status = 'Quase Lotada';
                          statusColor = Color(0xFFFB923C);
                        } else {
                          status = '${route.availableSeats} lugares';
                          statusColor = Color(0xFF3B82F6);
                        }

                        // Horário da viagem
                        String timeText = route.timeSlots.isNotEmpty
                            ? '${_formatToday()} às ${route.timeSlots.first}'
                            : '${_formatToday()}';

                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: index < todaysRoutes.length - 1 ? 8 : 0,
                          ),
                          child: TripTile(
                            route: route.title,
                            time: timeText,
                            status: status,
                            statusColor: statusColor,
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ],
            ),
          ),

          SizedBox(height: 24),
        ],
      ),
    );
  }
}