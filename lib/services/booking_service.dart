import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'tickets'; // Coleção de tickets no Firebase

  /// Buscar nome do usuário pelo ID
  Future<String> _getUserName(String oderId) async {
    try {
      final doc = await _firestore.collection('users').doc(oderId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return data['name'] ?? 'Passageiro';
      }
    } catch (e) {
      print('Erro ao buscar usuário: $e');
    }
    return 'Passageiro';
  }

  /// Stream de todos os tickets de uma rota (sem filtro de data)
  Stream<List<BookingModel>> watchAllBookingsByRoute(String routeId) {
    print('🔍 Buscando tickets para routeId: $routeId');
    return _firestore
        .collection(_collection)
        .where('routeId', isEqualTo: routeId)
        .snapshots()
        .asyncMap((snapshot) async {
          print('📦 Encontrados ${snapshot.docs.length} tickets');

          List<BookingModel> bookings = [];
          for (var doc in snapshot.docs) {
            print('📄 Ticket: ${doc.data()}');
            var booking = BookingModel.fromFirestore(doc);

            // Se o nome do passageiro não foi encontrado, busca pelo clientId
            if (booking.passengerName == 'Passageiro' &&
                booking.passengerId.isNotEmpty) {
              final userName = await _getUserName(booking.passengerId);
              booking = booking.copyWith(passengerName: userName);
            }

            bookings.add(booking);
          }

          return bookings;
        });
  }

  /// Stream de reservas para uma rota em uma data específica
  Stream<List<BookingModel>> watchBookingsByRouteAndDate(
    String routeId,
    DateTime date,
  ) {
    // Normaliza a data para início e fim do dia
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    return _firestore
        .collection(_collection)
        .where('routeId', isEqualTo: routeId)
        .where(
          'travelDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where('travelDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => BookingModel.fromFirestore(doc))
              .toList(),
        );
  }

  /// Buscar reservas para uma rota em uma data específica
  Future<List<BookingModel>> getBookingsByRouteAndDate(
    String routeId,
    DateTime date,
  ) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final snapshot = await _firestore
        .collection(_collection)
        .where('routeId', isEqualTo: routeId)
        .where(
          'travelDate',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay),
        )
        .where('travelDate', isLessThanOrEqualTo: Timestamp.fromDate(endOfDay))
        .get();

    return snapshot.docs.map((doc) => BookingModel.fromFirestore(doc)).toList();
  }

  /// Buscar reservas de um passageiro
  Future<List<BookingModel>> getBookingsByPassenger(String passengerId) async {
    final snapshot = await _firestore
        .collection(_collection)
        .where('passengerId', isEqualTo: passengerId)
        .orderBy('bookingDate', descending: true)
        .get();

    return snapshot.docs.map((doc) => BookingModel.fromFirestore(doc)).toList();
  }

  /// Criar nova reserva
  Future<String> createBooking(BookingModel booking) async {
    final docRef = await _firestore
        .collection(_collection)
        .add(booking.toFirestore());
    return docRef.id;
  }

  /// Atualizar status da reserva
  Future<void> updateBookingStatus(String bookingId, String status) async {
    await _firestore.collection(_collection).doc(bookingId).update({
      'status': status,
    });
  }

  /// Cancelar reserva
  Future<void> cancelBooking(String bookingId) async {
    await updateBookingStatus(bookingId, 'cancelado');
  }

  /// Confirmar pagamento
  Future<void> confirmPayment(String bookingId) async {
    await updateBookingStatus(bookingId, 'pago');
  }

  /// Deletar reserva
  Future<void> deleteBooking(String bookingId) async {
    await _firestore.collection(_collection).doc(bookingId).delete();
  }

  /// Contar reservas pagas para uma rota/data
  Future<int> countPaidBookings(String routeId, DateTime date) async {
    final bookings = await getBookingsByRouteAndDate(routeId, date);
    return bookings.where((b) => b.isPaid).length;
  }

  /// Verificar disponibilidade de assento
  Future<bool> isSeatAvailable(
    String routeId,
    DateTime date,
    int seatNumber,
  ) async {
    final bookings = await getBookingsByRouteAndDate(routeId, date);
    return !bookings.any(
      (b) => b.seatNumber == seatNumber && b.status != 'cancelado',
    );
  }

  /// Obter próximo assento disponível
  Future<int> getNextAvailableSeat(
    String routeId,
    DateTime date,
    int totalSeats,
  ) async {
    final bookings = await getBookingsByRouteAndDate(routeId, date);
    final takenSeats = bookings
        .where((b) => b.status != 'cancelado')
        .map((b) => b.seatNumber)
        .toSet();

    for (int i = 1; i <= totalSeats; i++) {
      if (!takenSeats.contains(i)) {
        return i;
      }
    }
    return -1; // Nenhum assento disponível
  }
}
