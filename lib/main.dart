import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:app_clima/screens/pantalla_splash.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const AplicacionClima());
}

class AplicacionClima extends StatefulWidget {
  const AplicacionClima({super.key});

  @override
  State<AplicacionClima> createState() => _AplicacionClimaState();
}

class _AplicacionClimaState extends State<AplicacionClima> {
  final ValueNotifier<bool> _notificadorModoOscuro = ValueNotifier(false);

  void _cambiarTema(bool activado) {
    _notificadorModoOscuro.value = activado;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _notificadorModoOscuro,
      builder: (context, modoOscuro, _) {
        return MaterialApp(
          title: 'Clima Inteligente',
          debugShowCheckedModeBanner: false,
          themeMode: modoOscuro ? ThemeMode.dark : ThemeMode.light,
          theme: ThemeData(
            brightness: Brightness.light,
            scaffoldBackgroundColor: const Color(0xFFF5F9FC),
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.cyan,
              brightness: Brightness.light,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              foregroundColor: Color(0xFF1A1A2E),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 4,
                shadowColor: Colors.cyanAccent.withValues(alpha: 0.4),
              ),
            ),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            scaffoldBackgroundColor: const Color(0xFF0A0E21),
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.cyan,
              brightness: Brightness.dark,
            ),
            appBarTheme: const AppBarTheme(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              foregroundColor: Colors.white,
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                elevation: 4,
                shadowColor: Colors.cyanAccent.withValues(alpha: 0.2),
              ),
            ),
            useMaterial3: true,
          ),
          home: PantallaSplash(
            notificadorModoOscuro: _notificadorModoOscuro,
            alCambiarTema: _cambiarTema,
          ),
        );
      },
    );
  }
}
