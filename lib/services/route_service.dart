import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/route_model.dart';

class RouteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'routes';

  // Obter rotas do usuário (stream para tempo real)
  Stream<QuerySnapshot> watchRoutesByOwner(String ownerId) {
    return _firestore
        .collection(_collection)
        .where('ownerId', isEqualTo: ownerId)
        .snapshots();
  }

  // Obter rotas do usuário (Future)
  Future<List<RouteModel>> getRoutesByOwner(String ownerId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('ownerId', isEqualTo: ownerId)
        .get();

    return snapshot.docs.map((doc) => RouteModel.fromFirestore(doc)).toList();
  }

  // Adicionar nova rota
  Future<String> addRoute(RouteModel route) async {
    final docRef = await _firestore.collection(_collection).add(route.toFirestore());
    return docRef.id;
  }

  // Atualizar rota
  Future<void> updateRoute(String routeId, RouteModel route) async {
    await _firestore.collection(_collection).doc(routeId).update({
      'origin': route.origin,
      'destination': route.destination,
      'price': route.price,
      'capacity': route.capacity,
      'availableSeats': route.availableSeats,
      'duration': route.duration,
      'timeSlots': route.timeSlots,
      'status': route.status,
      'tripsPerWeek': route.tripsPerWeek,
    });
  }

  // Atualizar status da rota
  Future<void> updateRouteStatus(String routeId, String status) async {
    await _firestore.collection(_collection).doc(routeId).update({
      'status': status,
    });
  }

  // Deletar rota
  Future<void> deleteRoute(String routeId) async {
    await _firestore.collection(_collection).doc(routeId).delete();
  }

  // Obter rota por ID
  Future<RouteModel?> getRouteById(String routeId) async {
    final doc = await _firestore.collection(_collection).doc(routeId).get();
    if (doc.exists) {
      return RouteModel.fromFirestore(doc);
    }
    return null;
  }

  // Contar rotas do usuário
  Future<int> countRoutes(String ownerId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('ownerId', isEqualTo: ownerId)
        .count()
        .get();
    return snapshot.count ?? 0;
  }

  // Contar rotas ativas do usuário
  Future<int> countActiveRoutes(String ownerId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('ownerId', isEqualTo: ownerId)
        .where('status', isEqualTo: 'Ativa')
        .count()
        .get();
    return snapshot.count ?? 0;
  }
}
