import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/event_provider.dart';
import '../widgets/event_card.dart';
import 'event_detail_screen.dart';
import 'create_event_screen.dart';
import '../models/event.dart'; 

class EventListScreen extends StatelessWidget {
  const EventListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => EventProvider()..loadEvents(),
      child: const _EventListBody(),
    );
  }
}

class _EventListBody extends StatefulWidget {
  const _EventListBody();

  @override
  State<_EventListBody> createState() => __EventListBodyState();
}

class __EventListBodyState extends State<_EventListBody> {
  Future<void> _refreshEvents() async {
    final provider = Provider.of<EventProvider>(context, listen: false);
    await provider.loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<EventProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("🎉 Eventos Disponibles"),
        backgroundColor: Colors.blue.shade800,
        centerTitle: true,
        elevation: 4,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 28),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateEventScreen()),
              ).then((_) {
                // FORZAR RECARGA después de crear evento
                _refreshEvents();
              });
            },
            tooltip: "Crear nuevo evento",
          ),
          IconButton(
            icon: const Icon(Icons.refresh, size: 26),
            onPressed: _refreshEvents,
            tooltip: "Actualizar eventos",
          ),
        ],
      ),
      body: provider.loading && provider.events.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _refreshEvents,
              child: provider.events.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'No hay eventos disponibles',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            '¡Crea el primer evento!',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 30),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CreateEventScreen(),
                                ),
                              ).then((_) {
                                _refreshEvents();
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue.shade800,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 30,
                                vertical: 15,
                              ),
                            ),
                            child: const Text(
                              'CREAR EVENTO',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: provider.events.length,
                      itemBuilder: (context, index) {
                        final event = provider.events[index];
                        return EventCard(
                          event: event,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => EventDetailScreen(event: event),
                              ),
                            ).then((_) {
                              _refreshEvents();
                            });
                          },
                          onDelete: () =>
                              _showDeleteDialog(context, event, provider),
                          showDeleteButton: true,
                        );
                      },
                    ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateEventScreen()),
          ).then((_) {
            _refreshEvents();
          });
        },
        backgroundColor: Colors.blue.shade800,
        foregroundColor: Colors.white,
        elevation: 6,
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  Future<void> _showDeleteDialog(
    BuildContext context,
    Event event,
    EventProvider provider,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("¿Eliminar evento?"),
        content: Text(
          "¿Estás seguro de eliminar '${event.title}'? Esta acción no se puede deshacer.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("CANCELAR"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await provider.deleteEvent(event.id);
              _refreshEvents();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text("ELIMINAR"),
          ),
        ],
      ),
    );
  }
}
