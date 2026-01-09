import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/vehicle_model.dart';

class VehicleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  /// Referência à coleção de veículos
  CollectionReference get _vehiclesRef => _firestore.collection('vehicles');

  /// Busca todos os veículos de um usuário
  Future<List<VehicleModel>> getVehiclesByOwner(String ownerId) async {
    try {
      final snapshot = await _vehiclesRef
          .where('ownerId', isEqualTo: ownerId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => VehicleModel.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Erro ao buscar veículos: $e');
      return [];
    }
  }

  /// Stream de veículos do usuário (atualiza em tempo real)
  Stream<List<VehicleModel>> watchVehiclesByOwner(String ownerId) {
    return _vehiclesRef
        .where('ownerId', isEqualTo: ownerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => VehicleModel.fromFirestore(doc))
            .toList());
  }

  /// Adiciona um novo veículo
  Future<VehicleModel> addVehicle({
    required String ownerId,
    required String type,
    required String brand,
    required String model,
    required String plate,
    required int seats,
    required int year,
    double mileage = 0,
    String status = 'Ativo',
    List<String> amenities = const [],
  }) async {
    final docRef = _vehiclesRef.doc();
    
    final vehicle = VehicleModel(
      id: docRef.id,
      ownerId: ownerId,
      type: type,
      brand: brand,
      model: model,
      plate: plate.toUpperCase(),
      seats: seats,
      year: year,
      mileage: mileage,
      status: status,
      amenities: amenities,
      createdAt: DateTime.now(),
    );

    await docRef.set(vehicle.toFirestore());
    return vehicle;
  }

  /// Atualiza um veículo existente
  Future<void> updateVehicle(VehicleModel vehicle) async {
    await _vehiclesRef.doc(vehicle.id).update(vehicle.toFirestore());
  }

  /// Atualiza apenas o status do veículo
  Future<void> updateVehicleStatus(String vehicleId, String status) async {
    await _vehiclesRef.doc(vehicleId).update({'status': status});
  }

  /// Deleta um veículo
  Future<void> deleteVehicle(String vehicleId) async {
    await _vehiclesRef.doc(vehicleId).delete();
  }

  /// Busca um veículo pelo ID
  Future<VehicleModel?> getVehicleById(String vehicleId) async {
    try {
      final doc = await _vehiclesRef.doc(vehicleId).get();
      if (doc.exists) {
        return VehicleModel.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Erro ao buscar veículo: $e');
      return null;
    }
  }

  /// Conta total de veículos do usuário
  Future<int> countVehicles(String ownerId) async {
    final snapshot = await _vehiclesRef
        .where('ownerId', isEqualTo: ownerId)
        .count()
        .get();
    return snapshot.count ?? 0;
  }
}
