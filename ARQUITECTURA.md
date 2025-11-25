# 📐 Arquitectura del Proyecto - Wine App

## 🏛️ Patrón Arquitectónico: MVVM (Model-View-ViewModel)

Este proyecto implementa el patrón **MVVM** con las siguientes responsabilidades bien definidas:

- **Model (Modelo)**: Entidades de dominio y lógica de negocio
- **View (Vista)**: Interfaz de usuario (widgets de Flutter)
- **ViewModel**: Gestión de estado y lógica de presentación

### Diagrama de Flujo de Datos

```
┌─────────────────────────────────────────────────────────────────┐
│                           USER INTERACTION                       │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│  VIEW (Presentation Layer)                                       │
│  • Screens (login.dart, wine_screen.dart, profile.dart)         │
│  • Components (drawer_menu.dart)                                │
│  • Solo renderiza UI, no contiene lógica de negocio             │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│  VIEWMODEL (State Management)                                    │
│  • auth_viewmodel.dart - Estado de autenticación                │
│  • wines_viewmodel.dart - Estado de lista de vinos              │
│  • add_edit_wine_viewmodel.dart - Estado de formulario          │
│  • profile_viewmodel.dart - Estado de perfil                    │
│  • Gestiona estado con Riverpod (Notifier/AsyncNotifier)        │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│  SERVICES (Business Logic)                                       │
│  • auth_service.dart - Autenticación                            │
│  • firebase_storage_service.dart - Almacenamiento de imágenes   │
│  • wine_image_analysis_service.dart - IA con Gemini             │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│  DATA LAYER (Repositories)                                       │
│  • wines_repository_firestore.dart - CRUD de vinos              │
│  • users_repository_firestore.dart - CRUD de usuarios           │
│  • Implementan interfaces del dominio                            │
└────────────────────────────┬────────────────────────────────────┘
                             │
                             ▼
┌─────────────────────────────────────────────────────────────────┐
│  EXTERNAL SERVICES                                               │
│  • Firebase Auth - Autenticación                                │
│  • Cloud Firestore - Base de datos NoSQL                        │
│  • Firebase Storage - Almacenamiento de archivos                │
│  • Google Gemini AI - Reconocimiento de imágenes                │
└─────────────────────────────────────────────────────────────────┘
```

---

## 📂 Estructura de Carpetas y Responsabilidades

```
lib/
├── config/              # Configuración
│   └── api_keys.dart    # API keys (Gemini AI)
│
├── core/                # Núcleo de la aplicación
│   ├── menu/            # Definición de menú
│   │   └── menu_item.dart
│   ├── router/          # Navegación
│   │   └── app_router.dart
│   └── theme/           # Temas y estilos
│       ├── app_theme.dart
│       └── theme_provider.dart
│
├── domain/              # MODELO - Entidades de negocio
│   ├── repositories/    # Interfaces de repositorios
│   │   └── wines_repository.dart
│   ├── user.dart        # Entidad User
│   ├── wine.dart        # Entidad Wine
│   └── wine_analysis_result.dart  # DTO de análisis IA
│
├── data/                # CAPA DE DATOS
│   ├── repositories/    # Implementaciones de repositorios
│   │   ├── users_repository.dart
│   │   ├── users_repository_firestore.dart
│   │   └── wines_repository_firestore.dart
│   └── providers.dart   # Providers de Riverpod
│
├── presentation/        # VISTA - UI y ViewModels
│   ├── components/      # Componentes reutilizables
│   │   └── drawer_menu.dart
│   ├── screen/          # Pantallas de la app
│   │   ├── login.dart
│   │   ├── wine_screen.dart
│   │   ├── wine_detail_screen.dart
│   │   ├── add_edit_item.dart
│   │   ├── profile.dart
│   │   └── settings.dart
│   ├── viewmodels/      # VIEWMODEL - Gestión de estado
│   │   ├── auth_viewmodel.dart
│   │   ├── profile_viewmodel.dart
│   │   ├── add_edit_wine_viewmodel.dart
│   │   └── notifiers/
│   │       └── wines_viewmodel.dart
│   └── utils/           # Utilidades de presentación
│       ├── base_state.dart
│       └── base_view_model.dart
│
├── services/            # SERVICIOS - Lógica de negocio
│   ├── auth_service.dart
│   ├── firebase_auth_service.dart
│   ├── firebase_storage_service.dart
│   ├── wine_image_analysis_service.dart
│   └── wines_provider.dart
│
├── firebase_options.dart  # Configuración Firebase
└── main.dart             # Punto de entrada
```

---

## 🔷 CAPA DE DOMINIO (Model)

### 📄 `domain/user.dart`
**Propósito**: Entidad que representa un usuario del sistema.

```dart
class User {
  final int id;
  final String username;
  String password;
  final String email;
  final int? age;
  String? avatarUrl;
}
```

**Características**:
- Modelo de datos puro sin dependencias de Flutter
- Incluye métodos `copyWith()`, `toJson()`, `fromJson()`
- Usado tanto en autenticación como en perfil de usuario

---

### 📄 `domain/wine.dart`
**Propósito**: Entidad que representa un vino en el catálogo.

```dart
class Wine {
  final String id;
  final String name;
  final String year;
  final String grapes;
  final String country;
  final String region;
  final String description;
  final String? pictureUrl;
}
```

**Características**:
- ID único para identificar cada vino
- Campos descriptivos del vino
- `pictureUrl` opcional para imagen de la botella
- Métodos de serialización para Firestore

---

### 📄 `domain/wine_analysis_result.dart`
**Propósito**: DTO (Data Transfer Object) que encapsula el resultado del análisis de IA.

```dart
class WineAnalysisResult {
  final bool isWine;           // ¿Es una botella de vino?
  final String? name;          // Nombre detectado
  final String? year;          // Año de cosecha
  final String? grapes;        // Tipo de uva
  final String? country;       // País de origen
  final String? region;        // Región vitivinícola
  final String? description;   // Descripción
  final double confidence;     // Nivel de confianza (0.0 - 1.0)
  final String? errorMessage;  // Mensaje de error si falla
}
```

**Métodos factory**:
- `WineAnalysisResult.error(String message)` - Para errores
- `WineAnalysisResult.notWine()` - Cuando no se detecta un vino

---

### 📄 `domain/repositories/wines_repository.dart`
**Propósito**: Interfaz que define el contrato para operaciones CRUD de vinos.

```dart
abstract class WinesRepository {
  Future<void> delete(Wine wine);
  Future<void> deleteAll();
  Future<List<Wine>> getAll();
  Future<Wine?> getById(String id);
  Future<void> insert(Wine wine);
  Future<void> update(Wine wine);
}
```

**Ventajas**:
- Inversión de dependencias (SOLID)
- Facilita testing con mocks
- Permite cambiar la implementación sin afectar la lógica de negocio

---

## 🔷 CAPA DE DATOS (Data)

### 📄 `data/repositories/wines_repository_firestore.dart`
**Propósito**: Implementación concreta del repositorio usando Cloud Firestore.

**Responsabilidades**:
1. **Mapeo de datos**: Convierte entre `Wine` (dominio) y `Map<String, dynamic>` (Firestore)
2. **Operaciones CRUD**:
   - `getAll()` - Obtiene todos los vinos
   - `getById(id)` - Busca un vino específico
   - `insert(wine)` - Agrega un nuevo vino
   - `update(wine)` - Actualiza un vino existente
   - `delete(wine)` - Elimina un vino
3. **Operaciones batch**: `insertMany()` para seed inicial

**Código clave**:
```dart
class WinesFirestoreRepository implements WinesRepository {
  final FirebaseFirestore _firestore;
  final CollectionReference<Map<String, dynamic>> _col;

  Wine _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return Wine(
      id: doc.id,
      name: data['name'] as String? ?? '',
      // ... más campos
    );
  }

  Map<String, dynamic> _toDoc(Wine wine) {
    return {
      'name': wine.name,
      'year': wine.year,
      // ... más campos
    };
  }
}
```

---

### 📄 `data/repositories/users_repository_firestore.dart`
**Propósito**: Gestiona usuarios en Firestore.

**Operaciones**:
- `findByCredentials(username, password)` - Login
- `getAll()` - Lista de usuarios
- `insertMany(users)` - Seed inicial
- `updateUser(user)` - Actualizar perfil

---

### 📄 `data/providers.dart`
**Propósito**: Define los providers de Riverpod para inyección de dependencias.

```dart
final winesRepositoryProvider = Provider<WinesRepository>((ref) {
  return WinesFirestoreRepository();
});
```

**Ventajas**:
- Centraliza la creación de instancias
- Facilita testing
- Permite cambiar implementaciones fácilmente

---

## 🔷 CAPA DE SERVICIOS (Services)

### 📄 `services/firebase_auth_service.dart`
**Propósito**: Gestiona la autenticación de usuarios.

**Responsabilidades**:
1. **Login con email/password**:
   ```dart
   Future<User?> signInWithEmailAndPassword(String email, String password)
   ```
2. **Login con Google**:
   ```dart
   Future<User?> signInWithGoogle()
   ```
3. **Logout**:
   ```dart
   Future<void> signOut()
   ```
4. **Escuchar cambios de autenticación**:
   ```dart
   Stream<User?> authStateChanges()
   ```

**Integración**:
- Usa `FirebaseAuth` para autenticación
- Sincroniza con `UsersRepository` de Firestore
- Notifica cambios mediante `ChangeNotifier`

---

### 📄 `services/firebase_storage_service.dart`
**Propósito**: Gestiona la subida y descarga de imágenes en Firebase Storage.

**Operaciones**:
1. **Subir imagen de perfil**:
   ```dart
   Future<String> uploadUserAvatar(String userId, File imageFile)
   ```
   - Ruta: `user_avatars/{userId}/avatar.jpg`
   - Comprime la imagen antes de subir
   - Retorna la URL de descarga

2. **Subir imagen de vino**:
   ```dart
   Future<String> uploadWineImage(String userId, File imageFile)
   ```
   - Ruta: `wine_images/{userId}/{timestamp}_{filename}`
   - Usa timestamp para evitar colisiones
   - Retorna la URL de descarga

3. **Eliminar imagen de vino**:
   ```dart
   Future<void> deleteWineImage(String imageUrl)
   ```
   - Extrae la ruta de la URL
   - Elimina el archivo de Storage

4. **Actualizar avatar de usuario**:
   ```dart
   Future<void> updateUserAvatar(String userId, File imageFile)
   ```
   - Elimina avatar anterior si existe
   - Sube nuevo avatar
   - Actualiza Firestore con nueva URL

---

### 📄 `services/wine_image_analysis_service.dart`
**Propósito**: Analiza imágenes de botellas de vino usando Google Gemini AI.

**Flujo de trabajo**:
1. **Recibe imagen** (ruta del archivo local)
2. **Lee imagen como bytes**
3. **Construye prompt** para Gemini AI:
   ```
   "Analiza esta imagen y determina si es una botella de vino.
    Si es un vino, extrae: nombre, año, uvas, país, región, descripción.
    Responde en formato JSON."
   ```
4. **Envía a Gemini** usando la API
5. **Parsea respuesta JSON**
6. **Retorna `WineAnalysisResult`**

**Código clave**:
```dart
class WineImageAnalysisService {
  final GenerativeModel _model;

  Future<WineAnalysisResult> analyzeWineImage(String imagePath) async {
    final imageBytes = await File(imagePath).readAsBytes();
    
    final content = [
      Content.multi([
        TextPart(prompt),
        DataPart('image/jpeg', imageBytes),
      ])
    ];

    final response = await _model.generateContent(content);
    return _parseResponse(response.text);
  }
}
```

**Manejo de errores**:
- Si la imagen no es un vino → `WineAnalysisResult.notWine()`
- Si hay error de red/API → `WineAnalysisResult.error(message)`

---

## 🔷 CAPA DE PRESENTACIÓN (View + ViewModel)

### 📄 `presentation/viewmodels/auth_viewmodel.dart`
**Propósito**: Gestiona el estado de autenticación de la aplicación.

**Estado**:
```dart
class AuthState {
  final User? currentUser;
  final bool isLoading;
  final String? errorMessage;
}
```

**Acciones**:
- `signInWithEmail(email, password)` - Login tradicional
- `signInWithGoogle()` - Login con Google
- `signOut()` - Cerrar sesión
- `updateUser(user)` - Actualizar perfil

**Integración con Router**:
```dart
redirect: (context, state) {
  final isLoggedIn = authViewModel.currentUser != null;
  final isLoginRoute = state.location == '/login';
  
  if (!isLoggedIn && !isLoginRoute) return '/login';
  if (isLoggedIn && isLoginRoute) return '/wines';
  return null;
}
```

---

### 📄 `presentation/viewmodels/wines_viewmodel.dart`
**Propósito**: Gestiona la lista de vinos (AsyncNotifier pattern).

**Características**:
```dart
class WinesViewModel extends AsyncNotifier<List<Wine>> {
  @override
  FutureOr<List<Wine>> build() async {
    final repository = ref.watch(winesRepositoryProvider);
    return repository.getAll();
  }

  Future<void> addWine(Wine wine) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(winesRepositoryProvider).insert(wine);
      return ref.read(winesRepositoryProvider).getAll();
    });
  }
}
```

**Ventajas**:
- Manejo automático de estados: loading, data, error
- Reactividad: la UI se actualiza automáticamente
- Cache automático de datos

---

### 📄 `presentation/viewmodels/add_edit_wine_viewmodel.dart`
**Propósito**: Gestiona el formulario de agregar/editar vinos y análisis con IA.

**Estados**:
```dart
enum AddEditWineState {
  idle,      // Estado inicial
  analyzing, // Analizando imagen con IA
  uploading, // Subiendo imagen a Storage
  success,   // Operación exitosa
  error      // Error
}
```

**Flujo de trabajo completo**:
```
Usuario selecciona imagen
         ↓
setLocalImage(File image)
         ↓
analyzeImage(apiKey)
         ↓
[Estado: analyzing]
         ↓
WineImageAnalysisService.analyzeWineImage()
         ↓
¿Es vino?
  ├─ Sí → Autocompletar formulario
  └─ No → Mostrar advertencia
         ↓
Usuario confirma/edita
         ↓
saveWine()
         ↓
[Estado: uploading]
         ↓
uploadImage() → Firebase Storage
         ↓
insert/update en Firestore
         ↓
[Estado: success]
```

**Código clave**:
```dart
class AddEditWineViewModel extends Notifier<AddEditWineState> {
  File? _localImage;
  WineAnalysisResult? _analysisResult;

  Future<WineAnalysisResult?> analyzeImage(String apiKey) async {
    if (_localImage == null) return null;
    
    state = AddEditWineState.analyzing;
    final service = WineImageAnalysisService(apiKey: apiKey);
    _analysisResult = await service.analyzeWineImage(_localImage!.path);
    state = AddEditWineState.idle;
    
    return _analysisResult;
  }

  Future<String?> uploadImage(String userId) async {
    if (_localImage == null) return null;
    
    state = AddEditWineState.uploading;
    final service = ref.read(firebaseStorageServiceProvider);
    final url = await service.uploadWineImage(userId, _localImage!);
    state = AddEditWineState.idle;
    
    return url;
  }
}
```

---

### 📄 `presentation/viewmodels/profile_viewmodel.dart`
**Propósito**: Gestiona el perfil del usuario y su avatar.

**Operaciones**:
1. **Actualizar avatar**:
   ```dart
   Future<void> updateAvatar(File imageFile) async {
     state = ProfileState.uploading;
     final url = await _storage.uploadUserAvatar(userId, imageFile);
     await _authViewModel.updateUser(user.copyWith(avatarUrl: url));
     state = ProfileState.success;
   }
   ```

2. **Cambiar contraseña**
3. **Actualizar información personal**

---

### 📄 `presentation/screen/login.dart`
**Propósito**: Pantalla de inicio de sesión.

**Arquitectura**:
```dart
LoginScreen (StatefulWidget)
    ↓
ConsumerWidget (escucha AuthViewModel)
    ↓
_LoginCard (componente reutilizable)
    ├─ _UsernameField
    ├─ _PasswordField
    └─ _LoginButton
```

**Flujo**:
1. Usuario ingresa credenciales
2. Tap en "Login"
3. Llama `authViewModel.signInWithEmail()`
4. Si éxito → Router redirige a `/wines`
5. Si error → Muestra SnackBar

---

### 📄 `presentation/screen/wine_screen.dart`
**Propósito**: Lista principal de vinos.

**Características**:
- Usa `ConsumerWidget` para escuchar `winesViewModelProvider`
- **RefreshIndicator** para pull-to-refresh
- **FutureBuilder** para manejar estados async
- **FloatingActionButton** para agregar vino
- Navega a detalle con `context.push('/wine/${wine.id}')`

**Código clave**:
```dart
class WineScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final winesAsync = ref.watch(winesViewModelProvider);
    
    return winesAsync.when(
      data: (wines) => ListView.builder(
        itemCount: wines.length,
        itemBuilder: (context, index) => WineCard(wine: wines[index]),
      ),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => ErrorWidget(error),
    );
  }
}
```

---

### 📄 `presentation/screen/add_edit_item.dart`
**Propósito**: Formulario para agregar o editar vinos con IA.

**Características principales**:

1. **Modo dual**: Add o Edit según `initialWine`
2. **Análisis con IA**:
   ```dart
   Future<void> _analyzeImage() async {
     final result = await ref.read(addEditWineProvider.notifier)
                           .analyzeImage(ApiKeys.geminiApiKey);
     
     if (result?.isWine == true) {
       _autoFillFields(result!);
     }
   }
   ```

3. **Autocompletado de campos**:
   ```dart
   void _autoFillFields(WineAnalysisResult result) {
     if (result.name != null) _nameCtrl.text = result.name!;
     if (result.year != null) _yearCtrl.text = result.year!;
     if (result.grapes != null) _grapesCtrl.text = result.grapes!;
     // ... más campos
   }
   ```

4. **Indicadores visuales**:
   - `CircularProgressIndicator` durante análisis
   - Card verde si detecta vino
   - Card amarilla si no detecta vino
   - Badge de confianza

**UI Flow**:
```
[Botón Cámara] [Botón Galería]
         ↓
[Imagen seleccionada]
         ↓
[Analizando... 🔄]
         ↓
[✓ Vino detectado - Confianza: 95%]
         ↓
[Formulario autocompletado]
         ↓
[Botón Guardar]
```

---

### 📄 `presentation/screen/profile.dart`
**Propósito**: Perfil del usuario con avatar editable.

**Características**:
- Avatar circular con `CircleAvatar`
- Tap en avatar → `ImagePicker` → Subir a Storage
- Muestra información del usuario
- Botón para cambiar contraseña

---

## 🔷 CAPA DE CONFIGURACIÓN (Core)

### 📄 `core/router/app_router.dart`
**Propósito**: Configuración de navegación con `go_router`.

**Rutas definidas**:
```dart
'/login'              → LoginScreen
'/wines'              → WineScreen (requiere auth)
'/wine/:id'           → WineDetailScreen
'/add_item'           → AddEditItemScreen (modo add)
'/edit_item'          → AddEditItemScreen (modo edit)
'/profile'            → ProfileScreen
'/settings'           → SettingsScreen
```

**Redirect automático**:
```dart
redirect: (context, state) {
  final isLoggedIn = authService.isLoggedIn;
  final isLoginRoute = state.location == '/login';
  
  if (!isLoggedIn && !isLoginRoute) return '/login';
  if (isLoggedIn && isLoginRoute) return '/wines';
  return null;
}
```

---

### 📄 `core/theme/theme_provider.dart`
**Propósito**: Gestión de tema (light/dark) con Riverpod.

**Estado**:
```dart
class AppTheme {
  final int selectedColor;
  final bool isDarkMode;
}
```

**Persistencia**: Guarda preferencias en `SharedPreferences`

---

## 🔷 PUNTO DE ENTRADA

### 📄 `main.dart`
**Responsabilidades**:

1. **Inicializar Firebase**:
   ```dart
   await Firebase.initializeApp(
     options: DefaultFirebaseOptions.currentPlatform,
   );
   ```

2. **Seed de datos iniciales**:
   ```dart
   await _seedDataIfNeeded();
   ```

3. **Configurar Riverpod**:
   ```dart
   runApp(ProviderScope(
     child: AppRoot(router: router),
   ));
   ```

4. **Aplicar tema**:
   ```dart
   MaterialApp.router(
     theme: ref.watch(themeNotifierProvider).getTheme(),
     routerConfig: router,
   );
   ```

---

## 🔄 Flujos de Datos Clave

### Flujo 1: Login
```
1. Usuario ingresa credenciales en LoginScreen
2. LoginScreen llama authViewModel.signInWithEmail()
3. AuthViewModel llama authService.signInWithEmail()
4. AuthService llama FirebaseAuth.signInWithEmailAndPassword()
5. AuthService consulta UsersRepository.findByEmail()
6. AuthViewModel actualiza estado con usuario
7. Router detecta cambio y redirige a /wines
8. WineScreen se renderiza automáticamente
```

### Flujo 2: Agregar Vino con IA
```
1. Usuario toca FAB en WineScreen
2. Router navega a AddEditItemScreen
3. Usuario selecciona imagen (cámara/galería)
4. AddEditWineViewModel.setLocalImage() guarda imagen
5. AddEditWineViewModel.analyzeImage() llama servicio IA
6. WineImageAnalysisService envía imagen a Gemini
7. Gemini responde con JSON
8. ViewModel parsea y actualiza analysisResult
9. AddEditItemScreen autocompleta campos
10. Usuario edita/confirma
11. AddEditWineViewModel.saveWine() sube imagen
12. FirebaseStorageService.uploadWineImage() retorna URL
13. WinesRepository.insert() guarda en Firestore
14. Router navega de vuelta con resultado
15. WineScreen se refresca automáticamente
```

### Flujo 3: Actualizar Avatar
```
1. Usuario toca avatar en ProfileScreen
2. ProfileScreen llama profileViewModel.updateAvatar()
3. ProfileViewModel llama firebaseStorageService.updateUserAvatar()
4. FirebaseStorageService sube imagen y retorna URL
5. ProfileViewModel llama authViewModel.updateUser()
6. AuthViewModel actualiza Firestore
7. Estado se propaga y UI se actualiza
```

---

## 🎯 Principios SOLID Aplicados

### Single Responsibility (S)
- Cada clase tiene una única responsabilidad
- `WineImageAnalysisService` solo analiza imágenes
- `FirebaseStorageService` solo gestiona archivos

### Open/Closed (O)
- Repositorios basados en interfaces
- Fácil extender sin modificar código existente

### Liskov Substitution (L)
- Cualquier `WinesRepository` puede reemplazar a otro
- `WinesFirestoreRepository` cumple el contrato

### Interface Segregation (I)
- Interfaces específicas por responsabilidad
- `WinesRepository` solo expone operaciones de vinos

### Dependency Inversion (D)
- ViewModels dependen de interfaces, no implementaciones
- Inyección de dependencias con Riverpod

---

## 🧪 Beneficios de Esta Arquitectura

### ✅ Testabilidad
- ViewModels independientes de UI
- Servicios y repositorios fáciles de mockear
- Lógica de negocio aislada

### ✅ Mantenibilidad
- Código organizado y predecible
- Separación clara de responsabilidades
- Fácil localizar bugs

### ✅ Escalabilidad
- Agregar nuevas features sin afectar existentes
- Cambiar implementaciones sin romper código
- Reutilización de componentes

### ✅ Reactividad
- UI se actualiza automáticamente
- Estado centralizado con Riverpod
- Menos boilerplate

---

## 📚 Tecnologías y Patrones Utilizados

| Capa | Tecnología | Patrón |
|------|------------|---------|
| **UI** | Flutter Widgets | Composition |
| **State** | Riverpod | Notifier/AsyncNotifier |
| **Navigation** | go_router | Declarative Routing |
| **Auth** | Firebase Auth | Observer |
| **Database** | Cloud Firestore | Repository |
| **Storage** | Firebase Storage | Service |
| **AI** | Gemini AI | Strategy |
| **DI** | Riverpod Providers | Dependency Injection |

---

## 🎓 Conceptos Clave para Explicar

1. **MVVM**: Separación entre lógica y presentación
2. **Riverpod**: Gestión de estado reactiva y type-safe
3. **Repository Pattern**: Abstracción de acceso a datos
4. **Service Layer**: Lógica de negocio centralizada
5. **Dependency Injection**: Inversión de control
6. **Reactive Programming**: Estado reactivo con Notifiers
7. **Clean Architecture**: Capas bien definidas
8. **Firebase**: Backend as a Service (BaaS)
9. **AI Integration**: Gemini Vision API
10. **Material Design 3**: Siguiendo guías de diseño

---

Este documento proporciona una visión completa de la arquitectura del proyecto, ideal para presentar en una evaluación académica. Cada módulo está explicado con su propósito, responsabilidades y cómo se integra con el resto del sistema.
