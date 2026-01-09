import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel {
  final String? id;
  final String routeId;
  final String passengerId;
  final String passengerName;
  final String passengerEmail;
  final String passengerPhone;
  final String boardingAddress;
  final int seatNumber;
  final double price;
  final String status; // 'pendente', 'pago', 'cancelado'
  final DateTime bookingDate; // Data da viagem reservada
  final DateTime createdAt;

  BookingModel({
    this.id,
    required this.routeId,
    required this.passengerId,
    required this.passengerName,
    required this.passengerEmail,
    required this.passengerPhone,
    this.boardingAddress = '',
    required this.seatNumber,
    required this.price,
    this.status = 'pendente',
    required this.bookingDate,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  bool get isPaid => status == 'pago';

  String get seatText => 'Assento $seatNumber';

  String get statusText {
    switch (status) {
      case 'pago':
        return 'Pago';
      case 'pendente':
        return 'Pendente';
      case 'cancelado':
        return 'Cancelado';
      default:
        return status;
    }
  }

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    // Tenta obter a data da viagem - pode ser String ou Timestamp
    DateTime travelDate = DateTime.now();
    if (data['date'] != null) {
      if (data['date'] is Timestamp) {
        travelDate = (data['date'] as Timestamp).toDate();
      } else if (data['date'] is String) {
        // Formato esperado: "09/01/2026"
        try {
          final parts = (data['date'] as String).split('/');
          if (parts.length == 3) {
            travelDate = DateTime(
              int.parse(parts[2]), // ano
              int.parse(parts[1]), // mês
              int.parse(parts[0]), // dia
            );
          }
        } catch (e) {
          print('Erro ao parsear data: ${data['date']}');
        }
      }
    } else if (data['travelDate'] != null) {
      if (data['travelDate'] is Timestamp) {
        travelDate = (data['travelDate'] as Timestamp).toDate();
      }
    } else if (data['bookingDate'] != null) {
      if (data['bookingDate'] is Timestamp) {
        travelDate = (data['bookingDate'] as Timestamp).toDate();
      }
    }
    
    // Tenta obter o nome do passageiro/cliente
    String passengerName = data['clientName'] ?? 
                          data['passengerName'] ?? 
                          data['userName'] ?? 
                          data['name'] ?? 
                          'Passageiro';
    
    // Tenta obter o ID do passageiro/cliente
    String passengerId = data['clientId'] ?? 
                        data['passengerId'] ?? 
                        data['userId'] ?? 
                        data['uid'] ?? 
                        '';
    
    // Tenta obter o email
    String passengerEmail = data['clientEmail'] ?? 
                           data['passengerEmail'] ?? 
                           data['userEmail'] ?? 
                           data['email'] ?? 
                           '';
    
    // Tenta obter o telefone
    String passengerPhone = data['clientPhone'] ?? 
                           data['passengerPhone'] ?? 
                           data['userPhone'] ?? 
                           data['phone'] ?? 
                           '';
    
    // Tenta obter o status
    String status = data['status'] ?? data['paymentStatus'] ?? 'pendente';
    // Normaliza o status
    if (status == 'paid' || status == 'confirmed' || status == 'Pago') {
      status = 'pago';
    } else if (status == 'pending' || status == 'Pendente') {
      status = 'pendente';
    } else if (status == 'cancelled' || status == 'canceled' || status == 'Cancelado') {
      status = 'cancelado';
    }
    
    // SeatNumber pode ser String ou int
    int seatNum = 1;
    if (data['seatNumber'] != null) {
      if (data['seatNumber'] is int) {
        seatNum = data['seatNumber'];
      } else if (data['seatNumber'] is String) {
        // Remove letras e pega só o número (ex: "8A" -> 8)
        final numStr = (data['seatNumber'] as String).replaceAll(RegExp(r'[^0-9]'), '');
        seatNum = int.tryParse(numStr) ?? 1;
      }
    }
    
    return BookingModel(
      id: doc.id,
      routeId: data['routeId'] ?? '',
      passengerId: passengerId,
      passengerName: passengerName,
      passengerEmail: passengerEmail,
      passengerPhone: passengerPhone,
      boardingAddress: data['boardingAddress'] ?? data['embarqueLocal'] ?? data['pickupLocation'] ?? data['origin'] ?? '',
      seatNumber: seatNum,
      price: (data['price'] ?? data['valor'] ?? data['amount'] ?? 0).toDouble(),
      status: status,
      bookingDate: travelDate,
      createdAt: data['createdAt'] != null && data['createdAt'] is Timestamp
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'routeId': routeId,
      'passengerId': passengerId,
      'passengerName': passengerName,
      'passengerEmail': passengerEmail,
      'passengerPhone': passengerPhone,
      'boardingAddress': boardingAddress,
      'seatNumber': seatNumber,
      'price': price,
      'status': status,
      'bookingDate': Timestamp.fromDate(bookingDate),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  BookingModel copyWith({
    String? id,
    String? routeId,
    String? passengerId,
    String? passengerName,
    String? passengerEmail,
    String? passengerPhone,
    String? boardingAddress,
    int? seatNumber,
    double? price,
    String? status,
    DateTime? bookingDate,
    DateTime? createdAt,
  }) {
    return BookingModel(
      id: id ?? this.id,
      routeId: routeId ?? this.routeId,
      passengerId: passengerId ?? this.passengerId,
      passengerName: passengerName ?? this.passengerName,
      passengerEmail: passengerEmail ?? this.passengerEmail,
      passengerPhone: passengerPhone ?? this.passengerPhone,
      boardingAddress: boardingAddress ?? this.boardingAddress,
      seatNumber: seatNumber ?? this.seatNumber,
      price: price ?? this.price,
      status: status ?? this.status,
      bookingDate: bookingDate ?? this.bookingDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
