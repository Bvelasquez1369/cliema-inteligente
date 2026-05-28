import 'package:flutter/material.dart';
import 'package:app_clima/screens/autenticacion/pantalla_inicio_sesion.dart';
import 'package:app_clima/screens/pantalla_inicio.dart';
import 'package:app_clima/services/servicio_autenticacion.dart';

class PantallaSplash extends StatefulWidget {
  final ValueNotifier<bool> notificadorModoOscuro;
  final Function(bool) alCambiarTema;

  const PantallaSplash({
    super.key,
    required this.notificadorModoOscuro,
    required this.alCambiarTema,
  });

  @override
  State<PantallaSplash> createState() => _PantallaSplashState();
}

class _PantallaSplashState extends State<PantallaSplash>
    with TickerProviderStateMixin {
  final ServicioAutenticacion _servicioAuth = ServicioAutenticacion();
  late AnimationController _controladorPrincipal;
  late Animation<double> _escala;
  late Animation<double> _opacidad;

  @override
  void initState() {
    super.initState();
    _controladorPrincipal = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _escala = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _controladorPrincipal, curve: Curves.elasticOut),
    );

    _opacidad = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controladorPrincipal,
        curve: const Interval(0.2, 0.6, curve: Curves.easeIn),
      ),
    );

    _controladorPrincipal.forward();

    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) _verificarAutenticacion();
    });
  }

  void _verificarAutenticacion() {
    if (_servicioAuth.usuarioActual != null) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, _, _) => PantallaInicio(
            notificadorModoOscuro: widget.notificadorModoOscuro,
          ),
          transitionsBuilder: (_, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, _, _) => const PantallaInicioSesion(),
          transitionsBuilder: (_, animation, _, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  @override
  void dispose() {
    _controladorPrincipal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool esOscuro = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const FondoAnimado(),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScaleTransition(
                  scale: _escala,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.cyanAccent.withValues(alpha: 0.6),
                          blurRadius: 40,
                          spreadRadius: 15,
                        ),
                      ],
                    ),
                    child: const Text('🌤️', style: TextStyle(fontSize: 100)),
                  ),
                ),
                const SizedBox(height: 40),
                FadeTransition(
                  opacity: _opacidad,
                  child: ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: esOscuro
                          ? [Colors.cyanAccent, Colors.purpleAccent]
                          : [Colors.cyan, Colors.blue],
                    ).createShader(bounds),
                    child: const Text(
                      'CLIMA\nINTELIGENTE',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: 8,
                        height: 1.2,
                        shadows: [
                          Shadow(
                            color: Colors.black26,
                            offset: Offset(2, 2),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 50),
                FadeTransition(
                  opacity: _opacidad,
                  child: SizedBox(
                    height: 4,
                    width: 80,
                    child: LinearProgressIndicator(
                      backgroundColor: esOscuro
                          ? Colors.white10
                          : Colors.black12,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        esOscuro ? Colors.cyanAccent : Colors.cyan,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// FondoAnimado y _PintorFondo sin cambios
class FondoAnimado extends StatefulWidget {
  const FondoAnimado({super.key});

  @override
  State<FondoAnimado> createState() => _FondoAnimadoState();
}

class _FondoAnimadoState extends State<FondoAnimado>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool esOscuro = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) {
        return CustomPaint(
          painter: _PintorFondo(
            valorAnimacion: _controller.value,
            esOscuro: esOscuro,
          ),
        );
      },
    );
  }
}

class _PintorFondo extends CustomPainter {
  final double valorAnimacion;
  final bool esOscuro;

  _PintorFondo({required this.valorAnimacion, required this.esOscuro});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final random = List.generate(50, (i) => (i * 37.5) % 100);

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    final gradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: esOscuro
          ? [const Color(0xFF0A0E21), const Color(0xFF1A1A40)]
          : [const Color(0xFFE0F7FA), const Color(0xFFB2EBF2)],
    );
    canvas.drawRect(rect, Paint()..shader = gradient.createShader(rect));

    for (int i = 0; i < 50; i++) {
      double x = (random[i] / 100) * size.width;
      double y = ((i * 13 + valorAnimacion * 100) % size.height);
      double radio = 2.0 + (i % 3);
      paint.color = (esOscuro ? Colors.white : Colors.cyan)
          .withValues(alpha: 0.3 + (i % 5) * 0.1);
      canvas.drawCircle(Offset(x, y), radio, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _PintorFondo oldDelegate) =>
      valorAnimacion != oldDelegate.valorAnimacion || esOscuro != oldDelegate.esOscuro;
}