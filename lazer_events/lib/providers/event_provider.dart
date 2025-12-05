import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/event_service.dart';

class EventProvider with ChangeNotifier {
  final EventService _eventService = EventService();

  List<Event> _events = [];
  bool _loading = false;
  String? _error;

  List<Event> get events => _events;
  bool get loading => _loading;
  String? get error => _error;

  EventProvider() {
    loadEvents();
  }

  Future<void> loadEvents() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _events = await _eventService.getEvents();
      _error = null;
    } catch (e) {
      _error = 'Error cargando eventos: $e';
      _events = _getMockEvents(); // Usar datos de ejemplo en caso de error
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addEvent(Event event) async {
    _loading = true;
    notifyListeners();

    try {
      await _eventService.addEvent(event);
      await loadEvents(); // Recargar la lista
    } catch (e) {
      _error = 'Error agregando evento: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateEvent(String id, Event updatedEvent) async {
    _loading = true;
    notifyListeners();

    try {
      await _eventService.updateEvent(id, updatedEvent);
      await loadEvents();
    } catch (e) {
      _error = 'Error actualizando evento: $e';
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteEvent(String id) async {
    _loading = true;
    notifyListeners();

    try {
      await _eventService.deleteEvent(id);
      // Eliminar localmente sin recargar
      _events.removeWhere((event) => event.id == id);
      _error = null;
    } catch (e) {
      _error = 'Error eliminando evento: $e';
      notifyListeners();
      rethrow;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> registerForEvent(String eventId, String userId) async {
    try {
      await _eventService.registerForEvent(eventId, userId);
      await loadEvents();
    } catch (e) {
      _error = 'Error registrando para evento: $e';
      notifyListeners();
      rethrow;
    }
  }

  Event? getEventById(String id) {
    return _events.firstWhere((event) => event.id == id);
  }

  List<Event> getEventsByCategory(String category) {
    return _events.where((event) => event.category == category).toList();
  }

  List<Event> getUpcomingEvents() {
    final now = DateTime.now();
    return _events.where((event) => event.date.isAfter(now)).toList();
  }

  List<Event> getPastEvents() {
    final now = DateTime.now();
    return _events.where((event) => event.date.isBefore(now)).toList();
  }

  // Datos de ejemplo para cuando no hay conexión
  List<Event> _getMockEvents() {
    return [
      Event(
        id: '1',
        title: 'Concierto de Rock',
        description: 'Concierto al aire libre con las mejores bandas locales',
        date: DateTime.now().add(const Duration(days: 2)),
        location: 'Parque Central',
        category: 'Música',
        price: 25.0,
        maxAttendees: 200,
        organizerId: 'org1',
        imageUrl: 'https://picsum.photos/400/300?random=1',
        attendees: ['user1', 'user2', 'user3'],
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
      ),
      Event(
        id: '2',
        title: 'Taller de Flutter Avanzado',
        description: 'Aprende Flutter con proyectos reales y mejores prácticas',
        date: DateTime.now().add(const Duration(days: 5)),
        location: 'Universidad Tecnológica',
        category: 'Educación',
        price: 0.0,
        maxAttendees: 50,
        organizerId: 'org2',
        imageUrl: 'https://picsum.photos/400/300?random=2',
        attendees: ['user4', 'user5'],
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      Event(
        id: '3',
        title: 'Feria de Startups',
        description: 'Exposición de emprendimientos tecnológicos innovadores',
        date: DateTime.now().add(const Duration(days: 7)),
        location: 'Centro de Convenciones',
        category: 'Negocios',
        price: 15.0,
        maxAttendees: 150,
        organizerId: 'org3',
        imageUrl: 'https://picsum.photos/400/300?random=3',
        attendees: ['user6'],
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
      ),
      Event(
        id: '4',
        title: 'Maratón Ciudad 2024',
        description: 'Carrera de 10km por las principales calles de la ciudad',
        date: DateTime.now().add(const Duration(days: 10)),
        location: 'Avenida Principal',
        category: 'Deportes',
        price: 30.0,
        maxAttendees: 500,
        organizerId: 'org4',
        imageUrl: 'https://picsum.photos/400/300?random=4',
        attendees: List.generate(450, (index) => 'user${index + 100}'),
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
      ),
    ];
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
