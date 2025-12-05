import 'package:flutter/material.dart';
import '../../models/event.dart';
import '../../services/event_service.dart';

class EditEventScreen extends StatefulWidget {
  final Event event;

  const EditEventScreen({super.key, required this.event});

  @override
  State<EditEventScreen> createState() => _EditEventScreenState();
}

class _EditEventScreenState extends State<EditEventScreen> {
  final _form = GlobalKey<FormState>();
  final _service = EventService();

  late TextEditingController title;
  late TextEditingController description;
  late TextEditingController location;
  late TextEditingController price;
  late TextEditingController maxAttendees;
  late TextEditingController imageUrl;

  DateTime? selectedDate;
  String? selectedCategory;

  @override
  void initState() {
    super.initState();

    // Inicializar controladores con los valores del evento
    title = TextEditingController(text: widget.event.title);
    description = TextEditingController(text: widget.event.description);
    location = TextEditingController(text: widget.event.location);
    price = TextEditingController(text: widget.event.price.toString());
    maxAttendees = TextEditingController(
      text: widget.event.maxAttendees.toString(),
    );
    imageUrl = TextEditingController(text: widget.event.imageUrl);

    selectedDate = widget.event.date;
    selectedCategory = widget.event.category;
  }

  Future<void> update() async {
    if (!_form.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Completa todos los campos')),
      );
      return;
    }

    if (selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('❌ Selecciona una fecha')));
      return;
    }

    if (selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Selecciona una categoría')),
      );
      return;
    }

    final updated = Event(
      id: widget.event.id,
      title: title.text,
      description: description.text,
      location: location.text,
      category: selectedCategory!,
      date: selectedDate!,
      price: double.tryParse(price.text) ?? 0.0,
      maxAttendees: int.tryParse(maxAttendees.text) ?? 0,
      imageUrl: imageUrl.text.isEmpty ? widget.event.imageUrl : imageUrl.text,
      attendees: widget.event.attendees, 
      organizerId: widget.event.organizerId, 
      createdAt: widget.event.createdAt,

    );

    try {
      await _service.updateEvent(updated);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Evento actualizado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Editar Evento",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.orange.shade800,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              TextFormField(
                controller: title,
                decoration: const InputDecoration(
                  labelText: "Título del Evento *",
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'El título es obligatorio' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: description,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Descripción *",
                  prefixIcon: Icon(Icons.description),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'La descripción es obligatoria' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: location,
                decoration: const InputDecoration(
                  labelText: "Ubicación *",
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'La ubicación es obligatoria' : null,
              ),
              const SizedBox(height: 16),

              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(
                  labelText: "Categoría *",
                  prefixIcon: Icon(Icons.category),
                ),
                items: const [
                  DropdownMenuItem(value: 'Música', child: Text('Música')),
                  DropdownMenuItem(value: 'Deportes', child: Text('Deportes')),
                  DropdownMenuItem(
                    value: 'Educación',
                    child: Text('Educación'),
                  ),
                  DropdownMenuItem(value: 'Negocios', child: Text('Negocios')),
                  DropdownMenuItem(value: 'Arte', child: Text('Arte')),
                  DropdownMenuItem(
                    value: 'Tecnología',
                    child: Text('Tecnología'),
                  ),
                  DropdownMenuItem(value: 'Otro', child: Text('Otro')),
                ],
                onChanged: (value) {
                  setState(() => selectedCategory = value);
                },
                validator: (value) =>
                    value == null ? 'Selecciona una categoría' : null,
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () async {
                  final pick = await showDatePicker(
                    context: context,
                    initialDate: selectedDate ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2035),
                  );
                  if (pick != null) {
                    setState(() => selectedDate = pick);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade50,
                  foregroundColor: Colors.orange.shade800,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 8),
                    Text(
                      "Fecha: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: price,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Precio *",
                  prefixIcon: Icon(Icons.attach_money),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Ingresa un precio' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: maxAttendees,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Capacidad máxima *",
                  prefixIcon: Icon(Icons.people),
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Ingresa la capacidad' : null,
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: imageUrl,
                decoration: const InputDecoration(
                  labelText: "URL de Imagen",
                  prefixIcon: Icon(Icons.image),
                ),
              ),
              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: update,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade800,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text(
                  "ACTUALIZAR EVENTO",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
