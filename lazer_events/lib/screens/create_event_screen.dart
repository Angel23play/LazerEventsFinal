import 'package:flutter/material.dart';
import '../models/event.dart';
import '../services/event_service.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _form = GlobalKey<FormState>();
  final _service = EventService();

  final title = TextEditingController();
  final description = TextEditingController();
  final location = TextEditingController();
  final category = TextEditingController();
  final price = TextEditingController();
  final maxAttendees = TextEditingController();
  final imageUrl = TextEditingController();

  DateTime? selectedDate;
  String? selectedCategory;

  Future<void> save() async {
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

    final event = Event(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title.text,
      description: description.text,
      date: selectedDate!,
      location: location.text,
      category: selectedCategory!,
      price: double.tryParse(price.text) ?? 0.0,
      maxAttendees: int.tryParse(maxAttendees.text) ?? 100,
      organizerId: 'current_user',
      imageUrl: imageUrl.text.isNotEmpty
          ? imageUrl.text
          : 'https://picsum.photos/400/300?random=${DateTime.now().millisecondsSinceEpoch}',
      attendees: [],
      createdAt: DateTime.now(),
    );

    try {
      await _service.addEvent(event);

      // Limpiar formulario
      title.clear();
      description.clear();
      location.clear();
      price.clear();
      maxAttendees.clear();
      imageUrl.clear();
      setState(() {
        selectedDate = null;
        selectedCategory = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Evento creado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );

      // Regresar a la lista
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
        title: const Text("Crear Nuevo Evento"),
        backgroundColor: Colors.blue.shade800,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _form,
          child: ListView(
            children: [
              // Título
              TextFormField(
                controller: title,
                decoration: const InputDecoration(
                  labelText: "Título del Evento *",
                  prefixIcon: Icon(Icons.title),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El título es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Descripción
              TextFormField(
                controller: description,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: "Descripción *",
                  prefixIcon: Icon(Icons.description),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La descripción es obligatoria';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Ubicación
              TextFormField(
                controller: location,
                decoration: const InputDecoration(
                  labelText: "Ubicación *",
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La ubicación es obligatoria';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Categoría - CORRECCIÓN AQUÍ
              DropdownButtonFormField<String>(
                initialValue: selectedCategory, // CAMBIADO: initialValue → value
                decoration: const InputDecoration(
                  labelText: "Categoría *",
                  prefixIcon: Icon(Icons.category),
                  border: OutlineInputBorder(),
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
                  setState(() {
                    selectedCategory = value;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Selecciona una categoría';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Fecha
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade50,
                  foregroundColor: Colors.blue.shade800,
                  minimumSize: const Size(double.infinity, 50),
                ),
                onPressed: () async {
                  final pick = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2035),
                  );
                  if (pick != null && mounted) {
                    setState(() => selectedDate = pick);
                  }
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 8),
                    Text(
                      selectedDate == null
                          ? "Seleccionar Fecha *"
                          : "Fecha: ${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Precio
              TextFormField(
                controller: price,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Precio (0 para gratis) *",
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa un precio (0 si es gratis)';
                  }
                  final num = double.tryParse(value);
                  if (num == null || num < 0) {
                    return 'Ingresa un número válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Capacidad
              TextFormField(
                controller: maxAttendees,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Capacidad máxima *",
                  prefixIcon: Icon(Icons.people),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa la capacidad';
                  }
                  final num = int.tryParse(value);
                  if (num == null || num <= 0) {
                    return 'Ingresa un número válido mayor a 0';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // URL de imagen
              TextFormField(
                controller: imageUrl,
                decoration: const InputDecoration(
                  labelText: "URL de imagen (opcional)",
                  prefixIcon: Icon(Icons.image),
                  border: OutlineInputBorder(),
                  hintText: "Deja vacío para imagen aleatoria",
                ),
              ),
              const SizedBox(height: 24),

              // Botón Guardar
              ElevatedButton(
                onPressed: save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade800,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "CREAR EVENTO",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),

              // Información
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: const Text(
                  '* Campos obligatorios\n'
                  'Los eventos se guardarán localmente para esta demo',
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
