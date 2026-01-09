import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../theme/app_theme.dart';
import '../services/chat_service.dart';
import '../services/booking_service.dart';
import '../models/booking_model.dart';
import 'chat_screen.dart';

class AgendaDetailScreen extends StatefulWidget {
  final String routeId;
  final String origin;
  final String destination;
  final String value;
  final int capacity;
  final int available;
  final String time;
  final String timeSlot;
  final DateTime selectedDate;

  const AgendaDetailScreen({
    Key? key,
    required this.routeId,
    required this.origin,
    required this.destination,
    required this.value,
    required this.capacity,
    required this.available,
    required this.time,
    required this.timeSlot,
    required this.selectedDate,
  }) : super(key: key);

  @override
  _AgendaDetailScreenState createState() => _AgendaDetailScreenState();
}

class _AgendaDetailScreenState extends State<AgendaDetailScreen> {
  final BookingService _bookingService = BookingService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agenda'),
        backgroundColor: AppTheme.primaryStart,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Center(child: Icon(Icons.notifications, size: 20)),
          ),
        ],
      ),
      body: StreamBuilder<List<BookingModel>>(
        // Temporariamente usando sem filtro de data para debug
        stream: _bookingService.watchAllBookingsByRoute(widget.routeId),
        builder: (context, snapshot) {
          // Debug
          print('🎫 RouteId: ${widget.routeId}');
          print('📅 Data: ${widget.selectedDate}');
          print('📊 Snapshot: ${snapshot.connectionState}');
          if (snapshot.hasError) {
            print('❌ Erro: ${snapshot.error}');
          }

          final bookings = snapshot.data ?? [];
          final activeBookings = bookings
              .where((b) => b.status != 'cancelado')
              .toList();

          int bookedSeats = activeBookings.length;
          double occupancyRate = widget.capacity > 0
              ? (bookedSeats / widget.capacity) * 100
              : 0;
          int paidPassengers = activeBookings.where((b) => b.isPaid).length;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Header Card
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '${widget.origin} → ${widget.destination}',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          '${_formatDate(widget.selectedDate)} às ${widget.timeSlot}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Statistics Cards
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _statCard(
                              title: 'Assentos Preenchidos',
                              value: '$bookedSeats/${widget.capacity}',
                              icon: Icons.event_seat,
                              iconColor: Color(0xFF3B82F6),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _statCard(
                              title: 'Passageiros Pagos',
                              value: '$paidPassengers/${activeBookings.length}',
                              icon: Icons.attach_money,
                              iconColor: Color(0xFF10B981),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _statCard(
                              title: 'Taxa de Ocupação',
                              value: '${occupancyRate.toStringAsFixed(0)}%',
                              icon: Icons.trending_up,
                              iconColor: Color(0xFF06B6D4),
                            ),
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: _statCard(
                              title: 'Reservas Confirmadas',
                              value: '$paidPassengers/${activeBookings.length}',
                              icon: Icons.check_circle,
                              iconColor: Color(0xFFFB923C),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 16),

                // Passengers List
                Container(
                  color: Colors.white,
                  padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Icon(
                              Icons.people,
                              size: 18,
                              color: AppTheme.textDark,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Lista de Passageiros (${activeBookings.length})',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (snapshot.connectionState == ConnectionState.waiting)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else if (activeBookings.isEmpty)
                        Center(
                          child: Padding(
                            padding: EdgeInsets.all(32),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.person_off,
                                  size: 48,
                                  color: Colors.grey[400],
                                ),
                                SizedBox(height: 12),
                                Text(
                                  'Nenhum passageiro reservado',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Column(
                          children: List.generate(
                            activeBookings.length,
                            (index) => Padding(
                              padding: EdgeInsets.only(
                                bottom: index < activeBookings.length - 1
                                    ? 12
                                    : 0,
                              ),
                              child: _passengerCard(activeBookings[index]),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
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
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _passengerCard(BookingModel booking) {
    bool isPaid = booking.isPaid;

    return Container(
      padding: EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPaid ? AppTheme.primaryStart : Colors.grey.shade200,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.person, size: 18, color: AppTheme.textDark),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.passengerName,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Text(
                        booking.seatText,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: isPaid ? AppTheme.primaryStart : Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  booking.statusText,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryStart,
                    side: BorderSide(color: AppTheme.primaryStart),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: () async {
                    // Buscar ou criar chat com o passageiro
                    final chatService = ChatService();
                    final chatId = await chatService.getOrCreateChat(
                      clientId: booking.passengerId,
                      clientName: booking.passengerName,
                      driverId: _currentUser?.uid ?? '',
                      driverName: _currentUser?.displayName ?? 'Motorista',
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          chatId: chatId,
                          otherUserName: booking.passengerName,
                          otherUserId: booking.passengerId,
                          senderType: 'driver',
                        ),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.mail, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'Mensagem',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryStart,
                    side: BorderSide(color: AppTheme.primaryStart),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 8),
                  ),
                  onPressed: () {
                    _showPassengerProfile(booking);
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person, size: 14),
                      SizedBox(width: 6),
                      Text(
                        'Ver Perfil',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPassengerProfile(BookingModel booking) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Perfil do Passageiro',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.person, size: 20, color: AppTheme.textDark),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        booking.passengerName,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Text(
                        booking.seatText,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),
              _profileInfoRow(
                label: 'Telefone',
                value: booking.passengerPhone.isNotEmpty
                    ? booking.passengerPhone
                    : 'Não informado',
                icon: Icons.phone,
              ),
              SizedBox(height: 12),
              _profileInfoRow(
                label: 'Email',
                value: booking.passengerEmail.isNotEmpty
                    ? booking.passengerEmail
                    : 'Não informado',
                icon: Icons.email,
              ),
              SizedBox(height: 12),
              _profileInfoRow(
                label: 'Local de Embarque',
                value: booking.boardingAddress.isNotEmpty
                    ? booking.boardingAddress
                    : 'Não informado',
                icon: Icons.location_on,
              ),
              SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 40,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryStart,
                    side: BorderSide(color: AppTheme.primaryStart),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    // Buscar ou criar chat com o passageiro
                    final chatService = ChatService();
                    final chatId = await chatService.getOrCreateChat(
                      clientId: booking.passengerId,
                      clientName: booking.passengerName,
                      driverId: _currentUser?.uid ?? '',
                      driverName: _currentUser?.displayName ?? 'Motorista',
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          chatId: chatId,
                          otherUserName: booking.passengerName,
                          otherUserId: booking.passengerId,
                          senderType: 'driver',
                        ),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.mail, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Mensagem',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileInfoRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey.shade600),
            SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 6),
        Padding(
          padding: EdgeInsets.only(left: 24),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
        ),
      ],
    );
  }
}
