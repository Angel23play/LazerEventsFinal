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
  // 🔥 Constructor CORREGIDO
  // -----------------------
  factory Event.fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      date: (map['date'] is Timestamp)
          ? (map['date'] as Timestamp).toDate()
          : DateTime.parse(map['date']),
      location: map['location'] ?? '',
      category: map['category'] ?? 'General',
      price: (map['price'] ?? 0).toDouble(),
      maxAttendees: map['maxAttendees'] ?? 100,
      organizerId: map['organizerId'] ?? '',
      imageUrl: map['imageUrl'],
      attendees: List<String>.from(map['attendees'] ?? []),
      createdAt: (map['createdAt'] is Timestamp)
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.parse(map['createdAt']),
    );
  }

  // -----------------------
  // 🔥 toMap CORREGIDO
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

  int get availableSpots => maxAttendees - attendees.length;

  bool get isSoldOut => availableSpots <= 0;

  bool get isFree => price == 0;

  @override
  String toString() => 'Event(id: $id, title: $title, date: $date)';
}
