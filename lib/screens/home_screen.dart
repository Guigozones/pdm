import 'package:flutter/material.dart';
import '../widgets/app_scaffold.dart';
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

  Widget _statBox({
    required String title,
    required String value,
    required String diff,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
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
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: EdgeInsets.all(6),
                child: Icon(icon, size: 16, color: iconColor),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
          SizedBox(height: 4),
          Text(
            diff,
            style: TextStyle(
              fontSize: 11,
              color: Colors.green,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tripTile({
    required String route,
    required String time,
    required String status,
    required Color statusColor,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  route,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

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
                child: _statBox(
                  title: 'Receita Hoje',
                  value: 'R\$ 2.850,00',
                  diff: '+12%',
                  icon: Icons.attach_money,
                  iconColor: Color(0xFF10B981),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _statBox(
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
                child: _statBox(
                  title: 'Viagens Hoje',
                  value: '3',
                  diff: '+2',
                  icon: Icons.directions_car,
                  iconColor: Color(0xFF06B6D4),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _statBox(
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
                _tripTile(
                  route: 'Caxias → Teresina',
                  time: '04/10/2025 às 8:00',
                  status: 'Lotada',
                  statusColor: Color(0xFF10B981),
                ),
                SizedBox(height: 8),
                _tripTile(
                  route: 'Caxias → Aldeias Altas',
                  time: '04/10/2025 às 11:00',
                  status: 'Disponível',
                  statusColor: Color(0xFF3B82F6),
                ),
                SizedBox(height: 8),
                _tripTile(
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