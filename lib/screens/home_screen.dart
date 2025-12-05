import 'package:flutter/material.dart';
import '../widgets/index.dart';
import '../theme/app_theme.dart';
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

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                  value: 'R\$ 2.850,00',
                  diff: '+12%',
                  icon: Icons.attach_money,
                  iconColor: Color(0xFF10B981),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: StatBox(
                  title: 'Passageiros',
                  value: '41',
                  diff: '+8',
                  icon: Icons.people,
                  iconColor: Color(0xFF3B82F6),
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: StatBox(
                  title: 'Viagens Hoje',
                  value: '3',
                  diff: '+2',
                  icon: Icons.directions_car,
                  iconColor: Color(0xFF06B6D4),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: StatBox(
                  title: 'Taxa de Ocupação',
                  value: '85%',
                  diff: '+5%',
                  icon: Icons.trending_up,
                  iconColor: Color(0xFFF59E0B),
                ),
              ),
            ],
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

          // Seção de viagens
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
                          'Viagens de Hoje',
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
                TripTile(
                  route: 'Caxias → Teresina',
                  time: '04/10/2025 às 8:00',
                  status: 'Lotada',
                  statusColor: Color(0xFF10B981),
                ),
                SizedBox(height: 8),
                TripTile(
                  route: 'Caxias → Aldeias Altas',
                  time: '04/10/2025 às 11:00',
                  status: 'Disponível',
                  statusColor: Color(0xFF3B82F6),
                ),
                SizedBox(height: 8),
                TripTile(
                  route: 'Caxias → São J. do Sóter',
                  time: '04/10/2025 às 14:00',
                  status: 'Cancelada',
                  statusColor: Color(0xFFFB923C),
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