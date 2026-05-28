import 'package:http/http.dart' as http;
import 'dart:convert';

// Caja que agrupa los datos del clima actual
class DatosClima {
  final String ciudad;
  final double temperatura;
  final double viento;
  final int humedad;

  DatosClima({
    required this.ciudad,
    required this.temperatura,
    required this.viento,
    required this.humedad,
  });
}

// Caja para cada día del pronóstico
class DiaPronostico {
  final String dia;
  final double tempMaxima;
  final double tempMinima;
  final int codigoClima;

  DiaPronostico({
    required this.dia,
    required this.tempMaxima,
    required this.tempMinima,
    required this.codigoClima,
  });
}

// Servicio que habla con la API de Open-Meteo
class ServicioClima {
  static const List<String> _diasSemana = [
    'Lunes', 'Martes', 'Miércoles', 'Jueves',
    'Viernes', 'Sábado', 'Domingo',
  ];

  // Obtiene latitud y longitud a partir del nombre de la ciudad
  Future<Map<String, dynamic>> obtenerCoordenadas(String nombreCiudad) async {
    final url = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search'
      '?name=$nombreCiudad&count=1&language=es&format=json',
    );
    final respuesta = await http.get(url);
    if (respuesta.statusCode != 200) {
      throw Exception('Error al conectar con el servidor (${respuesta.statusCode})');
    }
    final datos = json.decode(respuesta.body);
    if (datos['results'] == null || datos['results'].isEmpty) {
      throw Exception('Ciudad no encontrada. Verifica el nombre.');
    }
    return {
      'latitud': datos['results'][0]['latitude'],
      'longitud': datos['results'][0]['longitude'],
      'nombre': datos['results'][0]['name'],
    };
  }

  // Obtiene el clima actual y la humedad
  Future<DatosClima> obtenerClima(String nombreCiudad) async {
    final coords = await obtenerCoordenadas(nombreCiudad);
    final lat = coords['latitud'];
    final lon = coords['longitud'];
    final ciudad = coords['nombre'];

    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$lat&longitude=$lon'
      '&current_weather=true'
      '&hourly=relativehumidity_2m'
      '&timezone=auto',
    );
    final respuesta = await http.get(url);
    if (respuesta.statusCode != 200) {
      throw Exception('Error al obtener el clima (${respuesta.statusCode})');
    }
    final datos = json.decode(respuesta.body);
    final climaActual = datos['current_weather'];

    int humedad = 0;
    if (datos['hourly'] != null &&
        datos['hourly']['relativehumidity_2m'] != null &&
        datos['hourly']['relativehumidity_2m'].isNotEmpty) {
      humedad = datos['hourly']['relativehumidity_2m'][0];
    }

    return DatosClima(
      ciudad: ciudad,
      temperatura: climaActual['temperature'].toDouble(),
      viento: climaActual['windspeed'].toDouble(),
      humedad: humedad,
    );
  }

  // Obtiene el pronóstico de los próximos 7 días
  Future<List<DiaPronostico>> obtenerPronostico7Dias(String nombreCiudad) async {
    final coords = await obtenerCoordenadas(nombreCiudad);
    final lat = coords['latitud'];
    final lon = coords['longitud'];

    final url = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$lat&longitude=$lon'
      '&daily=temperature_2m_max,temperature_2m_min,weathercode'
      '&timezone=auto',
    );
    final respuesta = await http.get(url);
    if (respuesta.statusCode != 200) {
      throw Exception('Error al obtener el pronóstico (${respuesta.statusCode})');
    }
    final datos = json.decode(respuesta.body);
    final diario = datos['daily'];

    List<DiaPronostico> pronostico = [];
    for (int i = 0; i < 7; i++) {
      final fecha = DateTime.parse(diario['time'][i]);
      final nombreDia = i == 0 ? 'Hoy' : i == 1 ? 'Mañana' : _diasSemana[fecha.weekday - 1];
      pronostico.add(DiaPronostico(
        dia: nombreDia,
        tempMaxima: diario['temperature_2m_max'][i].toDouble(),
        tempMinima: diario['temperature_2m_min'][i].toDouble(),
        codigoClima: diario['weathercode'][i],
      ));
    }
    return pronostico;
  }
}