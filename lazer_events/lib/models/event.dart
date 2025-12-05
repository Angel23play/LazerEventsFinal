import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  String id;
  String title;
  String description;
  DateTime date;
  String location;
  String category;
  double price;
  int maxAttendees;
  String organizerId;
  String? imageUrl;
  List<String> attendees;
  DateTime createdAt;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.category,
    required this.price,
    required this.maxAttendees,
    required this.organizerId,
    this.imageUrl,
    this.attendees = const [],
    required this.createdAt,
  });

  // -----------------------
  // Factory seguro desde Map
  // -----------------------
  factory Event.fromMap(Map<String, dynamic> map) {
    // Helper para parsear DateTime seguro
    DateTime parseDate(dynamic value, {DateTime? fallback}) {
      if (value == null) return fallback ?? DateTime.now();
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      try {
        return DateTime.parse(value.toString());
      } catch (_) {
        // si no se puede parsear, retornar fallback o ahora
        return fallback ?? DateTime.now();
      }
    }

    // Helper para parsear double seguro
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    // Helper para parsear int seguro
    int parseInt(dynamic value, {int fallback = 100}) {
      if (value == null) return fallback;
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse(value.toString()) ?? fallback;
    }

    return Event(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: parseDate(map['date']),
      location: map['location'] ?? '',
      category: map['category'] ?? 'General',
      price: parseDouble(map['price']),
      maxAttendees: parseInt(map['maxAttendees'], fallback: 100),
      organizerId: map['organizerId'] ?? '',
      imageUrl: map['imageUrl'],
      attendees: List<String>.from(map['attendees'] ?? []),
      createdAt: parseDate(map['createdAt'], fallback: DateTime.now()),
    );
  }

  // -----------------------
  // toMap para Firestore
  // -----------------------
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': Timestamp.fromDate(date),
      'location': location,
      'category': category,
      'price': price,
      'maxAttendees': maxAttendees,
      'organizerId': organizerId,
      'imageUrl': imageUrl,
      'attendees': attendees,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // -----------------------
  // Método copyWith (dentro de la clase)
  // -----------------------
  Event copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    String? location,
    String? category,
    double? price,
    int? maxAttendees,
    String? organizerId,
    String? imageUrl,
    List<String>? attendees,
    DateTime? createdAt,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      location: location ?? this.location,
      category: category ?? this.category,
      price: price ?? this.price,
      maxAttendees: maxAttendees ?? this.maxAttendees,
      organizerId: organizerId ?? this.organizerId,
      imageUrl: imageUrl ?? this.imageUrl,
      attendees: attendees ?? this.attendees,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  int get availableSpots => maxAttendees - attendees.length;

  bool get isSoldOut => availableSpots <= 0;

  bool get isFree => price == 0;

  @override
  String toString() => 'Event(id: $id, title: $title, date: $date)';
}
