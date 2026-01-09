import 'package:cloud_firestore/cloud_firestore.dart';

class VehicleModel {
  final String id;
  final String ownerId; // ID do usuário dono do veículo
  final String type; // 'Van' ou 'Lotação'
  final String brand;
  final String model;
  final String plate;
  final int seats;
  final int year;
  final double mileage;
  final String status; // 'Ativo', 'Manutenção', 'Inativo'
  final DateTime? lastReview;
  final List<String> amenities; // 'Ar Condicionado', 'Wi-Fi', 'USB'
  final DateTime createdAt;

  VehicleModel({
    required this.id,
    required this.ownerId,
    this.type = 'Van',
    required this.brand,
    required this.model,
    required this.plate,
    required this.seats,
    required this.year,
    this.mileage = 0,
    this.status = 'Ativo',
    this.lastReview,
    this.amenities = const [],
    required this.createdAt,
  });

  /// Nome completo do veículo (marca + modelo)
  String get fullName => '$brand $model';

  /// Cria VehicleModel a partir de um documento Firestore
  factory VehicleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return VehicleModel(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      type: data['type'] ?? 'Van',
      brand: data['brand'] ?? '',
      model: data['model'] ?? '',
      plate: data['plate'] ?? '',
      seats: data['seats'] ?? 0,
      year: data['year'] ?? 0,
      mileage: (data['mileage'] ?? 0).toDouble(),
      status: data['status'] ?? 'Ativo',
      lastReview: (data['lastReview'] as Timestamp?)?.toDate(),
      amenities: List<String>.from(data['amenities'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converte VehicleModel para Map (para salvar no Firestore)
  Map<String, dynamic> toFirestore() {
    return {
      'ownerId': ownerId,
      'type': type,
      'brand': brand,
      'model': model,
      'plate': plate,
      'seats': seats,
      'year': year,
      'mileage': mileage,
      'status': status,
      'lastReview': lastReview != null ? Timestamp.fromDate(lastReview!) : null,
      'amenities': amenities,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// Cria uma cópia com campos alterados
  VehicleModel copyWith({
    String? type,
    String? brand,
    String? model,
    String? plate,
    int? seats,
    int? year,
    double? mileage,
    String? status,
    DateTime? lastReview,
    List<String>? amenities,
  }) {
    return VehicleModel(
      id: id,
      ownerId: ownerId,
      type: type ?? this.type,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      plate: plate ?? this.plate,
      seats: seats ?? this.seats,
      year: year ?? this.year,
      mileage: mileage ?? this.mileage,
      status: status ?? this.status,
      lastReview: lastReview ?? this.lastReview,
      amenities: amenities ?? this.amenities,
      createdAt: createdAt,
    );
  }
}
