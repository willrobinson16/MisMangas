# MisMangas 📚

> Aplicación iOS nativa para gestionar tu colección de manga con sincronización en la nube

[![Swift 6.2](https://img.shields.io/badge/Swift-6.2-orange.svg)](https://swift.org)
[![iOS 26.1+](https://img.shields.io/badge/iOS-26.1%2B-blue.svg)](https://developer.apple.com/ios/)
[![SwiftUI](https://img.shields.io/badge/SwiftUI-100%25-green.svg)](https://developer.apple.com/xcode/swiftui/)
[![License](https://img.shields.io/badge/license-Private-red.svg)](LICENSE)

**MisMangas** es una aplicación moderna para iPhone y iPad que te permite explorar, buscar y gestionar tu colección personal de manga. Con sincronización en la nube, diseño adaptativo y arquitectura Swift 6.2.

---

## ✨ Características Principales

### 📖 Exploración de Manga
- Catálogo completo con **paginación infinita**
- Vista detallada con diseño tipo revista
- Información completa: sinopsis, autores, géneros, temas, demografía
- Rating visual con estrellas
- Estados de publicación (En emisión, Finalizado, etc.)

### 🔍 Búsqueda Avanzada
- Búsqueda por **título** (exacta o flexible)
- Filtrado por **autor** (nombre y apellido)
- Selección múltiple de **géneros, temas y demografías**
- Chips visuales de filtros activos
- Resultados en tiempo real con debounce

### 📚 Gestión de Colección
- **Tracking de volúmenes**: marca los que posees individualmente
- **Progreso de lectura**: indica qué volumen estás leyendo
- **Colección completa**: flag especial para series completas
- Sincronización automática con la nube
- Filtros por autores, géneros, temas y demografías
- Vista lista o grid adaptativa

### ⭐ Favoritos
- Marca tus mangas favoritos
- Almacenamiento local con SwiftData
- Acceso rápido desde cualquier vista

### 👤 Sistema de Usuario
- **Autenticación JWT** segura
- Login y registro con validación
- Tokens almacenados en **Keychain**
- Refresh token automático
- Sincronización de colección al iniciar sesión

### 📱 Optimización iPad
- 6 vistas específicas para iPad
- **NavigationSplitView** para autores
- Grids adaptativos multi-columna
- Layouts enriquecidos con más información
- Detección automática de dispositivo

---

## 🛠️ Stack Tecnológico

### Frontend
- **SwiftUI** puro (sin UIKit)
- Swift 6.2 con **strict concurrency**
- Arquitectura **MVVM** + Repository Pattern
- `@Observable` (sin ObservableObject deprecado)

### Persistencia
- **SwiftData** para almacenamiento local
- Dual-model approach: DTOs → Models
- Offline-first con sincronización cloud
- Queue de cambios pendientes

### Networking
- NetworkAPI package personalizado
- **JWT authentication**
- HTTPS exclusivamente
- Manejo de errores tipado

### Seguridad
- Tokens en **Keychain** (no UserDefaults)
- Validación de email y contraseña
- Basic Auth para login
- Bearer tokens para endpoints protegidos

---

## 📂 Estructura del Proyecto

```
MisMangas/
├── System/           # App entry point y configuración
├── DataModel/        # SwiftData models (@Model)
├── DTO/              # Data Transfer Objects (API)
├── Network/          # Network layer + repositories
├── User/             # Autenticación y gestión de usuario
├── ViewModel/        # ViewModels @Observable
├── Views/            # Vistas iPhone
│   └── iPad/         # Vistas optimizadas iPad
├── Components/       # Componentes reutilizables
├── Search/           # Componentes de búsqueda avanzada
└── Extensions/       # Extensiones Swift
```

---

## 🚀 Instalación

### Requisitos

- **Xcode 26.2+**
- **Swift 6.2**
- **iOS 26.1+** (simulador o dispositivo)
- NetworkAPI package (incluido localmente)

### Pasos

1. **Clonar el repositorio**
   ```bash
   git clone https://github.com/usuario/MisMangas.git
   cd MisMangas
   ```

2. **Abrir en Xcode**
   ```bash
   open MisMangas.xcodeproj
   ```

3. **Configurar certificados**
   - Cambiar el **Development Team** en Xcode
   - Actualizar el **Bundle ID** si es necesario

4. **Ejecutar**
   - Seleccionar simulador o dispositivo
   - Presionar `Cmd + R` para compilar y ejecutar

---

## 🔐 Configuración

### API Backend

La aplicación se conecta a:
```
https://mymanga-acacademy-5607149ebe3d.herokuapp.com
```

Endpoints principales:
- `GET /list/mangas` - Listado de mangas
- `POST /search/manga` - Búsqueda personalizada
- `POST /users/jwt/login` - Login con JWT
- `GET /collection/manga` - Colección del usuario

### Autenticación

1. Crear cuenta desde la app (pantalla de registro)
2. Iniciar sesión con email y contraseña
3. El token JWT se guarda automáticamente en Keychain
4. La colección se sincroniza al iniciar sesión

---

## 🏗️ Arquitectura

### Patrones Implementados

1. **Repository Pattern** - Separación de lógica de datos
2. **MVVM** - ViewModels con `@Observable`
3. **Dependency Injection** - Environment + setModelContext()
4. **Offline-First** - Cambios locales + sincronización background
5. **Factory Pattern** - Conversión DTO → Model centralizada

### Concurrencia Swift 6.2

- ✅ **@MainActor** para UI y ViewModels
- ✅ **async/await** en lugar de completion handlers
- ✅ Funciones de persistencia **nonisolated**
- ✅ ZERO data race warnings
- ✅ Sin código deprecado

---

## 🔒 Seguridad

### Implementado

- ✅ Tokens JWT en Keychain (seguro)
- ✅ HTTPS para todas las peticiones
- ✅ Validación de email con regex
- ✅ Contraseñas mínimo 8 caracteres
- ✅ Refresh token automático

---

## 📝 Documentación

- **CLAUDE.md** - Guía de desarrollo para Claude Code
- **ARQUITECTURA.md** - Arquitectura detallada del proyecto
- **SECURITY_ANALYSIS.md** - Análisis de seguridad y vulnerabilidades
- **DOCUMENTACION_RESUMEN.md** - Índice de toda la documentación

---

## 🗺️ Roadmap

### ✅ Completado (MVP)

- Catálogo de mangas con paginación
- Búsqueda avanzada multi-criterio
- Sistema de favoritos
- Gestión de colección con sincronización
- Autenticación JWT
- Layouts iPad optimizados

### 🔜 Próximamente

- [ ] Configurar tests en Xcode scheme
- [ ] Resolver vulnerabilidad de token hardcodeado
- [ ] Logger centralizado (OSLog)
- [ ] Scroll infinito en SearchView
- [ ] Rate limiting client-side
- [ ] Skeleton screens para loading states

---

## 👨‍💻 Desarrollo

### Comandos Útiles

```bash
# Compilar Debug
xcodebuild -scheme MisMangas -configuration Debug build

# Compilar Release
xcodebuild -scheme MisMangas -configuration Release build

# Limpiar build
xcodebuild -scheme MisMangas clean

# Abrir en Xcode
open MisMangas.xcodeproj
```

### Versión Swift

```bash
swift --version
# Apple Swift version 6.2
```

---

## 📄 Licencia

Este proyecto es de uso privado. Todos los derechos reservados.

**Bundle ID**: `com.grobinson.MisMangas`
**Development Team**: 2WATSHBXAF

---

## 🙏 Agradecimientos

- API Backend: [MyManga Academy](https://mymanga-acacademy-5607149ebe3d.herokuapp.com)
- NetworkAPI: Package Swift personalizado
- Iconos: SF Symbols

---

## 📧 Contacto

**Guillermo Robinson**
Proyecto desarrollado como parte del portfolio iOS

---

<p align="center">
  Hecho con ❤️ y SwiftUI
</p>
