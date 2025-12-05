import 'package:flutter/material.dart';
import '../../models/event.dart';
import '../booking/booking_screen.dart';

class EventDetailScreen extends StatelessWidget {
  final Event event;

  const EventDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    // Formatear fecha
    final formattedDate =
        "${event.date.day}/${event.date.month}/${event.date.year}";
    final formattedTime =
        "${event.date.hour}:${event.date.minute.toString().padLeft(2, '0')}";

    // Verificar si hay cupos disponibles
    final availableSpots = event.maxAttendees - event.attendees.length;
    final isSoldOut = availableSpots <= 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          event.title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blue.shade800,
        centerTitle: true,
        elevation: 4,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Imagen del evento
            Container(
              height: 250,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.blue.shade800, Colors.blue.shade600],
                ),
              ),
              child: Stack(
                children: [
                  // Imagen
                  Image.network(
                    event.imageUrl ??
                        'https://picsum.photos/400/300?random=${event.id}',
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.blue.shade100,
                        child: const Icon(
                          Icons.event,
                          size: 100,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),

                  // Overlay con título
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.7),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        event.title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          shadows: [
                            Shadow(blurRadius: 10, color: Colors.black),
                          ],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Información del evento
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Precio
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: event.price > 0
                          ? Colors.orange.shade50
                          : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: event.price > 0
                            ? Colors.orange.shade200
                            : Colors.green.shade200,
                      ),
                    ),
                    child: Text(
                      event.price > 0
                          ? 'Precio: \$${event.price.toStringAsFixed(2)}'
                          : '🎉 ENTRADA GRATUITA',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: event.price > 0
                            ? Colors.orange.shade800
                            : Colors.green.shade800,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Descripción
                  const Text(
                    "Descripción",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.description,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Detalles en tarjetas
                  const Text(
                    "Detalles del Evento",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _buildDetailCard(
                        icon: Icons.calendar_today,
                        title: "Fecha",
                        value: formattedDate,
                      ),
                      _buildDetailCard(
                        icon: Icons.access_time,
                        title: "Hora",
                        value: formattedTime,
                      ),
                      _buildDetailCard(
                        icon: Icons.location_on,
                        title: "Ubicación",
                        value: event.location,
                      ),
                      _buildDetailCard(
                        icon: Icons.category,
                        title: "Categoría",
                        value: event.category,
                      ),
                      _buildDetailCard(
                        icon: Icons.people,
                        title: "Cupos",
                        value: "$availableSpots / ${event.maxAttendees}",
                        isHighlighted: availableSpots < 10,
                      ),
                      _buildDetailCard(
                        icon: Icons.person,
                        title: "Organizador",
                        value: "ID: ${event.organizerId}",
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Información de asistencia
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.info, color: Colors.blue, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "Información de Asistencia",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "• ${event.attendees.length} personas ya se han registrado\n"
                          "• ${availableSpots > 0 ? availableSpots : 0} cupos disponibles\n"
                          "• Registro hasta 1 hora antes del evento",
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Botón de reserva
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isSoldOut
                          ? null
                          : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => BookingScreen(event: event),
                                ),
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSoldOut
                            ? Colors.grey
                            : Colors.blue.shade800,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.confirmation_num),
                          const SizedBox(width: 12),
                          Text(
                            isSoldOut ? "EVENTO AGOTADO" : "RESERVAR MI CUPO",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Mensaje si está agotado
                  if (isSoldOut)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.error, color: Colors.red),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Lo sentimos, este evento ya no tiene cupos disponibles.",
                              style: TextStyle(
                                color: Colors.red,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String value,
    bool isHighlighted = false,
  }) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: Colors.blue.shade700),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isHighlighted ? Colors.orange.shade800 : Colors.black,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
