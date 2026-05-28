import 'package:flutter/material.dart';
import 'package:app_clima/services/servicio_clima.dart';

class TarjetaPronostico extends StatelessWidget {
  final List<DiaPronostico> pronostico;
  final bool modoOscuro;

  const TarjetaPronostico({
    super.key,
    required this.pronostico,
    required this.modoOscuro,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ColorFilter.mode(
          modoOscuro ? Colors.white10 : Colors.black12,
          BlendMode.srcOver,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: modoOscuro
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.white.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: modoOscuro ? Colors.white24 : Colors.cyan.shade100,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: (modoOscuro ? Colors.cyanAccent : Colors.cyan)
                    .withValues(alpha: 0.2),
                blurRadius: 25,
                spreadRadius: 4,
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('📅', style: TextStyle(fontSize: 22)),
                  SizedBox(width: 10),
                  Text(
                    'PRONÓSTICO',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Center(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children:
                        pronostico.asMap().entries.map((entry) {
                      return _tarjetaDia(entry.value, entry.key == 0);
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tarjetaDia(DiaPronostico dia, bool esHoy) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: 16),
      decoration: esHoy
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: modoOscuro ? Colors.cyanAccent : Colors.cyan,
                width: 1.5,
              ),
              color: (modoOscuro ? Colors.cyanAccent : Colors.cyan)
                  .withValues(alpha: 0.1),
            )
          : null,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Text(
            dia.dia.substring(0, 3).toUpperCase(),
            style: TextStyle(
              color: esHoy
                  ? (modoOscuro ? Colors.cyanAccent : Colors.cyan)
                  : (modoOscuro ? Colors.white70 : Colors.black54),
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _emoji(dia.codigoClima),
            style: const TextStyle(fontSize: 32),
          ),
          const SizedBox(height: 6),
          Text(
            '${dia.tempMinima.round()}°',
            style: TextStyle(
              color: modoOscuro ? Colors.blue.shade200 : Colors.blue.shade700,
              fontSize: 13,
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 4),
            height: 3,
            width: 45,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: LinearGradient(
                colors: [
                  modoOscuro ? Colors.blue.shade200 : Colors.blue.shade400,
                  modoOscuro
                      ? Colors.orange.shade200
                      : Colors.orange.shade400,
                ],
              ),
            ),
          ),
          Text(
            '${dia.tempMaxima.round()}°',
            style: TextStyle(
              color: modoOscuro
                  ? Colors.orangeAccent
                  : Colors.orange.shade700,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  String _emoji(int code) {
    if (code == 0) return '☀️';
    if (code <= 3) return '⛅';
    if (code <= 49) return '🌫️';
    if (code <= 59) return '🌦️';
    if (code <= 69) return '🌧️';
    if (code <= 79) return '🌨️';
    return '⛈️';
  }
}