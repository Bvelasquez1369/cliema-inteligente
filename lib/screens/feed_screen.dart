import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app_clima/modelos/publicacion.dart';
import 'package:app_clima/screens/crear_publicacion.dart';
import 'package:app_clima/services/servicio_publicaciones.dart';

/// Pantalla de feed con todas las publicaciones.
class PantallaFeed extends StatelessWidget {
  const PantallaFeed({super.key});

  @override
  Widget build(BuildContext context) {
    final servicio = ServicioPublicaciones();
    final User? usuario = FirebaseAuth.instance.currentUser;
    final bool esOscuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicaciones Climáticas'),
        automaticallyImplyLeading: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PantallaCrearPublicacion()),
          );
        },
        icon: const Icon(Icons.add_comment),
        label: const Text('Publicar'),
        backgroundColor: Colors.cyanAccent.shade700,
      ),
      body: StreamBuilder<List<Publicacion>>(
        stream: servicio.obtenerPublicaciones(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final publicaciones = snapshot.data!;
          if (publicaciones.isEmpty) {
            return const Center(
              child: Text('No hay publicaciones aún. ¡Sé el primero!'),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: publicaciones.length,
            itemBuilder: (context, index) {
              return _tarjetaPublicacion(
                publicaciones[index],
                esOscuro,
                usuario,
                servicio,
              );
            },
          );
        },
      ),
    );
  }

  Widget _tarjetaPublicacion(
    Publicacion pub,
    bool esOscuro,
    User? usuario,
    ServicioPublicaciones servicio,
  ) {
    final bool dioLike = usuario != null && pub.likes.contains(usuario.uid);

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  child: Text(pub.nombreAutor[0].toUpperCase()),
                ),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pub.nombreAutor,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _formatearFecha(pub.fecha),
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
            if (pub.comentario != null && pub.comentario!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(pub.comentario!),
              ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _datoClima('${pub.temperatura.toStringAsFixed(1)}°C', '🌡️'),
                _datoClima('${pub.viento.toStringAsFixed(1)} km/h', '💨'),
                _datoClima('${pub.humedad}%', '💧'),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                GestureDetector(
                  onTap: () => servicio.toggleLike(pub.id),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      dioLike ? Icons.favorite : Icons.favorite_border,
                      key: ValueKey(dioLike),
                      color: dioLike ? Colors.red : Colors.grey,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text('${pub.likes.length}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _datoClima(String valor, String emoji) {
    return Row(
      children: [
        Text(emoji, style: const TextStyle(fontSize: 18)),
        const SizedBox(width: 4),
        Text(
          valor,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  String _formatearFecha(DateTime fecha) {
    return '${fecha.day}/${fecha.month}/${fecha.year}';
  }
}
