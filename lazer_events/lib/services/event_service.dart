import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event.dart';

class EventService {
  final CollectionReference eventsRef = FirebaseFirestore.instance.collection(
    'events',
  );

  // Obtener todos los eventos
  Future<List<Event>> getEvents() async {
    final snapshot = await eventsRef
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Event.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  // Crear un evento
  Future<void> addEvent(Event event) async {
    await eventsRef.doc(event.id).set(event.toMap());
  }

  //  Obtener un evento por ID
  Future<Event?> getEventById(String id) async {
    final doc = await eventsRef.doc(id).get();

    if (!doc.exists) return null;

    return Event.fromMap(doc.data() as Map<String, dynamic>);
  }

  //  Actualizar evento
  Future<void> updateEvent(String id, Event event) async {
    await eventsRef.doc(id).update(event.toMap());
  }

  //  Eliminar evento
  Future<void> deleteEvent(String id) async {
    await eventsRef.doc(id).delete();
  }

  //  Registrar un usuario en un evento (con validación de aforo)
  Future<void> registerForEvent(String eventId, String userId) async {
    return FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentReference eventDoc = eventsRef.doc(eventId);

      DocumentSnapshot snapshot = await transaction.get(eventDoc);

      if (!snapshot.exists) {
        throw Exception("Evento no encontrado en Firestore");
      }

      final data = snapshot.data() as Map<String, dynamic>;

      List attendees = List<String>.from(data['attendees'] ?? []);
      int maxAttendees = data['maxAttendees'];

      if (attendees.contains(userId)) {
        throw Exception("Ya estás registrado");
      }

      if (attendees.length >= maxAttendees) {
        throw Exception("El evento está lleno");
      }

      attendees.add(userId);

      transaction.update(eventDoc, {'attendees': attendees});
    });
  }
}
