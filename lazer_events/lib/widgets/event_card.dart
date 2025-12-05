import 'package:flutter/material.dart';
import '../models/event.dart';

class EventCard extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showEditButton;
  final bool showDeleteButton;

  const EventCard({
    super.key,
    required this.event,
    required this.onTap,
    this.onEdit,
    this.showEditButton = false,
    this.onDelete,
    this.showDeleteButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        '${event.date.day}/${event.date.month}/${event.date.year}';
    final availableSpots = event.maxAttendees - event.attendees.length;
    final isSoldOut = availableSpots <= 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Imagen del evento
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
                      child: Image.network(
                        event.imageUrl ??
                            'https://picsum.photos/400/300?random=${event.id}',
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return SizedBox(
                            height: 160,
                            width: double.infinity,
                            child: Center(
                              child: CircularProgressIndicator(
                                value:
                                    loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 160,
                            width: double.infinity,
                            color: Colors.blue.shade100,
                            child: const Icon(
                              Icons.event,
                              size: 60,
                              color: Colors.white,
                            ),
                          );
                        },
                      ),
                    ),

                    // Badge de vendido
                    if (isSoldOut)
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'AGOTADO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                    // Badge de precio
                    Positioned(
                      top: 12,
                      left: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: event.price > 0 ? Colors.orange : Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          event.price > 0
                              ? '\$${event.price.toStringAsFixed(2)}'
                              : 'GRATIS',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Contenido de la tarjeta
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título y botón eliminar
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              event.title,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (showEditButton && onEdit != null)
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.black),
                              onPressed: onEdit,
                              iconSize: 20,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          if (showDeleteButton && onDelete != null)
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: onDelete,
                              iconSize: 20,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      // Descripción
                      Text(
                        event.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      const SizedBox(height: 16),

                      // Información del evento
                      Row(
                        children: [
                          // Fecha
                          _buildInfoItem(
                            icon: Icons.calendar_today,
                            text: formattedDate,
                          ),
                          const SizedBox(width: 16),
                          // Ubicación
                          Expanded(
                            child: _buildInfoItem(
                              icon: Icons.location_on,
                              text: event.location,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          // Categoría
                          _buildInfoItem(
                            icon: Icons.category,
                            text: event.category,
                          ),
                          const Spacer(),
                          // Cupos disponibles
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: availableSpots > 10
                                  ? Colors.green.shade50
                                  : availableSpots > 0
                                  ? Colors.orange.shade50
                                  : Colors.red.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: availableSpots > 10
                                    ? Colors.green.shade200
                                    : availableSpots > 0
                                    ? Colors.orange.shade200
                                    : Colors.red.shade200,
                              ),
                            ),
                            child: Text(
                              '$availableSpots cupos',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: availableSpots > 10
                                    ? Colors.green.shade800
                                    : availableSpots > 0
                                    ? Colors.orange.shade800
                                    : Colors.red.shade800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoItem({required IconData icon, required String text}) {
    return Row(
      mainAxisSize: MainAxisSize.min, // <- Evita que el Row crezca sin límites
      children: [
        Icon(icon, size: 16, color: Colors.blue.shade700),
        const SizedBox(width: 6),
        Flexible(
          // <- Flexible en lugar de Expanded
          child: Text(
            text,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
