import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'chat_screen.dart';

class ConversasScreen extends StatefulWidget {
  const ConversasScreen({Key? key}) : super(key: key);

  @override
  _ConversasScreenState createState() => _ConversasScreenState();
}

class _ConversasScreenState extends State<ConversasScreen> {
  final List<Map<String, dynamic>> conversas = [
    {'name': 'Marília Mendoça', 'route': 'Caxias → Teresina', 'time': '10:30', 'message': 'A que horas você passa no meu local de embarque?', 'unread': true},
    {'name': 'João Gomes', 'route': 'Caxias → Aldeias Altas', 'time': '09:33', 'message': 'Obrigado! Até amanhã!', 'unread': false},
    {'name': 'Simone Simária', 'route': 'Caxias → São João do Sóter', 'time': '08:30', 'message': 'Pode levar uma mala extra?', 'unread': false},
    {'name': 'Henrique Juliano', 'route': 'Teresina → São João do Sóter', 'time': '08:30', 'message': 'Eu vou ter que meus dois cachorrros. Tem algum...', 'unread': false},
  ];

  final TextEditingController searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Conversas'),
        backgroundColor: AppTheme.primaryStart,
        elevation: 0,
        actions: [
          Padding(padding: EdgeInsets.only(right: 16), child: Center(child: Icon(Icons.notifications, size: 20))),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _SearchBar(controller: searchController),
            _ConversasList(conversas: conversas),
          ],
        ),
      ),
    );
  }
}

/// Barra de busca
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;

  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Buscar Conversas',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Colors.grey.shade400, size: 18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: Colors.grey.shade300)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: AppTheme.primaryStart)),
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        ),
      ),
    );
  }
}

/// Lista de conversas
class _ConversasList extends StatelessWidget {
  final List<Map<String, dynamic>> conversas;

  const _ConversasList({required this.conversas});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        children: List.generate(
          conversas.length,
          (index) => Padding(
            padding: EdgeInsets.only(bottom: index < conversas.length - 1 ? 12 : 0),
            child: _ConversaCard(conversa: conversas[index]),
          ),
        ),
      ),
    );
  }
}

/// Card individual de conversa
class _ConversaCard extends StatelessWidget {
  final Map<String, dynamic> conversa;

  const _ConversaCard({required this.conversa});

  @override
  Widget build(BuildContext context) {
    bool isUnread = conversa['unread'] as bool;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              passengerName: conversa['name'],
              route: conversa['route'],
            ),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isUnread ? AppTheme.primaryStart.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnread ? AppTheme.primaryStart.withOpacity(0.2) : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ConversaHeader(conversa: conversa, isUnread: isUnread),
            SizedBox(height: 10),
            _ConversaMessage(message: conversa['message'], isUnread: isUnread),
          ],
        ),
      ),
    );
  }
}

/// Cabeçalho da conversa
class _ConversaHeader extends StatelessWidget {
  final Map<String, dynamic> conversa;
  final bool isUnread;

  const _ConversaHeader({required this.conversa, required this.isUnread});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryStart.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(child: Icon(Icons.person, size: 20, color: AppTheme.primaryStart)),
            ),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(conversa['name'], style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textDark)),
                SizedBox(height: 4),
                Text(conversa['route'], style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
              ],
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(conversa['time'], style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
            SizedBox(height: 4),
            if (isUnread)
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(color: AppTheme.primaryStart, borderRadius: BorderRadius.circular(12)),
                child: Center(child: Icon(Icons.send, size: 14, color: Colors.white)),
              ),
          ],
        ),
      ],
    );
  }
}

/// Mensagem da conversa
class _ConversaMessage extends StatelessWidget {
  final String message;
  final bool isUnread;

  const _ConversaMessage({required this.message, required this.isUnread});

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey.shade700,
        fontWeight: isUnread ? FontWeight.w500 : FontWeight.w400,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}
