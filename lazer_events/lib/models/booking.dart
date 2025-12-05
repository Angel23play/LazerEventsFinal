import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String id;
  final String userId;
  final String eventId;
  final String? eventTitle;
  final DateTime? eventDate;
  final DateTime? bookingDate;
  final double? pricePaid;
  final String status;
  final DateTime createdAt;

  Booking({
    required this.id,
    required this.userId,
    required this.eventId,
    this.eventTitle,
    this.eventDate,
    this.bookingDate,
    this.pricePaid,
    required this.status,
    required this.createdAt,
  });

  factory Booking.fromMap(Map<String, dynamic> data, String id) {
    return Booking(
      id: id,
      userId: data['userId'] ?? '',
      eventId: data['eventId'] ?? '',
      eventTitle: data['eventTitle'],
      eventDate: _toDate(data['eventDate']),
      bookingDate: _toDate(data['bookingDate']),
      pricePaid: (data['pricePaid'] is num)
          ? (data['pricePaid'] as num).toDouble()
          : null,
      status: data['status'] ?? 'unknown',
      createdAt: _toDate(data['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'eventId': eventId,
      'eventTitle': eventTitle,
      'eventDate': eventDate?.toIso8601String(),
      'bookingDate': bookingDate?.toIso8601String(),
      'pricePaid': pricePaid,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  /// Convierte tanto Timestamp como String → DateTime
  static DateTime? _toDate(dynamic value) {
    if (value == null) return null;

    if (value is Timestamp) {
      return value.toDate();
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    return null;
  }
}
