import 'package:flutter/material.dart';
import 'package:app_clima/services/servicio_autenticacion.dart';

class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _correoCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _servicio = ServicioAutenticacion();
  String? _mensajeError;
  bool _ocultarContrasena = true;
  bool _cargando = false;

  late final AnimationController _btnCtrl;
  late final Animation<double> _btnScale;

  @override
  void initState() {
    super.initState();
    _btnCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 150));
    _btnScale = Tween(begin: 1.0, end: 0.97).animate(
        CurvedAnimation(parent: _btnCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _correoCtrl.dispose();
    _passCtrl.dispose();
    _btnCtrl.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _mensajeError = null;
      _cargando = true;
    });
    try {
      await _servicio.crearCuenta(
        _correoCtrl.text.trim(),
        _passCtrl.text.trim(),
      );
    } catch (e) {
      setState(() {
        _mensajeError = e.toString().replaceAll('Exception: ', '');
        _cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final esOscuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: esOscuro
                ? [const Color(0xFF1A1A40), const Color(0xFF0A0E21)]
                : [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('✨', style: TextStyle(fontSize: 70)),
                    const SizedBox(height: 10),
                    Text(
                      'Crear Cuenta',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: esOscuro ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _campoTexto(
                      controlador: _correoCtrl,
                      etiqueta: 'Correo electrónico',
                      icono: Icons.email_outlined,
                      esOscuro: esOscuro,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Ingresa tu correo';
                        if (!v.contains('@')) return 'Correo inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _campoTexto(
                      controlador: _passCtrl,
                      etiqueta: 'Contraseña',
                      icono: Icons.lock_outline,
                      esOscuro: esOscuro,
                      ocultar: _ocultarContrasena,
                      sufijo: IconButton(
                        icon: Icon(
                          _ocultarContrasena
                              ? Icons.visibility_off
                              : Icons.visibility,
                          color: esOscuro ? Colors.white54 : Colors.black54,
                        ),
                        onPressed: () => setState(
                            () => _ocultarContrasena = !_ocultarContrasena),
                      ),
                      validator: (v) {
                        if (v == null || v.length < 6) {
                          return 'Mínimo 6 caracteres';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    ScaleTransition(
                      scale: _btnScale,
                      child: GestureDetector(
                        onTapDown: (_) => _btnCtrl.forward(),
                        onTapUp: (_) => _btnCtrl.reverse(),
                        child: ElevatedButton(
                          onPressed: _cargando ? null : _registrar,
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 55),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30)),
                            backgroundColor: Colors.orangeAccent.shade700,
                            disabledBackgroundColor: Colors.grey.shade600,
                          ),
                          child: _cargando
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'REGISTRARSE',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ),
                    if (_mensajeError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16),
                        child: Text(
                          _mensajeError!,
                          style: const TextStyle(
                              color: Colors.redAccent, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 20),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: RichText(
                        text: TextSpan(
                          text: '¿Ya tienes cuenta? ',
                          style: TextStyle(
                              color:
                                  esOscuro ? Colors.white70 : Colors.black54),
                          children: const [
                            TextSpan(
                              text: 'Inicia sesión',
                              style: TextStyle(
                                color: Colors.cyanAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
    bool ocultar = false,
    Widget? sufijo,
    String? Function(String?)? validator,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ColorFilter.mode(
            esOscuro ? Colors.white10 : Colors.black12, BlendMode.srcOver),
        child: Container(
          decoration: BoxDecoration(
            color: esOscuro
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.white.withValues(alpha: 0.8),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
                color: esOscuro ? Colors.white24 : Colors.cyan.shade100),
          ),
          child: TextFormField(
            controller: controlador,
            obscureText: ocultar,
            style: TextStyle(
                color: esOscuro ? Colors.white : Colors.black87, fontSize: 16),
            decoration: InputDecoration(
              labelText: etiqueta,
              labelStyle: TextStyle(
                  color: esOscuro ? Colors.white54 : Colors.black54),
              prefixIcon:
                  Icon(icono, color: esOscuro ? Colors.cyanAccent : Colors.cyan),
              suffixIcon: sufijo,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            ),
            validator: validator,
          ),
        ),
      ),
    );
  }
}