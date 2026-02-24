# Arquitectura de MisMangas

## Descripción General

MisMangas es una aplicación iOS desarrollada con **SwiftUI** y **Swift 6.2** que permite a los usuarios gestionar su colección de mangas, consultar información detallada y marcar favoritos.

### Tecnologías Principales

- **Swift 6.2** con concurrencia estricta (strict concurrency checking)
- **SwiftUI** para interfaz de usuario declarativa
- **SwiftData** para persistencia local
- **Async/Await** para operaciones asíncronas
- **URLSession** para peticiones de red
- **NetworkAPI** (paquete personalizado) para gestión de red

### Plataforma

- **iOS 26.1+**
- **Bundle ID**: `com.grobinson.MisMangas`
- **Arquitectura**: Clean Architecture con separación de capas

---

## Estructura del Proyecto

```
MisMangas/
├── System/              - Punto de entrada de la app (MisMangasApp.swift)
├── DataModel/           - Modelos SwiftData (@Model) y actores de datos
│   ├── Model.swift                  - Manga, Author, Theme, Genre, Demographic
│   ├── FavoriteManga.swift          - Modelo de favoritos
│   ├── UserMangaCollection.swift    - Modelo de colección del usuario
│   ├── DataContainer.swift          - Actor de datos principal
│   ├── PreviewContainer.swift       - Contenedor para previews
│   └── PreviewData.swift            - Datos de prueba
├── Model/DTO/           - Data Transfer Objects para comunicación con API
│   ├── MangaDTO.swift
│   ├── AuthorDTO.swift
│   ├── ThemeDTO.swift
│   ├── GenreDTO.swift
│   ├── DemographicDTO.swift
│   ├── MangaPageDTO.swift
│   ├── MangaStatus.swift
│   └── ...
├── Network/             - Capa de red y comunicación con API
│   ├── NetworkRepository.swift      - Implementación de endpoints
│   ├── NetworkError.swift           - Errores tipados de red
│   ├── NetworkInteractor.swift      - Protocolo de interacción
│   ├── ImageDownloader.swift        - Actor para descarga de imágenes
│   ├── URL.swift                    - Definiciones de endpoints
│   └── URLRequest.swift             - Extensiones de URLRequest
├── ViewModel/           - ViewModels con lógica de negocio
│   ├── UserCollectionViewModel.swift
│   ├── FavoritesViewModel.swift
│   ├── BestMangasViewModel.swift
│   └── SearchViewModel.swift
├── Views/               - Vistas SwiftUI de pantalla completa
│   ├── ContentView.swift            - Vista principal con lista de mangas
│   ├── MangaView.swift              - Vista de detalle de un manga
│   ├── FavoritesView.swift          - Vista de favoritos
│   ├── UserCollectionView.swift     - Vista de colección del usuario
│   ├── EditCollectionSheet.swift    - Sheet para editar colección
│   └── ...
├── Search/              - Componentes de búsqueda avanzada
│   ├── SearchView.swift                   - Vista principal de búsqueda
│   ├── AdvancedSearchFiltersSheet.swift   - Sheet de filtros avanzados
│   ├── MultiSelectGenresView.swift        - Selector multi-opción de géneros
│   ├── MultiSelectThemesView.swift        - Selector multi-opción de temas
│   ├── MultiSelectDemographicsView.swift  - Selector multi-opción de demografías
│   └── FilterChip.swift                   - Chip visual para filtros activos
├── Components/          - Componentes reutilizables de SwiftUI
│   ├── MangaRow.swift
│   ├── RatingView.swift
│   ├── MainPictureView.swift
│   └── ...
├── Extensions/          - Extensiones y utilidades
│   ├── ModelContext+MangaPersistence.swift  - Funciones globales de persistencia
│   └── StringExtensions.swift
└── MainTab.swift        - TabView principal de navegación
```

---

## Capas de la Arquitectura

### 1. **Capa de Presentación (Views + ViewModels)**

#### Views
- **SwiftUI** con declaración de interfaz de usuario
- Aisladas a `@MainActor` para actualizaciones seguras de UI
- Utilizan `@Environment` para acceder a contextos y dependencias
- Implementan navegación con `NavigationStack` y `NavigationDestination`

#### ViewModels
- Marcados con `@Observable` (Swift 6.2)
- Aislados a `@MainActor` para garantizar ejecución en hilo principal
- Gestionan estado de UI: carga, errores, datos
- No realizan persistencia directamente, delegan en `ModelContext`

**Ejemplos:**
- `BestMangasViewModel`: Carga mejores mangas desde API
- `SearchViewModel`: Búsqueda en tiempo real con debounce (500ms)
- `FavoritesViewModel`: Gestión de favoritos (añadir/eliminar/verificar)
- `UserCollectionViewModel`: Gestión completa de colección del usuario

---

### 2. **Capa de Datos (DataModel + Network)**

#### DataModel (Persistencia con SwiftData)

##### Modelos principales (`@Model`)

**Manga**
- Modelo principal con toda la información de un manga
- Índice en `title` para búsquedas rápidas
- Relaciones bidireccionales con Theme, Author, Genre, Demographic
- ID único con restricción de unicidad

**Author**
- Información de autores
- Índices en `firstName` y `lastName`
- Relación inversa con Manga (cascade delete)
- Rol del autor: Story, Art, Story and Art

**Theme, Genre, Demographic**
- Modelos auxiliares para categorización
- Índices en sus respectivos campos de nombre
- Relaciones muchos-a-muchos con Manga

**FavoriteManga**
- Modelo ligero que solo almacena ID y fecha de agregado
- Relación implícita con Manga por ID

**UserMangaCollection**
- Modelo completo para colección del usuario
- Gestión de volúmenes poseídos (almacenados como Data/JSON)
- Seguimiento de volumen actual de lectura
- Flags de colección completa
- Métodos de cálculo de progreso

##### DataContainer (`@ModelActor`)

Actor de datos que gestiona la carga y persistencia:
- Operaciones concurrentes seguras con SwiftData
- Integración con `Network` para obtener datos de API
- Paginación automática con persistencia en UserDefaults
- Conversión de DTOs a modelos SwiftData
- Evita duplicados al persistir

---

#### Network (Comunicación con API)

##### NetworkRepository (`Network`)

Implementación de todos los endpoints de la API:

**Listados:**
- `getAuthors()`: Lista completa de autores
- `getMangas()`: Lista completa de mangas
- `getMangasPage(page:itemsPerPage:)`: Paginación
- `getBestMangas()`: Mejores mangas por score
- `getThemes()`, `getGenres()`, `getDemographics()`

**Búsquedas:**
- `searchMangasBeginsWith(_:)`: Por inicio de título
- `searchMangasContains(_:)`: Por contenido de título
- `getManga(id:)`: Manga específico por ID
- `customSearch(_:)`: Búsqueda con múltiples criterios

**Filtrados:**
- `getMangaByAuthor(id:)`
- `getMangaByTheme(theme:)`
- `getMangaByGenre(genre:)`
- `getMangaByDemographic(demographic:)`

##### NetworkError

Errores tipados para manejo específico:
- `.general(Error)`: Error general de red
- `.status(Int)`: Código HTTP no exitoso
- `.json(Error)`: Error de decodificación JSON
- `.dataNotValid`: Datos inválidos
- `.nonHTTP`: Respuesta no es HTTPURLResponse

##### ImageDownloader (`actor`)

Actor especializado en descarga y caché de imágenes:
- **Caché en memoria**: Estado de descarga por URL
- **Caché en disco**: Almacenamiento persistente en directorio de caché
- **Prevención de descargas duplicadas**: Una única descarga por URL
- **Redimensionamiento**: A 300px de ancho antes de guardar
- **Formato**: JPEG con calidad máxima

---

### 3. **Capa de Transferencia de Datos (DTOs)**

#### MangaDTO
- Información completa de un manga desde la API
- Conversión a `Manga` (@Model) con `.toManga`
- Limpieza automática de URLs con `.cleanedURL`
- Mapeo especial: `synopsis` ← API: `"sypnosis"` (typo del backend)

#### AuthorDTO, ThemeDTO, GenreDTO, DemographicDTO
- DTOs simples con conversión a modelos SwiftData
- ID en formato UUID
- Conforman `Codable`, `Identifiable`, `Hashable`

#### MangaPageDTO
- Respuesta paginada con metadatos y lista de items
- Estructura: `{ metadata: {...}, items: [...] }`

#### MangaStatus (Enum)
- Estados de publicación: `discontinued`, `onHiatus`, `currentlyPublishing`, `finished`, `none`
- Valores raw en snake_case (formato API)

---

## Flujo de Datos

### Carga Inicial de Mangas

```
1. ContentView se muestra
2. .refreshable { DataContainer.loadInitialData() }
3. DataContainer (actor) obtiene mangas y autores concurrentemente
4. Convierte MangaDTO a Manga usando funciones globales de persistencia
5. SwiftData persiste los datos
6. @Query actualiza automáticamente la vista
```

### Búsqueda de Mangas

```
1. Usuario escribe en SearchView
2. SearchViewModel.search cambia → cancela tarea anterior
3. Espera 500ms (debounce)
4. Llama a network.searchMangasBeginsWith(search)
5. Actualiza mangaResult con resultados
6. Lista se actualiza reactivamente
```

### Añadir a Favoritos

```
1. Usuario toca botón de favorito en MangaView
2. FavoritesViewModel.toggleFavorite(manga)
3. Verifica si ya es favorito con isFavorite(manga.id)
4. Si no es favorito, crea FavoriteManga(id: manga.id)
5. Inserta en ModelContext y guarda
6. Vista actualiza automáticamente con @Query
```

### Gestión de Colección

```
1. Usuario navega a UserCollectionView
2. @Query obtiene todas las UserMangaCollection
3. Para cada entrada, hace JOIN con Manga por mangaID
4. Usuario edita con EditCollectionSheet (@Bindable)
5. Cambios en UserMangaCollection se persisten automáticamente
6. UserCollectionViewModel gestiona lógica de volúmenes y progreso
```

---

## Persistencia de Datos

### Funciones Globales (ModelContext+MangaPersistence.swift)

Solución arquitectónica para evitar problemas de concurrencia en Swift 6:

#### Funciones públicas `nonisolated`

**`insertOrUpdateManga(in:from:)`**
- Persiste un `MangaDTO` en SwiftData
- Busca o crea entidades relacionadas (Theme, Author, etc.)
- Actualiza si existe, crea si no existe

**`insertOrUpdateMangas(in:from:)`**
- Persiste múltiples mangas de una vez
- Guarda cambios al finalizar si hay modificaciones

**`insertOrUpdateManga(in:_:)`** (sobrecarga)
- Persiste una instancia `Manga` (@Model) creada con `.toManga`
- Persiste todas las relaciones primero, luego el manga

#### Funciones privadas auxiliares

- `fetchOrCreateThemes(in:from:)`
- `fetchOrCreateAuthors(in:from:)`
- `fetchOrCreateGenres(in:from:)`
- `fetchOrCreateDemographics(in:from:)`
- `updateManga(_:in:from:themes:authors:genres:demographics:)`
- `createManga(from:themes:authors:genres:demographics:)`
- `statusToString(_:)`: Convierte enum a String

**Ventajas:**
- ✅ Sin warnings de concurrencia en Swift 6
- ✅ Funcionan desde cualquier contexto de actor
- ✅ Evitan duplicación de código
- ✅ Centralizan lógica de persistencia

---

## Concurrencia y Aislamiento de Actores

### Uso de Actores

**`@ModelActor` (DataContainer)**
- Aislamiento de actor para operaciones seguras con SwiftData
- Acceso al `modelContext` desde contexto de actor
- Operaciones de carga/persistencia asíncronas

**`actor ImageDownloader`**
- Gestión segura de caché compartida
- Prevención de condiciones de carrera en descargas
- Estado mutable protegido por actor

**`@MainActor` (ViewModels y Views)**
- Garantiza actualizaciones de UI en hilo principal
- Todos los `@Observable` ViewModels aislados a `@MainActor`
- Todas las vistas SwiftUI ejecutan en `@MainActor`

### Funciones `nonisolated`

- **Funciones globales de persistencia**: Sin aislamiento de actor
- **Métodos de utilidad pura**: `statusToString`, `getFileURL`
- **Propiedades computadas de DTOs**: `mainPictureURL`, `urlCleaned`

---

## Navegación

### Estructura de Tabs (MainTab.swift)

```swift
TabView {
    ContentView()              // Tab 1: Todos los mangas
    SearchView()               // Tab 2: Búsqueda
    UserCollectionView()       // Tab 3: Mi colección
    FavoritesView()            // Tab 4: Favoritos (pendiente)
    UserProfileView()          // Tab 5: Perfil (pendiente)
}
```

### Navegación Jerárquica

- **NavigationStack** en vistas principales
- **NavigationDestination** para vistas de detalle
- **Sheet/FullScreenCover** para modales
- **Matched Geometry Effect** para animaciones hero

**Ejemplo:**
```swift
NavigationStack {
    List(mangas) { manga in
        NavigationLink(value: manga) {
            MangaRow(manga: manga)
        }
    }
    .navigationDestination(for: Manga.self) { manga in
        MangaView(manga: manga)
    }
}
```

---

## Gestión de Estado

### @Observable (Swift 6.2)

Reemplaza `ObservableObject` de versiones anteriores:
- Más eficiente
- Tracking automático de cambios
- No requiere `@Published`
- Mejor integración con Swift Concurrency

### @Query (SwiftData)

Consultas reactivas automáticas:
```swift
@Query private var mangas: [Manga]
@Query private var favorites: [FavoriteManga]
@Query(sort: \UserMangaCollection.dateAdded, order: .reverse)
private var collection: [UserMangaCollection]
```

### @Environment

Inyección de dependencias:
```swift
@Environment(\.modelContext) var context
@Environment(FavoritesViewModel.self) private var favoritesVM
```

---

## Optimizaciones

### Rendimiento de SwiftData

1. **Índices**: Campos de búsqueda frecuente tienen `#Index`
2. **Restricciones de unicidad**: `@Attribute(.unique)` en IDs
3. **FetchDescriptor con fetchLimit**: Limitar resultados innecesarios
4. **Lazy loading**: Solo cargar datos cuando se necesitan

### Caché de Imágenes

1. **Memoria**: Caché activa durante sesión de la app
2. **Disco**: Persistencia entre sesiones
3. **Redimensionamiento**: 300px de ancho para reducir espacio
4. **Limpieza automática**: Caché en memoria se libera tras guardar en disco

### Búsqueda con Debounce

```swift
var search = "" {
    didSet {
        searchTask?.cancel()
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }
            await searchMangasBeginsWith()
        }
    }
}
```

---

## Pruebas y Previews

### PreviewContainer

Contenedor en memoria para previews de SwiftUI:
```swift
#Preview(traits: .sampleData) {
    ContentView()
        .modelContainer(for: [Manga.self, FavoriteManga.self])
}
```

### PreviewData

Datos de prueba para desarrollo:
- 8 mangas de ejemplo (One Piece, Naruto, Death Note, etc.)
- Autores de prueba
- Géneros, temas y demografías de ejemplo

---

## Gestión de Errores

### NetworkError

Errores tipados con mensajes descriptivos:
```swift
do {
    let mangas = try await network.getBestMangas()
} catch let error as NetworkError {
    switch error {
    case .status(let code):
        print("HTTP \(code)")
    case .json(let jsonError):
        print("JSON error: \(jsonError)")
    default:
        print(error.localizedDescription)
    }
}
```

### Manejo en ViewModels

```swift
func loadBestMangas() async {
    isLoading = true
    errorMessage = nil

    do {
        bestMangas = try await network.getBestMangas()
    } catch {
        errorMessage = "No se pudieron cargar los mejores mangas"
    }

    isLoading = false
}
```

---

## Configuración de API

### Base URL
```
https://mymanga-acacademy-5607149ebe3d.herokuapp.com
```

### Endpoints Principales

| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/mangas` | Lista completa de mangas |
| GET | `/mangas?page={n}&itemsPerPage={m}` | Paginación |
| GET | `/mangas/best` | Mejores mangas |
| GET | `/mangas/{id}` | Manga por ID |
| GET | `/mangas/search/begins/{title}` | Búsqueda por inicio |
| GET | `/mangas/search/contains/{title}` | Búsqueda por contenido |
| GET | `/authors` | Lista de autores |
| GET | `/themes` | Lista de temas |
| GET | `/genres` | Lista de géneros |
| GET | `/demographics` | Lista de demografías |
| POST | `/search/custom` | Búsqueda personalizada |

---

## Próximas Mejoras

### Pendiente de Implementación

1. **FavoritesView completa**: Grid/List de favoritos con navegación
2. **UserProfileView**: Perfil de usuario y estadísticas
3. **Error States**: Vistas de error con botón de "Reintentar"
4. **Loading States**: Skeleton screens y shimmer effects
5. **Filtros**: Por género, tema, demographic, score
6. **Ordenación**: Por título, score, fecha
7. **iPad Layouts**: Sidebar, multi-columna
8. **Búsqueda avanzada**: CustomSearch implementation
9. **Offline mode**: Caché completo de datos
10. **Sincronización**: Backend para favoritos y colección

### Deuda Técnica

1. **NetworkError Sendable**: Conformar a Sendable para Swift 6
2. **POST requests**: Implementar método POST en URLRequest
3. **Logging**: Reemplazar prints por sistema de logging
4. **Tests**: Unit tests, integration tests, UI tests

---

## Convenciones de Código

### Nomenclatura

- **Clases y Structs**: PascalCase (`MangaDTO`, `NetworkError`)
- **Funciones y variables**: camelCase (`loadBestMangas`, `isLoading`)
- **Constantes**: camelCase (`actualPage`, `bestMangas`)
- **Enums**: PascalCase para tipo, camelCase para casos

### Documentación

- **`///`** para documentación de métodos, clases y propiedades públicas
- **`//`** para comentarios internos de implementación
- **`// MARK: -`** para secciones de código

### Organización de Archivos

- Un tipo principal por archivo
- Extensiones en el mismo archivo si son pequeñas
- Agrupar funcionalidad relacionada con `// MARK:`

---

## Recursos

### Documentación Oficial

- [Swift.org](https://swift.org)
- [SwiftUI Apple Docs](https://developer.apple.com/documentation/swiftui)
- [SwiftData Apple Docs](https://developer.apple.com/documentation/swiftdata)

### Herramientas

- **Xcode 16.1+**
- **iOS 26.1+ SDK**
- **Swift 6.2**

---

**Última actualización**: 22 de febrero de 2026
