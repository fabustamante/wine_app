# 🚀 Guía Rápida: Firebase Authentication

## Inicio Rápido (5 minutos)

### 1. Instalar dependencias
```bash
flutter pub get
```

### 2. Configurar Firebase Console

#### a) Habilitar Email/Password
1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto
3. **Authentication** → **Sign-in method** → **Email/Password**
4. Activa y guarda

#### b) Habilitar Google Sign-In
1. En la misma pantalla de **Sign-in method**
2. Selecciona **Google**
3. Activa, selecciona email de soporte y guarda

### 3. Configurar Android

#### Obtener SHA-1:
```bash
cd android
gradlew signingReport
```

Copia el SHA-1 que aparece en consola.

#### Añadir a Firebase:
1. **Firebase Console** → **Project Settings** → Tu app Android
2. **Add fingerprint** → Pega el SHA-1
3. Descarga el nuevo `google-services.json`
4. Reemplaza `android/app/google-services.json`

### 4. Ejecutar
```bash
flutter run
```

---

## 📖 Cómo usar

### Registrar nuevo usuario
1. Abre la app
2. Clic en "¿No tienes cuenta? Regístrate"
3. Ingresa email, contraseña, username
4. Clic en "Registrarse"

### Iniciar sesión con Email
1. Ingresa email y contraseña
2. Clic en "Iniciar Sesión"

### Iniciar sesión con Google
1. Clic en "Continuar con Google"
2. Selecciona cuenta
3. Autoriza

---

## 🔧 Métodos disponibles

### En cualquier pantalla con Riverpod:

```dart
// Obtener instancia del notificador
final authNotifier = ref.read(authProvider.notifier);

// Login con email/password
await authNotifier.signInWithEmailAndPassword(email, password);

// Login con Google
await authNotifier.signInWithGoogle();

// Registro
await authNotifier.signUpWithEmailAndPassword(
  email: email,
  password: password,
  username: username,
  age: age,
);

// Logout
await authNotifier.signOut();

// Verificar si está autenticado
final authStatus = ref.watch(authProvider);
if (authStatus.isAuthenticated) {
  // Usuario autenticado
  final user = authStatus.user;
}
```

---

## 📁 Archivos modificados

✅ **Nuevos:**
- `lib/services/firebase_auth_service.dart` - Servicio principal
- `FIREBASE_AUTH_SETUP.md` - Guía completa
- `QUICKSTART.md` - Esta guía

✅ **Modificados:**
- `pubspec.yaml` - Dependencias añadidas
- `lib/presentation/viewmodels/auth_viewmodel.dart` - Refactorizado
- `lib/presentation/screen/login.dart` - UI actualizada
- `lib/services/auth_service.dart` - Actualizado (legacy)

---

## ⚠️ Importante

### Usuarios existentes
Los usuarios creados con el método antiguo (username/password en Firestore) **NO funcionarán** con Firebase Auth. Deberán:
- Registrarse nuevamente con Firebase Auth, o
- Migrar sus cuentas manualmente (ver guía completa)

### Diferencias clave
| Antes | Ahora |
|-------|-------|
| Username + Password | Email + Password |
| Búsqueda en Firestore | Firebase Authentication |
| Contraseñas en Firestore | Contraseñas en Firebase Auth (seguro) |
| Solo local | Cloud-ready |

---

## 🆘 Problemas comunes

### "PlatformException(sign_in_failed)"
→ SHA-1 no configurado. Revisa el paso 3.

### "A network error occurred"
→ `google-services.json` faltante o Firebase no inicializado.

### Google Sign-In no aparece
→ Verifica que esté habilitado en Firebase Console.

### "The email address is badly formatted"
→ Usa formato válido: `user@example.com`

---

## 📚 Documentación completa

Para configuración detallada, troubleshooting avanzado y mejores prácticas, consulta:
- **FIREBASE_AUTH_SETUP.md** - Guía completa paso a paso

---

## 🎯 Próximos pasos recomendados

1. ✅ Configurar recuperación de contraseña
2. ✅ Implementar verificación de email
3. ✅ Añadir guards a las rutas (proteger /wines, /profile)
4. ✅ Mejorar manejo de errores
5. ✅ Implementar "Remember me"
6. ✅ Añadir más proveedores (Facebook, Apple, etc.)

---

**¿Listo?** Ejecuta `flutter pub get` y `flutter run` 🚀
