import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_clima/modelos/usuario.dart';
import 'package:app_clima/services/servicio_perfil.dart';

/// Pantalla de perfil como widget (sin Scaffold propio) para usar en pestañas.
class PantallaPerfil extends StatefulWidget {
  final ValueNotifier<bool> notificadorModoOscuro;
  final VoidCallback onCerrarSesion;

  const PantallaPerfil({
    super.key,
    required this.notificadorModoOscuro,
    required this.onCerrarSesion,
  });

  @override
  State<PantallaPerfil> createState() => _PantallaPerfilState();
}

class _PantallaPerfilState extends State<PantallaPerfil>
    with TickerProviderStateMixin {
  final ServicioPerfil _servicioPerfil = ServicioPerfil();
  final ImagePicker _picker = ImagePicker();
  final _nombreCtrl = TextEditingController();
  final _bioCtrl = TextEditingController();

  Usuario? _usuario;
  bool _cargando = true;
  String? _error;

  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );
    _cargarPerfil();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _nombreCtrl.dispose();
    _bioCtrl.dispose();
    super.dispose();
  }

  Future<void> _cargarPerfil() async {
    try {
      final perfil = await _servicioPerfil.obtenerPerfil();
      _nombreCtrl.text = perfil.nombre;
      _bioCtrl.text = perfil.biografia;
      setState(() {
        _usuario = perfil;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _cargando = false;
      });
    }
  }

  Future<void> _cambiarFoto() async {
    final XFile? imagen = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (imagen == null || _usuario == null) return;

    try {
      setState(() => _cargando = true);
      // Guarda la foto localmente y obtiene la ruta
      final rutaLocal = await _servicioPerfil.guardarFotoLocal(imagen);
      final nuevoUsuario = Usuario(
        uid: _usuario!.uid,
        nombre: _usuario!.nombre,
        biografia: _usuario!.biografia,
        urlFoto: rutaLocal,
      );
      setState(() {
        _usuario = nuevoUsuario;
        _cargando = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al guardar foto: $e';
        _cargando = false;
      });
    }
  }

  Future<void> _guardarCambios() async {
    if (_usuario == null) return;
    final nuevoUsuario = Usuario(
      uid: _usuario!.uid,
      nombre: _nombreCtrl.text.trim(),
      biografia: _bioCtrl.text.trim(),
      urlFoto: _usuario!.urlFoto,
    );
    try {
      setState(() => _cargando = true);
      await _servicioPerfil.actualizarPerfil(nuevoUsuario);
      setState(() {
        _usuario = nuevoUsuario;
        _cargando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil actualizado')),
      );
    } catch (e) {
      setState(() {
        _error = 'Error al guardar: $e';
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool esOscuro = Theme.of(context).brightness == Brightness.dark;

    if (_cargando && _usuario == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: esOscuro
              ? [const Color(0xFF0F2027), const Color(0xFF2C5364)]
              : [Colors.cyan.shade50, Colors.white],
        ),
      ),
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _cambiarFoto,
                child: AnimatedBuilder(
                  animation: _pulseAnim,
                  builder: (context, child) {
                    final brillo = Colors.cyanAccent
                        .withValues(alpha: 0.3 + _pulseAnim.value * 0.5);
                    return Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: brillo, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: brillo,
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: _usuario?.urlFoto != null
                            ? (_usuario!.urlFoto!.startsWith('http')
                                ? Image.network(_usuario!.urlFoto!)
                                : Image.file(File(_usuario!.urlFoto!),
                                    fit: BoxFit.cover))
                            : const Icon(Icons.person,
                                size: 70, color: Colors.white54),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Toca para cambiar foto',
                style: TextStyle(
                  color: esOscuro ? Colors.white54 : Colors.black54,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 24),
              _campoTexto(
                controlador: _nombreCtrl,
                etiqueta: 'Nombre',
                icono: Icons.person,
                esOscuro: esOscuro,
              ),
              const SizedBox(height: 16),
              _campoTexto(
                controlador: _bioCtrl,
                etiqueta: 'Biografía',
                icono: Icons.info_outline,
                esOscuro: esOscuro,
                lineasMaximas: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _cargando ? null : _guardarCambios,
                icon: _cargando
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                label: Text(_cargando ? 'Guardando...' : 'Guardar cambios'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.redAccent),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Cerrar sesión'),
                      content: const Text('¿Estás seguro?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            widget.onCerrarSesion();
                          },
                          child: const Text('Salir'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.logout),
                label: const Text('Cerrar sesión'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _campoTexto({
    required TextEditingController controlador,
    required String etiqueta,
    required IconData icono,
    required bool esOscuro,
    int lineasMaximas = 1,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ColorFilter.mode(
          esOscuro ? Colors.white10 : Colors.black12,
          BlendMode.srcOver,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: esOscuro
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: esOscuro ? Colors.white24 : Colors.cyan.shade100,
            ),
          ),
          child: TextFormField(
            controller: controlador,
            maxLines: lineasMaximas,
            style: TextStyle(
              color: esOscuro ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              labelText: etiqueta,
              labelStyle: TextStyle(
                  color: esOscuro ? Colors.white54 : Colors.black54),
              prefixIcon:
                  Icon(icono, color: esOscuro ? Colors.cyanAccent : Colors.cyan),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
          ),
        ),
      ),
    );
  }
}