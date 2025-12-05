import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';
import 'package:flutter/foundation.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final CollectionReference<Map<String, dynamic>> _bookingsCollection =
      FirebaseFirestore.instance.collection('bookings');

  final CollectionReference<Map<String, dynamic>> _eventsCollection =
      FirebaseFirestore.instance.collection('events');

  /// Reserva un evento correctamente, buscando el documentId real del evento
  Future<void> bookEvent(String userId, Event event) async {
    try {
      final query = await _eventsCollection
          .where('id', isEqualTo: event.id)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        print("🟦 DEBUG event.id recibido: ${event.id}");
        throw Exception('Evento no encontrado en la base de datos');
        

      }

      final eventDoc = query.docs.first;
      final eventRef = eventDoc.reference;

      await _firestore.runTransaction((transaction) async {
        final bookingRef = _bookingsCollection.doc('${event.id}_$userId');


        final bookingSnapshot = await transaction.get(bookingRef);
        if (bookingSnapshot.exists) {
          throw Exception('Ya tienes una reserva para este evento');
        }

      
        final eventSnapshot = await transaction.get(eventRef);

        if (!eventSnapshot.exists) {
          throw Exception('Evento no encontrado (conflicto interno)');
        }

        final data = eventSnapshot.data()!;
        final attendees = List<String>.from(data['attendees'] ?? []);
        final maxAttendees = data['maxAttendees'] ?? event.maxAttendees;

        if (attendees.contains(userId)) {
          throw Exception('Ya estás registrado en este evento');
        }

        if (attendees.length >= maxAttendees) {
          throw Exception('El evento está agotado');
        }

        // 4️⃣ Agregar usuario a asistentes
        attendees.add(userId);

        transaction.update(eventRef, {
          'attendees': attendees,
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // 5️⃣ Crear la reserva
        final bookingData = {
          'id': '${event.id}_$userId',
          'userId': userId,
          'eventId': event.id,
          'eventTitle': event.title,
          'eventDate': event.date.toIso8601String(),
          'bookingDate': DateTime.now().toIso8601String(),
          'pricePaid': event.price,
          'status': 'confirmed',
          'createdAt': FieldValue.serverTimestamp(),
        };

        transaction.set(bookingRef, bookingData);

        debugPrint(
          '✅ Reserva creada exitosamente para el evento: ${event.title}',
        );
      });
    } catch (e) {
      debugPrint('❌ Error creando reserva: $e');
      rethrow;
    }
  }

  /// Obtiene todas las reservas del usuario
  Future<List<Map<String, dynamic>>> getUserBookings(String userId) async {
    try {
      final querySnapshot = await _bookingsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('bookingDate', descending: true)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        return <String, dynamic>{'id': doc.id, ...data};
      }).toList();
    } catch (e) {
      debugPrint('❌ Error obteniendo reservas: $e');
      return [];
    }
  }

  /// Cancela una reserva
  Future<void> cancelBooking(
    String bookingId,
    String eventId,
    String userId,
  ) async {
    try {
      // Buscar evento por ID real
      final query = await _eventsCollection
          .where('id', isEqualTo: eventId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception('Evento no encontrado');
      }

      final eventRef = query.docs.first.reference;

      await _firestore.runTransaction((transaction) async {
        final bookingRef = _bookingsCollection.doc(bookingId);
        final bookingSnapshot = await transaction.get(bookingRef);

        if (!bookingSnapshot.exists) {
          throw Exception('Reserva no encontrada');
        }

        final bookingData = bookingSnapshot.data();
        if (bookingData?['userId'] != userId) {
          throw Exception('No tienes permiso para cancelar esta reserva');
        }

        final eventSnapshot = await transaction.get(eventRef);
        if (eventSnapshot.exists) {
          final data = eventSnapshot.data();
          final attendees = List<String>.from(data?['attendees'] ?? []);
          attendees.remove(userId);

          transaction.update(eventRef, {
            'attendees': attendees,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }

        transaction.update(bookingRef, {
          'status': 'cancelled',
          'cancelledAt': FieldValue.serverTimestamp(),
        });

        debugPrint('⚠️ Reserva cancelada correctamente');
      });
    } catch (e) {
      debugPrint('❌ Error cancelando reserva: $e');
      rethrow;
    }
  }

  /// Verifica si el usuario ya está registrado
  Future<bool> isUserRegistered(String userId, String eventId) async {
    try {
      final query = await _bookingsCollection
          .where('userId', isEqualTo: userId)
          .where('eventId', isEqualTo: eventId)
          .where('status', isEqualTo: 'confirmed')
          .limit(1)
          .get();

      return query.docs.isNotEmpty;
    } catch (e) {
      debugPrint('❌ Error verificando registro: $e');
      return false;
    }
  }
}
