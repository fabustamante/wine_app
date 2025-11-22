# Guía de Configuración de Firebase Authentication

Esta guía te ayudará a configurar Firebase Authentication para tu aplicación Wine App con autenticación de correo/contraseña y Google Sign-In.

## Índice
1. [Configuración en Firebase Console](#1-configuración-en-firebase-console)
2. [Configuración de Android](#2-configuración-de-android)
3. [Configuración de iOS (opcional)](#3-configuración-de-ios)
4. [Instalación de dependencias](#4-instalación-de-dependencias)
5. [Migración de usuarios existentes](#5-migración-de-usuarios-existentes)
6. [Pruebas](#6-pruebas)

---

## 1. Configuración en Firebase Console

### Paso 1.1: Habilitar métodos de autenticación

1. Ve a [Firebase Console](https://console.firebase.google.com/)
2. Selecciona tu proyecto
3. En el menú lateral, ve a **Authentication** (Autenticación)
4. Haz clic en la pestaña **Sign-in method** (Método de acceso)

#### Habilitar Email/Password:
1. Haz clic en **Email/Password**
2. Activa el interruptor "Enable" (Habilitar)
3. Haz clic en **Save** (Guardar)

#### Habilitar Google Sign-In:
1. Haz clic en **Google**
2. Activa el interruptor "Enable" (Habilitar)
3. Selecciona un correo de soporte del proyecto
4. Haz clic en **Save** (Guardar)

### Paso 1.2: Configurar dominio autorizado (opcional)
Si vas a probar en web, asegúrate de que `localhost` esté en la lista de dominios autorizados (debería estar por defecto).

---

## 2. Configuración de Android

### Paso 2.1: Obtener el SHA-1 de tu aplicación

Necesitas el SHA-1 fingerprint de tu keystore para que Google Sign-In funcione en Android.

**En desarrollo (usando debug keystore):**

```bash
cd android
./gradlew signingReport
```

O directamente con keytool:

```bash
# Windows
keytool -list -v -keystore "%USERPROFILE%\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android

# Mac/Linux
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Copia el **SHA-1 fingerprint** que aparece.

### Paso 2.2: Añadir SHA-1 a Firebase

1. En Firebase Console, ve a **Project Settings** (Configuración del proyecto)
2. Desplázate hasta la sección "Your apps" (Tus aplicaciones)
3. Selecciona tu aplicación Android
4. En la sección **SHA certificate fingerprints**, haz clic en **Add fingerprint**
5. Pega el SHA-1 que copiaste
6. Haz clic en **Save**

### Paso 2.3: Descargar google-services.json actualizado

1. En Firebase Console, en **Project Settings** → Tu app Android
2. Haz clic en **Download google-services.json**
3. Reemplaza el archivo `android/app/google-services.json` con el nuevo archivo

### Paso 2.4: Verificar configuración en Android

Verifica que `android/app/build.gradle` tenga:

```gradle
dependencies {
    // ... otras dependencias
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-auth'
    implementation 'com.google.android.gms:play-services-auth:20.7.0'
}
```

Y que `android/build.gradle` tenga:

```gradle
buildscript {
    dependencies {
        classpath 'com.google.gms:google-services:4.4.0'
    }
}
```

Y en `android/app/build.gradle` al final:

```gradle
apply plugin: 'com.google.gms.google-services'
```

---

## 3. Configuración de iOS (opcional)

### Paso 3.1: Descargar GoogleService-Info.plist

1. En Firebase Console, ve a **Project Settings**
2. Selecciona tu aplicación iOS
3. Descarga **GoogleService-Info.plist**
4. Copia el archivo a `ios/Runner/GoogleService-Info.plist`

### Paso 3.2: Configurar URL Scheme

1. Abre `ios/Runner.xcworkspace` en Xcode
2. Selecciona el proyecto Runner en el navegador
3. Ve a la pestaña **Info**
4. Expande **URL Types**
5. Añade un nuevo URL Type con el **REVERSED_CLIENT_ID** de tu `GoogleService-Info.plist`

### Paso 3.3: Actualizar Info.plist

Añade en `ios/Runner/Info.plist`:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- Reemplaza con tu REVERSED_CLIENT_ID -->
            <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
        </array>
    </dict>
</array>
```

---

## 4. Instalación de dependencias

Ejecuta el siguiente comando en la raíz del proyecto:

```bash
flutter pub get
```

Las dependencias necesarias ya están añadidas en `pubspec.yaml`:
- `firebase_auth: ^5.3.3`
- `google_sign_in: ^6.2.2`

---

## 5. Migración de usuarios existentes

### Opción A: Migración manual (Recomendado)

Los usuarios existentes en Firestore deberán crear una cuenta nueva usando Firebase Authentication. Puedes:

1. Mantener los usuarios existentes en Firestore como respaldo
2. Solicitar a los usuarios que se registren nuevamente
3. Vincular los datos antiguos con los nuevos usuarios basándote en el email

### Opción B: Migración programática

Si tienes usuarios existentes con contraseñas hasheadas, puedes usar la Admin SDK de Firebase para importarlos:

```javascript
// Node.js con Firebase Admin SDK
const admin = require('firebase-admin');
admin.initializeApp();

const users = [
  {
    email: 'admin@gmail.com',
    password: 'admin123', // Debe estar hasheada apropiadamente
    displayName: 'admin'
  }
];

users.forEach(async (user) => {
  try {
    await admin.auth().createUser({
      email: user.email,
      password: user.password,
      displayName: user.displayName
    });
  } catch (error) {
    console.error('Error:', error);
  }
});
```

**⚠️ IMPORTANTE:** Nunca almacenes contraseñas en texto plano. Las contraseñas actuales en tu seed deberán ser rehash o solicitar a usuarios que creen nuevas cuentas.

### Opción C: Mantener compatibilidad temporal

El código mantiene compatibilidad con el método antiguo de autenticación. Puedes:

1. Usar Firebase Auth para nuevos usuarios
2. Mantener el flujo antiguo para usuarios legacy
3. Migrar gradualmente

---

## 6. Pruebas

### Probar Email/Password

1. Ejecuta la aplicación: `flutter run`
2. En la pantalla de login, haz clic en "¿No tienes cuenta? Regístrate"
3. Ingresa:
   - Email: `test@example.com`
   - Contraseña: `Test123!`
   - Username: `testuser`
4. Haz clic en "Registrarse"
5. Cierra sesión y vuelve a iniciar con las mismas credenciales

### Probar Google Sign-In

1. En la pantalla de login, haz clic en "Continuar con Google"
2. Selecciona una cuenta de Google
3. Autoriza la aplicación
4. Deberías ser redirigido a la pantalla principal

### Verificar en Firebase Console

1. Ve a **Authentication** → **Users**
2. Deberías ver los usuarios que creaste
3. Verifica el proveedor (Email/Password o Google)

---

## Solución de problemas comunes

### Error: "PlatformException(sign_in_failed)"

**Causa:** SHA-1 no configurado o incorrecto

**Solución:**
1. Verifica que el SHA-1 esté añadido en Firebase Console
2. Descarga el `google-services.json` actualizado
3. Limpia el proyecto: `flutter clean && flutter pub get`
4. Reconstruye: `flutter run`

### Error: "A network error occurred"

**Causa:** Firebase no inicializado o configuración incorrecta

**Solución:**
1. Verifica que `google-services.json` esté en `android/app/`
2. Verifica que Firebase esté inicializado en `main.dart`
3. Comprueba tu conexión a internet

### Error: "The email address is badly formatted"

**Causa:** Email inválido

**Solución:** Asegúrate de usar un formato de email válido (ej: `user@example.com`)

### Google Sign-In no funciona en release

**Causa:** Falta el SHA-1 del release keystore

**Solución:**
1. Obtén el SHA-1 de tu release keystore
2. Añádelo en Firebase Console junto al debug SHA-1

---

## Arquitectura implementada

### Estructura de archivos:

```
lib/
├── services/
│   ├── firebase_auth_service.dart    # Servicio principal de Firebase Auth
│   └── auth_service.dart              # Servicio legacy (deprecated)
├── presentation/
│   ├── viewmodels/
│   │   └── auth_viewmodel.dart        # ViewModel con Riverpod
│   └── screen/
│       └── login.dart                 # Pantalla de login actualizada
```

### Flujo de autenticación:

1. **Usuario interactúa** con `LoginScreen`
2. **LoginScreen** llama a `AuthNotifier` (ViewModel)
3. **AuthNotifier** usa `FirebaseAuthService`
4. **FirebaseAuthService** interactúa con Firebase Auth
5. Al autenticarse, también se guarda/obtiene info en Firestore
6. El estado se actualiza en `AuthStatus` y la UI reacciona

### Datos guardados en Firestore:

Cuando un usuario se autentica, se crea/actualiza un documento en `users/{uid}`:

```json
{
  "id": 123456,
  "username": "johndoe",
  "email": "john@example.com",
  "age": 25,
  "avatarPath": "https://...",
  "createdAt": "Timestamp"
}
```

---

## Próximos pasos recomendados

1. **Implementar recuperación de contraseña:**
   ```dart
   await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
   ```

2. **Añadir verificación de email:**
   ```dart
   await user.sendEmailVerification();
   ```

3. **Implementar sign-out en toda la app:**
   - Actualizar ProfileScreen para usar el nuevo signOut
   - Añadir confirmación antes de cerrar sesión

4. **Proteger rutas:**
   - Implementar guards en GoRouter
   - Redirigir a /login si no está autenticado

5. **Manejo de errores mejorado:**
   - Mostrar mensajes más específicos
   - Implementar retry logic

---

## Referencias

- [Firebase Authentication Docs](https://firebase.google.com/docs/auth)
- [FlutterFire Auth Package](https://pub.dev/packages/firebase_auth)
- [Google Sign-In Package](https://pub.dev/packages/google_sign_in)
- [Firebase Console](https://console.firebase.google.com/)

---

**✅ Implementación completada**

Tu aplicación ahora usa Firebase Authentication con:
- ✅ Autenticación con Email/Password
- ✅ Autenticación con Google
- ✅ Registro de nuevos usuarios
- ✅ Integración con Firestore para datos adicionales
- ✅ Arquitectura limpia con Riverpod
