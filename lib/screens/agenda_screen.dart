import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_theme.dart';
import '../services/auth_service.dart';
import '../models/route_model.dart';
import 'agenda_detail_screen.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({Key? key}) : super(key: key);

  @override
  _AgendaScreenState createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  final AuthService _authService = AuthService();
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now(); // Inicia com a data de hoje
  }

  /// Retorna a abreviação do dia da semana para uma data
  String _getWeekDay(DateTime date) {
    final weekDays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab'];
    return weekDays[date.weekday % 7];
  }

  void _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024, 1, 1),
      lastDate: DateTime(2030, 12, 31),
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primaryStart,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.textDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() => selectedDate = pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.currentUser;
    final selectedWeekDay = _getWeekDay(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text('Agenda'),
        backgroundColor: AppTheme.primaryStart,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: _DatePickerWidget(
              selectedDate: selectedDate,
              weekDay: selectedWeekDay,
              onDateTap: _selectDate,
            ),
          ),
          Expanded(
            child: currentUser == null
                ? Center(child: Text('Usuário não logado'))
                : StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('routes')
                        .where('ownerId', isEqualTo: currentUser.uid)
                        .where('status', isEqualTo: 'Ativa')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(child: CircularProgressIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(child: Text('Erro ao carregar viagens'));
                      }

                      final allRoutes =
                          snapshot.data?.docs
                              .map((doc) => RouteModel.fromFirestore(doc))
                              .toList() ??
                          [];

                      // Filtra rotas pelo dia da semana selecionado
                      final filteredRoutes = allRoutes
                          .where(
                            (route) => route.weekDays.contains(selectedWeekDay),
                          )
                          .toList();

                      if (filteredRoutes.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                              SizedBox(height: 16),
                              Text(
                                'Nenhuma viagem para $selectedWeekDay',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[600],
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Não há rotas cadastradas para este dia da semana',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: filteredRoutes.length,
                        itemBuilder: (context, index) {
                          final route = filteredRoutes[index];

                          // Define status baseado nos lugares disponíveis
                          String status;
                          Color statusColor;
                          if (route.availableSeats == 0) {
                            status = 'Lotada';
                            statusColor = Color(0xFFEF4444); // Vermelho
                          } else {
                            status = '${route.availableSeats} vagas';
                            statusColor = Color(0xFF10B981); // Verde
                          }

                          return Padding(
                            padding: EdgeInsets.only(bottom: 14),
                            child: _AgendaCard(
                              routeId: route.id ?? '',
                              origin: route.origin,
                              destination: route.destination,
                              status: status,
                              statusColor: statusColor,
                              value: route.formattedPrice,
                              capacity: route.capacity,
                              available: route.availableSeats,
                              time: route.duration.isNotEmpty
                                  ? route.duration
                                  : '-',
                              timeSlot: route.timeSlots.isNotEmpty
                                  ? route.timeSlots.first
                                  : '8:00',
                              selectedDate: selectedDate,
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Widget de seleção de data
class _DatePickerWidget extends StatelessWidget {
  final DateTime selectedDate;
  final String weekDay;
  final VoidCallback onDateTap;

  const _DatePickerWidget({
    required this.selectedDate,
    required this.weekDay,
    required this.onDateTap,
  });

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: onDateTap,
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.grey.shade600, size: 18),
            SizedBox(width: 12),
            Text(
              'Selecionar Data',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.accent,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                weekDay,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 8),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryStart,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                _formatDate(selectedDate),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(width: 8),
            Icon(Icons.calendar_today, color: AppTheme.primaryStart, size: 18),
          ],
        ),
      ),
    );
  }
}

/// Card de agenda
class _AgendaCard extends StatelessWidget {
  final String routeId;
  final String origin;
  final String destination;
  final String status;
  final Color statusColor;
  final String value;
  final int capacity;
  final int available;
  final String time;
  final String timeSlot;
  final DateTime selectedDate;

  const _AgendaCard({
    required this.routeId,
    required this.origin,
    required this.destination,
    required this.status,
    required this.statusColor,
    required this.value,
    required this.capacity,
    required this.available,
    required this.time,
    required this.timeSlot,
    required this.selectedDate,
  });

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.location_on, size: 20, color: AppTheme.primaryStart),
              SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$origin → $destination',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${_formatDate(selectedDate)} às $timeSlot',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
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
          SizedBox(height: 12),
          Divider(color: Colors.grey.shade200, height: 1),
          SizedBox(height: 12),
          // Details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.attach_money,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  SizedBox(width: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.event_seat, size: 16, color: Colors.grey.shade600),
                  SizedBox(width: 4),
                  Text(
                    '$available/$capacity lugares',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  SizedBox(width: 4),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 12),
          // Button
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryStart,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AgendaDetailScreen(
                      routeId: routeId,
                      origin: origin,
                      destination: destination,
                      value: value,
                      capacity: capacity,
                      available: available,
                      time: time,
                      timeSlot: timeSlot,
                      selectedDate: selectedDate,
                    ),
                  ),
                );
              },
              child: Text(
                'Ver mais',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
