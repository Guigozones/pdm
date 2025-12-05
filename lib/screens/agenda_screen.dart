import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'agenda_detail_screen.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({Key? key}) : super(key: key);

  @override
  _AgendaScreenState createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime(2025, 10, 24);
  }

  void _selectDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime(2025, 12, 31),
    );
    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() => selectedDate = pickedDate);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Agenda'),
        backgroundColor: AppTheme.primaryStart,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _DatePickerWidget(selectedDate: selectedDate, onDateTap: _selectDate),
            SizedBox(height: 16),
            _AgendaCard(
              origin: 'Caxias',
              destination: 'Teresina',
              status: 'Lotada',
              statusColor: Color(0xFF10B981),
              value: 'R\$ 60,00',
              capacity: 5,
              available: 5,
              time: '1h 10min',
              context: context,
            ),
            SizedBox(height: 14),
            _AgendaCard(
              origin: 'Caxias',
              destination: 'Aldeias Altas',
              status: 'Disponível',
              statusColor: Color(0xFF3B82F6),
              value: 'R\$ 80,00',
              capacity: 10,
              available: 7,
              time: '1h 10min',
              context: context,
            ),
            SizedBox(height: 14),
            _AgendaCard(
              origin: 'Caxias',
              destination: 'São J. do Sóter',
              status: 'Cancelada',
              statusColor: Color(0xFFFB923C),
              value: 'R\$ 100,00',
              capacity: 8,
              available: 3,
              time: '1h 40min',
              context: context,
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget de seleção de data
class _DatePickerWidget extends StatelessWidget {
  final DateTime selectedDate;
  final VoidCallback onDateTap;

  const _DatePickerWidget({
    required this.selectedDate,
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
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: GestureDetector(
        onTap: onDateTap,
        child: Row(
          children: [
            Icon(Icons.calendar_today, color: Colors.grey.shade600, size: 18),
            SizedBox(width: 12),
            Text('Selecionar Data', style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
            Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: AppTheme.primaryStart, borderRadius: BorderRadius.circular(6)),
              child: Text(_formatDate(selectedDate), style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
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
  final String origin;
  final String destination;
  final String status;
  final Color statusColor;
  final String value;
  final int capacity;
  final int available;
  final String time;
  final BuildContext context;

  const _AgendaCard({
    required this.origin,
    required this.destination,
    required this.status,
    required this.statusColor,
    required this.value,
    required this.capacity,
    required this.available,
    required this.time,
    required this.context,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardHeader(origin: origin, destination: destination, status: status, statusColor: statusColor),
          SizedBox(height: 12),
          Divider(color: Colors.grey.shade200, height: 1),
          SizedBox(height: 12),
          _CardDetails(value: value, capacity: capacity, available: available, time: time),
          SizedBox(height: 12),
          _ViewMoreButton(
            origin: origin,
            destination: destination,
            value: value,
            capacity: capacity,
            available: available,
            time: time,
          ),
        ],
      ),
    );
  }
}

/// Cabeçalho do card
class _CardHeader extends StatelessWidget {
  final String origin;
  final String destination;
  final String status;
  final Color statusColor;

  const _CardHeader({
    required this.origin,
    required this.destination,
    required this.status,
    required this.statusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.location_on, size: 20, color: AppTheme.primaryStart),
        SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$origin → $destination', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
              SizedBox(height: 4),
              Text('04/10/2025 às 8:00', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ],
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(6)),
          child: Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
        ),
      ],
    );
  }
}

/// Detalhes do card
class _CardDetails extends StatelessWidget {
  final String value;
  final int capacity;
  final int available;
  final String time;

  const _CardDetails({
    required this.value,
    required this.capacity,
    required this.available,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(Icons.attach_money, size: 16, color: Colors.grey.shade600),
            SizedBox(width: 4),
            Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
          ],
        ),
        Row(
          children: [
            Icon(Icons.event_seat, size: 16, color: Colors.grey.shade600),
            SizedBox(width: 4),
            Text('$available/$capacity lugares', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
          ],
        ),
        Row(
          children: [
            Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
            SizedBox(width: 4),
            Text(time, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textDark)),
          ],
        ),
      ],
    );
  }
}

/// Botão Ver mais
class _ViewMoreButton extends StatelessWidget {
  final String origin;
  final String destination;
  final String value;
  final int capacity;
  final int available;
  final String time;

  const _ViewMoreButton({
    required this.origin,
    required this.destination,
    required this.value,
    required this.capacity,
    required this.available,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryStart,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AgendaDetailScreen(
                origin: origin,
                destination: destination,
                value: value,
                capacity: capacity,
                available: available,
                time: time,
              ),
            ),
          );
        },
        child: Text('Ver mais', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
      ),
    );
  }
}
