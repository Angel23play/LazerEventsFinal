import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/booking_service.dart';

class BookingScreen extends StatefulWidget {
  final Event event;

  const BookingScreen({super.key, required this.event});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  bool loading = false;
  final BookingService _service = BookingService();
  String? errorMessage;

  Future<void> makeBooking() async {
    setState(() {
      loading = true;
      errorMessage = null;
    });

    try {
      // Usar un ID de usuario fijo para la demo
      const userId = "user_demo_123";

      await _service.bookEvent(userId, widget.event);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("✅ Reservado con éxito"),
          backgroundColor: Colors.green,
        ),
      );

      // Esperar un poco antes de cerrar
      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.pop(context, true); // Retornar true para indicar éxito
    } catch (e) {
      setState(() {
        errorMessage = "Error al reservar: $e";
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Confirmar Reserva"),
        backgroundColor: Colors.blue[800],
        elevation: 4,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del evento
            _buildEventInfo(),

            const SizedBox(height: 24),

            // Detalles de la reserva
            _buildBookingDetails(),

            const SizedBox(height: 32),

            // Mensaje de error
            if (errorMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Botones de acción
            _buildActionButtons(),

            const SizedBox(height: 20),

            // Información adicional
            _buildAdditionalInfo(),
          ],
        ),
      ),
    );
  }

  Widget _buildEventInfo() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.event.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            Row(
              children: [
                Icon(Icons.calendar_today, size: 18, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  '${widget.event.date.day}/${widget.event.date.month}/${widget.event.date.year}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),

            const SizedBox(height: 4),

            Row(
              children: [
                Icon(Icons.location_on, size: 18, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.event.location,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            Divider(color: Colors.grey[300]),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Precio:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: widget.event.price > 0
                        ? Colors.orange[50]
                        : Colors.green[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.event.price > 0
                        ? '\$${widget.event.price.toStringAsFixed(2)}'
                        : 'GRATIS',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: widget.event.price > 0
                          ? Colors.orange[800]
                          : Colors.green[800],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingDetails() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade800),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Detalles de la Reserva",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              const Icon(Icons.person, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              const Text(
                "Usuario: ",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Text("user_demo_123", style: TextStyle(color: Colors.grey[700])),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.event_seat, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              const Text(
                "Capacidad disponible: ",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                "${widget.event.maxAttendees - widget.event.attendees.length} lugares",
                style: TextStyle(
                  color:
                      widget.event.maxAttendees -
                              widget.event.attendees.length >
                          10
                      ? Colors.green
                      : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.blue, size: 20),
              const SizedBox(width: 8),
              const Text(
                "Fecha de reserva: ",
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                "${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}",
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        if (loading) ...[
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
        ],

        // Verificar si hay cupos disponibles
        if (widget.event.attendees.length >= widget.event.maxAttendees) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade400),
            ),
            child: const Row(
              children: [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    "¡Evento agotado! No hay más cupos disponibles.",
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],

        Row(
          children: [
            // Botón Cancelar
            Expanded(
              child: OutlinedButton(
                onPressed: loading ? null : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.grey[400]!),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "CANCELAR",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ),

            const SizedBox(width: 16),

            // Botón Confirmar
            Expanded(
              child: ElevatedButton(
                onPressed:
                    (loading ||
                        widget.event.attendees.length >=
                            widget.event.maxAttendees)
                    ? null
                    : makeBooking,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "CONFIRMAR RESERVA",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAdditionalInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info, color: Colors.blue, size: 20),
              SizedBox(width: 8),
              Text(
                "Información importante",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "• La reserva es válida hasta 30 minutos antes del evento.\n"
            "• Presenta tu código QR al ingresar al evento.\n"
            "• Cancelaciones disponibles hasta 24 horas antes.\n"
            "• Para eventos pagos, el pago se realiza en la entrada.",
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
