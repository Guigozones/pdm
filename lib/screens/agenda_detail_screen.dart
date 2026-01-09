import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/chat_service.dart';
import 'chat_screen.dart';

class AgendaDetailScreen extends StatefulWidget {
  final String origin;
  final String destination;
  final String value;
  final int capacity;
  final int available;
  final String time;

  const AgendaDetailScreen({
    Key? key,
    required this.origin,
    required this.destination,
    required this.value,
    required this.capacity,
    required this.available,
    required this.time,
  }) : super(key: key);

  @override
  _AgendaDetailScreenState createState() => _AgendaDetailScreenState();
}

class _AgendaDetailScreenState extends State<AgendaDetailScreen> {
  final List<Map<String, dynamic>> passengers = [
    {
      'name': 'Marília Mendoça',
      'seat': 'Assento 1',
      'paid': true,
      'phone': '(99) 99999-9999',
      'email': 'marilia@email.com',
      'address': 'Rua 01, nº 100, Centro - Caxias-MA',
    },
    {
      'name': 'Henrique Juliano',
      'seat': 'Assento 1',
      'paid': true,
      'phone': '(99) 98888-8888',
      'email': 'henrique@email.com',
      'address': 'Rua 02, nº 200, Centro - Caxias-MA',
    },
    {
      'name': 'João Gomes',
      'seat': 'Assento 1',
      'paid': true,
      'phone': '(99) 97777-7777',
      'email': 'joao@email.com',
      'address': 'Rua 03, nº 300, Centro - Caxias-MA',
    },
    {
      'name': 'Jorge Mateus',
      'seat': 'Assento 1',
      'paid': false,
      'phone': '(99) 96666-6666',
      'email': 'jorge@email.com',
      'address': 'Rua 04, nº 400, Centro - Caxias-MA',
    },
    {
      'name': 'Victor Leo',
      'seat': 'Assento 1',
      'paid': false,
      'phone': '(99) 95555-5555',
      'email': 'victor@email.com',
      'address': 'Rua 05, nº 500, Centro - Caxias-MA',
    },
  ];

  @override
  Widget build(BuildContext context) {
    int bookedSeats = widget.capacity - widget.available;
    double occupancyRate = widget.capacity > 0
        ? (bookedSeats / widget.capacity) * 100
        : 0;
    int confirmedReservations = passengers.where((p) => p['paid']).length;

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
      body: SingleChildScrollView(
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
                  border: Border.all(color: Colors.grey.shade200, width: 1.5),
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
                      '04/12/2025 às 8:00',
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
                          value: '${confirmedReservations}/5',
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
                          value: '$confirmedReservations/5',
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
                        Icon(Icons.people, size: 18, color: AppTheme.textDark),
                        SizedBox(width: 8),
                        Text(
                          'Lista de Passageiros (${passengers.length})',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: List.generate(
                      passengers.length,
                      (index) => Padding(
                        padding: EdgeInsets.only(
                          bottom: index < passengers.length - 1 ? 12 : 0,
                        ),
                        child: _passengerCard(passengers[index]),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16),
          ],
        ),
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

  Widget _passengerCard(Map<String, dynamic> passenger) {
    bool isPaid = passenger['paid'] as bool;

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
                        passenger['name'],
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Text(
                        passenger['seat'],
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
                  isPaid ? 'Pago' : 'Pendente',
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
                      clientId: passenger['id'] ?? '',
                      clientName: passenger['name'] ?? 'Passageiro',
                      driverId: '', // TODO: passar o ID do motorista logado
                      driverName:
                          'Motorista', // TODO: passar o nome do motorista logado
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          chatId: chatId,
                          otherUserName: passenger['name'] ?? 'Passageiro',
                          otherUserId: passenger['id'] ?? '',
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
                    _showPassengerProfile(passenger);
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

  void _showPassengerProfile(Map<String, dynamic> passenger) {
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
                        passenger['name'],
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Text(
                        passenger['seat'],
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
                value: passenger['phone'],
                icon: Icons.phone,
              ),
              SizedBox(height: 12),
              _profileInfoRow(
                label: 'Email',
                value: passenger['email'],
                icon: Icons.email,
              ),
              SizedBox(height: 12),
              _profileInfoRow(
                label: 'Local de Embarque',
                value: passenger['address'],
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
                      clientId: passenger['id'] ?? '',
                      clientName: passenger['name'] ?? 'Passageiro',
                      driverId: '', // TODO: passar o ID do motorista logado
                      driverName:
                          'Motorista', // TODO: passar o nome do motorista logado
                    );
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          chatId: chatId,
                          otherUserName: passenger['name'] ?? 'Passageiro',
                          otherUserId: passenger['id'] ?? '',
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
