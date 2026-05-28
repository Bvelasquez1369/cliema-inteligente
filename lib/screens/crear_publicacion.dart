import 'package:flutter/material.dart';
import 'package:app_clima/services/servicio_publicaciones.dart';

/// Pantalla para crear una publicación con comentario y datos del clima.
class PantallaCrearPublicacion extends StatefulWidget {
  const PantallaCrearPublicacion({super.key});

  @override
  State<PantallaCrearPublicacion> createState() =>
      _PantallaCrearPublicacionState();
}

class _PantallaCrearPublicacionState extends State<PantallaCrearPublicacion> {
  final _comentarioCtrl = TextEditingController();
  final _ciudadCtrl = TextEditingController();
  final _servicio = ServicioPublicaciones();
  bool _cargando = false;
  String? _error;

  Future<void> _publicar() async {
    if (_ciudadCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Ingresa la ciudad para obtener el clima');
      return;
    }

    setState(() {
      _cargando = true;
      _error = null;
    });

    try {
      await _servicio.crearPublicacion(
        ciudad: _ciudadCtrl.text.trim(),
        comentario: _comentarioCtrl.text.trim(),
        nombreAutor: 'Usuario', // Luego se obtiene del perfil real
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() {
        _error = 'Error al publicar: $e';
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nueva publicación')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _ciudadCtrl,
              decoration: const InputDecoration(
                labelText: 'Ciudad',
                prefixIcon: Icon(Icons.location_city),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _comentarioCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Comentario (opcional)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _cargando ? null : _publicar,
              icon: _cargando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              label: Text(_cargando ? 'Publicando...' : 'Publicar'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(_error!,
                    style: const TextStyle(color: Colors.redAccent)),
              ),
          ],
        ),
      ),
    );
  }
}