# 🌤️ App Clima - Weather & Social Feed

Una aplicación Flutter que combina pronósticos de clima en tiempo real con una red social para compartir observaciones meteorológicas.

## ✨ Características

- 🌍 **Búsqueda de Clima** - Obtén información meteorológica actual de cualquier ciudad
- 📅 **Pronóstico 7 días** - Visualiza el pronóstico extendido
- 📱 **Feed Social** - Publica y comparte observaciones climáticas con otros usuarios
- 👥 **Perfiles de Usuario** - Gestiona tu perfil y foto
- ❤️ **Sistema de Likes** - Interactúa con publicaciones de otros usuarios
- 🌙 **Modo Oscuro** - Interfaz adaptable a preferencias visuales
- 🔐 **Autenticación Firebase** - Login seguro con correo

## 🚀 Inicio Rápido

### Requisitos

- Flutter 3.12+
- Dart 3.12+
- Un proyecto Firebase configurado

### Instalación

1. **Clona el repositorio**

   ```bash
   git clone <repo-url>
   cd app_clima
   ```

2. **Instala dependencias**

   ```bash
   flutter pub get
   ```

3. **Configura Firebase**
   - Copia `lib/firebase_options.dart.example` a `lib/firebase_options.dart`
   - Reemplaza con tus credenciales de Firebase
   - Configura Firestore y Authentication en tu proyecto Firebase

4. **Ejecuta la app**
   ```bash
   flutter run
   ```

## 📚 Estructura del Proyecto

```
lib/
├── main.dart                 # Punto de entrada
├── screens/
│   ├── pantalla_inicio.dart      # Navegación principal
│   ├── feed_screen.dart          # Pantalla de publicaciones
│   ├── crear_publicacion.dart    # Crear posts
│   ├── perfil/                   # Gestión de perfil
│   └── autenticacion/            # Login/Registro
├── services/
│   ├── servicio_clima.dart       # API de clima
│   ├── servicio_autenticacion.dart
│   ├── servicio_publicaciones.dart
│   └── servicio_perfil.dart
├── modelos/
│   ├── publicacion.dart
│   └── usuario.dart
└── widgets/
    ├── tarjeta_clima.dart
    └── tarjeta_pronostico.dart
```

## 🔧 Dependencias Principales

- **firebase_auth** - Autenticación
- **cloud_firestore** - Base de datos
- **firebase_storage** - Almacenamiento de archivos
- **http** - Peticiones HTTP (API de clima)
- **image_picker** - Selección de imágenes
- **shared_preferences** - Preferencias locales

## 📝 Notas de Desarrollo

- Modo de navegación: Bottom Navigation Bar (3 tabs: Publicaciones, Clima, Perfil)
- API de Clima: OpenWeatherMap (configura tu API key en `servicio_clima.dart`)
- Base de datos: Firestore con colecciones `publicaciones` y `usuarios`

## 🤝 Contribuciones

Este es un proyecto educativo. Siéntete libre de hacer fork y contribuir.

## 📄 Licencia

MIT

## 👨‍💻 Autor

Proyecto Flutter personal

---

**¿Preguntas o problemas?** Crea un issue en el repositorio.
