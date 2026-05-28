import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app_clima/services/servicio_clima.dart';
import 'package:app_clima/services/servicio_autenticacion.dart';
import 'package:app_clima/widgets/tarjeta_clima.dart';
import 'package:app_clima/widgets/tarjeta_pronostico.dart';
import 'package:app_clima/screens/autenticacion/pantalla_inicio_sesion.dart';
import 'package:app_clima/screens/perfil/pantalla_perfil.dart';
import 'package:app_clima/screens/feed_screen.dart';

class PantallaInicio extends StatefulWidget {
  final ValueNotifier<bool> notificadorModoOscuro;

  const PantallaInicio({super.key, required this.notificadorModoOscuro});

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  int _indiceActual = 1; // 0: Publicaciones, 1: Clima, 2: Perfil

  final _controladorCiudad = TextEditingController();
  final _servicioClima = ServicioClima();
  final _servicioAuth = ServicioAutenticacion();

  DatosClima? _datosClima;
  List<DiaPronostico> _pronostico = [];
  String _mensajeError = '';
  bool _estaCargando = false;
  final List<String> _historial = [];

  Color get _colorFondo {
    if (_datosClima == null) return Theme.of(context).scaffoldBackgroundColor;
    final t = _datosClima!.temperatura;
    if (t < 0) return const Color(0xFF1A237E);
    if (t < 10) return const Color(0xFF0D47A1);
    if (t < 20) return const Color(0xFF006064);
    if (t < 30) return const Color(0xFF1B5E20);
    return const Color(0xFFBF360C);
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _controladorCiudad.dispose();
    super.dispose();
  }

  Future<void> _buscarClima([String? ciudadDirecta]) async {
    final ciudad = ciudadDirecta ?? _controladorCiudad.text.trim();
    if (ciudad.isEmpty) {
      setState(() => _mensajeError = '🌍 Por favor escribe una ciudad');
      return;
    }

    setState(() {
      _estaCargando = true;
      _mensajeError = '';
      _datosClima = null;
      _pronostico = [];
      if (ciudadDirecta != null) _controladorCiudad.text = ciudadDirecta;
    });

    try {
      final resultados = await Future.wait([
        _servicioClima.obtenerClima(ciudad),
        _servicioClima.obtenerPronostico7Dias(ciudad),
      ]);
      final datos = resultados[0] as DatosClima;
      final pronostico = resultados[1] as List<DiaPronostico>;

      if (!_historial.contains(datos.ciudad)) {
        _historial.insert(0, datos.ciudad);
        if (_historial.length > 5) _historial.removeLast();
      }

      setState(() {
        _datosClima = datos;
        _pronostico = pronostico;
        _estaCargando = false;
      });
    } catch (e) {
      setState(() {
        _mensajeError = '❌ ${e.toString().replaceAll('Exception: ', '')}';
        _estaCargando = false;
      });
    }
  }

  Future<void> _cerrarSesion() async {
    await _servicioAuth.cerrarSesion();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const PantallaInicioSesion()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: widget.notificadorModoOscuro,
      builder: (context, modoOscuro, _) {
        final bool esOscuro = modoOscuro;
        final User? usuario = _servicioAuth.usuarioActual;

        final List<Widget> pantallas = [
          const PantallaFeed(),
          _construirPantallaClima(esOscuro),
          PantallaPerfil(
            notificadorModoOscuro: widget.notificadorModoOscuro,
            onCerrarSesion: _cerrarSesion,
          ),
        ];

        return Scaffold(
          body: pantallas[_indiceActual],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _indiceActual,
            onTap: (index) => setState(() => _indiceActual = index),
            selectedItemColor: Colors.cyanAccent,
            unselectedItemColor: Colors.grey,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.post_add),
                label: 'Publicaciones',
              ),
              BottomNavigationBarItem(icon: Icon(Icons.cloud), label: 'Clima'),
              BottomNavigationBarItem(
                icon: Icon(Icons.person),
                label: 'Perfil',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _construirPantallaClima(bool esOscuro) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🌤️', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Text(
              'CLIMA INTELIGENTE',
              style: TextStyle(
                letterSpacing: 3,
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: Theme.of(context).appBarTheme.foregroundColor,
              ),
            ),
          ],
        ),
        actions: [
          Row(
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  esOscuro ? Icons.nightlight_round : Icons.wb_sunny,
                  key: ValueKey(esOscuro),
                  color: esOscuro ? Colors.amber : Colors.orange,
                  size: 22,
                ),
              ),
              Switch(
                value: esOscuro,
                activeThumbColor: Colors.cyanAccent,
                onChanged: (valor) =>
                    widget.notificadorModoOscuro.value = valor,
              ),
            ],
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: esOscuro
                ? [_colorFondo, const Color(0xFF121212)]
                : [_colorFondo.withValues(alpha: 0.05), Colors.white],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            color: Colors.cyanAccent,
            backgroundColor: esOscuro ? Colors.black : Colors.white,
            onRefresh: () => _buscarClima(_controladorCiudad.text.trim()),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  _construirBarraBusqueda(esOscuro),
                  const SizedBox(height: 12),
                  if (_historial.isNotEmpty) _construirHistorial(esOscuro),
                  const SizedBox(height: 20),
                  if (_estaCargando) _construirCargaAnimada(esOscuro),
                  if (_mensajeError.isNotEmpty) _construirError(esOscuro),
                  if (_datosClima != null) ...[
                    TarjetaClima(datos: _datosClima!),
                    const SizedBox(height: 20),
                  ],
                  if (_pronostico.isNotEmpty)
                    TarjetaPronostico(
                      pronostico: _pronostico,
                      modoOscuro: esOscuro,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Los métodos _construirBarraBusqueda, _construirHistorial, etc. se mantienen exactamente igual que antes
  Widget _construirBarraBusqueda(bool esOscuro) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ColorFilter.mode(
          esOscuro ? Colors.white10 : Colors.black12,
          BlendMode.srcOver,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: esOscuro
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: esOscuro ? Colors.white24 : Colors.cyan.shade200,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: (esOscuro ? Colors.cyanAccent : Colors.cyan).withValues(
                  alpha: 0.3,
                ),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: TextField(
            controller: _controladorCiudad,
            style: TextStyle(
              color: esOscuro ? Colors.white : Colors.black87,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: '🌍 Buscar ciudad...',
              hintStyle: TextStyle(
                color: esOscuro ? Colors.white38 : Colors.black38,
                fontStyle: FontStyle.italic,
              ),
              prefixIcon: Icon(
                Icons.location_on_rounded,
                color: esOscuro ? Colors.cyanAccent : Colors.cyan,
              ),
              suffixIcon: _controladorCiudad.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear_rounded,
                        color: esOscuro ? Colors.white54 : Colors.black54,
                      ),
                      onPressed: () {
                        setState(() {
                          _controladorCiudad.clear();
                          _datosClima = null;
                          _pronostico = [];
                          _mensajeError = '';
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
            ),
            onSubmitted: (_) => _buscarClima(),
          ),
        ),
      ),
    );
  }

  Widget _construirHistorial(bool esOscuro) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _historial.map((ciudad) {
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: GestureDetector(
              onTap: () => _buscarClima(ciudad),
              child: Chip(
                avatar: Icon(
                  Icons.history,
                  size: 16,
                  color: esOscuro ? Colors.cyanAccent : Colors.cyan,
                ),
                label: Text(
                  ciudad,
                  style: TextStyle(
                    color: esOscuro ? Colors.white70 : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                backgroundColor: esOscuro
                    ? Colors.white.withValues(alpha: 0.1)
                    : Colors.black.withValues(alpha: 0.05),
                side: BorderSide(
                  color: esOscuro
                      ? Colors.cyanAccent.withValues(alpha: 0.4)
                      : Colors.cyan.withValues(alpha: 0.6),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _construirCargaAnimada(bool esOscuro) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 50),
      child: Column(
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              color: Colors.cyanAccent,
            ),
          ),
          SizedBox(height: 20),
          Text(
            '⏳ Analizando atmósfera...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _construirError(bool esOscuro) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ColorFilter.mode(
          esOscuro ? Colors.red.shade900 : Colors.red.shade100,
          BlendMode.srcOver,
        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (esOscuro ? Colors.red : Colors.red).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Colors.redAccent,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _mensajeError,
                  style: TextStyle(
                    color: esOscuro ? Colors.white : Colors.red.shade900,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
