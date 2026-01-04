import 'package:cloud_firestore/cloud_firestore.dart';

class RouteModel {
  final String? id;
  final String ownerId;
  final String origin;
  final String destination;
  final double price;
  final int capacity;
  final int availableSeats;
  final String duration;
  final List<String> timeSlots;
  final String status; // 'Ativa', 'Pausada', 'Inativa'
  final int tripsPerWeek;
  final DateTime? createdAt;

  RouteModel({
    this.id,
    required this.ownerId,
    required this.origin,
    required this.destination,
    required this.price,
    required this.capacity,
    this.availableSeats = 0,
    this.duration = '',
    this.timeSlots = const [],
    this.status = 'Ativa',
    this.tripsPerWeek = 0,
    this.createdAt,
  });

  String get title => '$origin → $destination';

  String get formattedPrice => 'R\$ ${price.toStringAsFixed(2)}';

  String get seatsText {
    if (availableSeats == 1) return '1 lugar';
    return '$availableSeats lugares';
  }

  String get tripsText => '$tripsPerWeek viagens/semana';

  factory RouteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return RouteModel(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      origin: data['origin'] ?? '',
      destination: data['destination'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      capacity: data['capacity'] ?? 0,
      availableSeats: data['availableSeats'] ?? 0,
      duration: data['duration'] ?? '',
      timeSlots: List<String>.from(data['timeSlots'] ?? []),
      status: data['status'] ?? 'Ativa',
      tripsPerWeek: data['tripsPerWeek'] ?? 0,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'ownerId': ownerId,
      'origin': origin,
      'destination': destination,
      'price': price,
      'capacity': capacity,
      'availableSeats': availableSeats,
      'duration': duration,
      'timeSlots': timeSlots,
      'status': status,
      'tripsPerWeek': tripsPerWeek,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }

  RouteModel copyWith({
    String? id,
    String? ownerId,
    String? origin,
    String? destination,
    double? price,
    int? capacity,
    int? availableSeats,
    String? duration,
    List<String>? timeSlots,
    String? status,
    int? tripsPerWeek,
    DateTime? createdAt,
  }) {
    return RouteModel(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      price: price ?? this.price,
      capacity: capacity ?? this.capacity,
      availableSeats: availableSeats ?? this.availableSeats,
      duration: duration ?? this.duration,
      timeSlots: timeSlots ?? this.timeSlots,
      status: status ?? this.status,
      tripsPerWeek: tripsPerWeek ?? this.tripsPerWeek,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
