# Wine App 🍷

Aplicación Flutter de gestión de vinos con Firebase Authentication.

## 🔐 Autenticación

Esta aplicación utiliza **Firebase Authentication** con soporte para:
- ✅ Correo electrónico y contraseña
- ✅ Google Sign-In
- ✅ Registro de nuevos usuarios
- ✅ Integración con Firestore para datos adicionales

## 🚀 Inicio Rápido

### 1. Instalar dependencias
```bash
flutter pub get
```

### 2. Configurar Firebase
Sigue la guía rápida en [QUICKSTART.md](QUICKSTART.md) o la guía completa en [FIREBASE_AUTH_SETUP.md](FIREBASE_AUTH_SETUP.md).

### 3. Ejecutar
```bash
flutter run
```

## 📚 Documentación

- **[QUICKSTART.md](QUICKSTART.md)** - Guía rápida de inicio (5 minutos)
- **[FIREBASE_AUTH_SETUP.md](FIREBASE_AUTH_SETUP.md)** - Guía completa de configuración

## 🏗️ Arquitectura

```
lib/
├── core/              # Configuración central (router, theme)
├── data/              # Repositorios y acceso a datos
├── domain/            # Entidades del dominio
├── presentation/      # UI y ViewModels
│   ├── screen/       # Pantallas
│   └── viewmodels/   # Lógica de presentación (Riverpod)
└── services/          # Servicios (Auth, etc.)
```

## 🔧 Tecnologías

- **Flutter** - Framework UI
- **Firebase Authentication** - Autenticación segura
- **Cloud Firestore** - Base de datos NoSQL
- **Riverpod** - Gestión de estado
- **GoRouter** - Navegación
- **Google Sign-In** - Autenticación con Google

## 📱 Características

- [x] Autenticación con email/password
- [x] Autenticación con Google
- [x] Registro de usuarios
- [x] Gestión de vinos (CRUD)
- [x] Perfil de usuario
- [x] Modo claro/oscuro
- [ ] Recuperación de contraseña
- [ ] Verificación de email

## 👥 Uso

### Registrar usuario
1. Abre la app
2. Toca "¿No tienes cuenta? Regístrate"
3. Completa el formulario
4. Toca "Registrarse"

### Iniciar sesión
**Con email:**
- Ingresa email y contraseña
- Toca "Iniciar Sesión"

**Con Google:**
- Toca "Continuar con Google"
- Selecciona tu cuenta de Google

## ⚙️ Configuración requerida

### Firebase Console
1. Habilitar Email/Password en Authentication
2. Habilitar Google Sign-In en Authentication
3. Añadir SHA-1 fingerprint para Android
4. Descargar y reemplazar `google-services.json`

Ver [FIREBASE_AUTH_SETUP.md](FIREBASE_AUTH_SETUP.md) para instrucciones detalladas.

## 🐛 Solución de problemas

Ver sección de troubleshooting en [FIREBASE_AUTH_SETUP.md](FIREBASE_AUTH_SETUP.md).

## 📄 Licencia

Este proyecto es parte del Parcial 2 de Desarrollo de Aplicaciones para Dispositivos Móviles.
