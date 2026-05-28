import 'package:flutter/material.dart';
import 'package:app_clima/services/servicio_clima.dart';

class TarjetaClima extends StatefulWidget {
  final DatosClima datos;
  const TarjetaClima({super.key, required this.datos});

  @override
  State<TarjetaClima> createState() => _TarjetaClimaState();
}

class _TarjetaClimaState extends State<TarjetaClima>
    with TickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  late Animation<double> _pulseAnim;
  late AnimationController _floatCtrl;
  late Animation<double> _floatAnim;
  bool _presionado = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut),
    );

    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  String _emoji(double t) {
    if (t < 0) return '🥶';
    if (t < 10) return '❄️';
    if (t < 20) return '🌤️';
    if (t < 30) return '☀️';
    return '🔥';
  }

  String _desc(double t) {
    if (t < 0) return 'GLACIAL';
    if (t < 10) return 'FRÍO';
    if (t < 20) return 'FRESCO';
    if (t < 30) return 'CÁLIDO';
    return 'TÓRRIDO';
  }

  @override
  Widget build(BuildContext context) {
    final temp = widget.datos.temperatura;
    final bool esOscuro = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTapDown: (_) => setState(() => _presionado = true),
      onTapUp: (_) => setState(() => _presionado = false),
      onTapCancel: () => setState(() => _presionado = false),
      child: AnimatedBuilder(
        animation: _floatCtrl,
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, _floatAnim.value),
            child: Transform.scale(
              scale: _presionado ? 0.98 : 1.0,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(35),
                child: BackdropFilter(
                  filter: ColorFilter.mode(
                    esOscuro ? Colors.black38 : Colors.white24,
                    BlendMode.srcOver,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: esOscuro
                            ? [
                                Colors.white.withValues(alpha: 0.1),
                                Colors.white.withValues(alpha: 0.03),
                              ]
                            : [
                                Colors.white.withValues(alpha: 0.75),
                                Colors.white.withValues(alpha: 0.45),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(35),
                      border: Border.all(
                        color: esOscuro ? Colors.white24 : Colors.cyan.shade100,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (temp < 15
                                  ? Colors.blueAccent
                                  : Colors.orangeAccent)
                              .withValues(alpha: _presionado ? 0.6 : 0.4),
                          blurRadius: _presionado ? 40 : 30,
                          spreadRadius: _presionado ? 12 : 8,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 28, horizontal: 22),
                      child: Column(
                        children: [
                          // Ciudad con icono
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.location_on,
                                  color: esOscuro
                                      ? Colors.white54
                                      : Colors.black54,
                                  size: 18),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  widget.datos.ciudad.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: esOscuro
                                        ? Colors.white
                                        : Colors.black87,
                                    letterSpacing: 2,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Temperatura con pulso
                          AnimatedBuilder(
                            animation: _pulseAnim,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _pulseAnim.value,
                                child: child,
                              );
                            },
                            child: Text(
                              '${temp.toStringAsFixed(1)}°',
                              style: TextStyle(
                                fontSize: 85,
                                fontWeight: FontWeight.w900,
                                foreground: Paint()
                                  ..shader = LinearGradient(
                                    colors: esOscuro
                                        ? [
                                            Colors.cyanAccent,
                                            Colors.purpleAccent
                                          ]
                                        : [Colors.cyan, Colors.blue],
                                  ).createShader(
                                      const Rect.fromLTWH(0, 0, 200, 70)),
                                shadows: [
                                  Shadow(
                                    color: Colors.cyanAccent.withValues(alpha: 0.7),
                                    blurRadius: 25,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(_emoji(temp),
                              style: const TextStyle(fontSize: 42)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 18, vertical: 6),
                            decoration: BoxDecoration(
                              color: esOscuro
                                  ? Colors.white.withValues(alpha: 0.15)
                                  : Colors.black.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _desc(temp),
                              style: TextStyle(
                                color: esOscuro
                                    ? Colors.white70
                                    : Colors.black54,
                                fontSize: 14,
                                letterSpacing: 2,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Datos extra en cápsulas
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _capsula('💧 Humedad',
                                  '${widget.datos.humedad}%', esOscuro),
                              _capsula('💨 Viento',
                                  '${widget.datos.viento} km/h', esOscuro),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _capsula(String etiqueta, String valor, bool esOscuro) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ColorFilter.mode(
          esOscuro ? Colors.white10 : Colors.black12,
          BlendMode.srcOver,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            color: esOscuro
                ? Colors.white.withValues(alpha: 0.07)
                : Colors.black.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: esOscuro ? Colors.white24 : Colors.cyan.shade100,
            ),
          ),
          child: Column(
            children: [
              Text(
                etiqueta,
                style: TextStyle(
                  color: esOscuro ? Colors.white54 : Colors.black54,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                valor,
                style: TextStyle(
                  color: esOscuro ? Colors.white : Colors.black87,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}