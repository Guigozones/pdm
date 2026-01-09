import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get currentUserId => _auth.currentUser?.uid;

  /// Busca todas as conversas do motorista atual
  Stream<QuerySnapshot> getDriverChats() {
    if (currentUserId == null) {
      return const Stream.empty();
    }
    
    // Sem orderBy para evitar necessidade de índice composto
    // A ordenação será feita na UI
    return _firestore
        .collection('chats')
        .where('driverId', isEqualTo: currentUserId)
        .snapshots();
  }

  /// Busca todas as conversas do cliente atual
  Stream<QuerySnapshot> getClientChats() {
    if (currentUserId == null) {
      return const Stream.empty();
    }
    
    // Sem orderBy para evitar necessidade de índice composto
    return _firestore
        .collection('chats')
        .where('clientId', isEqualTo: currentUserId)
        .snapshots();
  }

  /// Busca mensagens de um chat específico
  Stream<QuerySnapshot> getChatMessages(String chatId) {
    // Sem orderBy para evitar necessidade de índice composto
    // A ordenação será feita na UI
    return _firestore
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .snapshots();
  }

  /// Envia uma mensagem
  Future<void> sendMessage({
    required String chatId,
    required String message,
    required String senderType, // 'driver' ou 'client'
  }) async {
    if (currentUserId == null || message.trim().isEmpty) return;

    final timestamp = FieldValue.serverTimestamp();

    // Adiciona a mensagem
    await _firestore.collection('messages').add({
      'chatId': chatId,
      'senderId': currentUserId,
      'senderType': senderType,
      'message': message.trim(),
      'timestamp': timestamp,
      'type': 'text',
      'isRead': false,
    });

    // Atualiza o chat com a última mensagem
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': message.trim(),
      'lastMessageTime': timestamp,
      'unreadCount': FieldValue.increment(1),
    });
  }

  /// Marca mensagens como lidas
  Future<void> markMessagesAsRead(String chatId, String senderType) async {
    if (currentUserId == null) return;

    // Busca mensagens não lidas que não foram enviadas pelo usuário atual
    final otherSenderType = senderType == 'driver' ? 'client' : 'driver';
    
    final unreadMessages = await _firestore
        .collection('messages')
        .where('chatId', isEqualTo: chatId)
        .where('senderType', isEqualTo: otherSenderType)
        .where('isRead', isEqualTo: false)
        .get();

    // Marca cada mensagem como lida
    final batch = _firestore.batch();
    for (var doc in unreadMessages.docs) {
      batch.update(doc.reference, {'isRead': true});
    }
    await batch.commit();

    // Zera o contador de não lidas no chat
    await _firestore.collection('chats').doc(chatId).update({
      'unreadCount': 0,
    });
  }

  /// Cria ou busca um chat existente entre motorista e cliente
  Future<String> getOrCreateChat({
    required String clientId,
    required String driverId,
    required String driverName,
    String? driverPhoto,
    String? clientName,
  }) async {
    // Verifica se já existe um chat entre os dois
    final existingChat = await _firestore
        .collection('chats')
        .where('clientId', isEqualTo: clientId)
        .where('driverId', isEqualTo: driverId)
        .limit(1)
        .get();

    if (existingChat.docs.isNotEmpty) {
      return existingChat.docs.first.id;
    }

    // Cria um novo chat
    final newChat = await _firestore.collection('chats').add({
      'clientId': clientId,
      'driverId': driverId,
      'driverName': driverName,
      'driverPhoto': driverPhoto,
      'clientName': clientName ?? 'Cliente',
      'createdAt': FieldValue.serverTimestamp(),
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCount': 0,
      'isPinned': false,
    });

    return newChat.id;
  }

  /// Busca informações de um usuário
  Future<Map<String, dynamic>?> getUserInfo(String oderId) async {
    final doc = await _firestore.collection('users').doc(oderId).get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }
}
