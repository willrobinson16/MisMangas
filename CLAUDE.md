# CLAUDE.md

This file provides guidance to Claude Code when working with code in this repository.

## Project Overview

MisMangas is a SwiftUI iOS application for managing manga collections using Swift 6.2 with strict concurrency enabled.

- **Platform**: iOS 26.1+
- **Language**: Swift 6.2
- **Bundle ID**: `com.grobinson.MisMangas`
- **Development Team**: 2WATSHBXAF
- **Concurrency**: Complete concurrency checking enforced
- **APIs**: NO deprecated APIs allowed

## Architecture

The project follows clean architecture with clear separation of concerns:

```
MisMangas/
├── System/              - App entry point and configuration
├── DataModel/           - SwiftData models (@Model classes) and data actors
├── DTO/                 - Data Transfer Objects for network/API communication
├── Network/             - Network layer (errors, interactor, repository, endpoints)
├── ViewModel/           - ViewModels for complex view logic
├── Views/               - Full-screen SwiftUI views
├── Components/          - Reusable SwiftUI components
├── Search/              - Advanced search components (filters, multi-select views)
├── Extensions/          - Swift extensions and custom modifiers
├── ContentView.swift    - Main manga list view
└── MainTab.swift        - TabView navigation container
```

## Data Layer

### Dual-Model Approach

**Network Layer (DTOs)**: Data Transfer Objects in `DTO/` directory
- **Core DTOs**: `MangaDTO`, `AuthorDTO`, `ThemeDTO`, `GenreDTO`, `DemographicDTO`
- **Collection DTO**: `UserMangaCollectionDTO` (user's manga ownership & reading progress)
- **Pagination DTOs**: `MangaPageDTO`, `AuthorPageDTO`, `PageMetadataDTO`
- **Enums**: `MangaStatus`, `AuthorRole` with snake_case API mapping
- All conform to `Codable` and `Identifiable`
- DTOs include conversion methods (`toManga`, `toAuthor`, etc.)

**Persistence Layer (SwiftData)**: Models in `DataModel/` directory
- **Core Models**: `Manga`, `Author`, `Theme`, `Genre`, `Demographic`
- **User Data**: `FavoriteManga`, `UserMangaCollection`
- Use `@Model` macro with performance optimizations
- Unique constraints on IDs (`@Attribute(.unique)`)
- Indexes on searchable fields (`#Index`)
- Bidirectional relationships with cascade delete rules

**Data Mapping**: `DataContainer.swift` uses `@ModelActor` pattern
- Converts DTOs to SwiftData models
- Dictionary-based lookups to prevent duplicates
- Handles pagination with `@AppStorage`
- Integrates with NetworkRepository

### API Configuration

- **Base URL**: `https://mymanga-acacademy-5607149ebe3d.herokuapp.com`
- **Endpoints**: Type-safe definitions in `Network/URL.swift`
- **Categories**: List, filtered, search, authentication endpoints

## Swift Version & Features

- **Swift 6.2** with strict concurrency checking
- **Typed throws**: `throws(NetworkError)` for network operations
- **MainActor isolation** for UI components
- **Sendable** conformance for types crossing actor boundaries
- **SwiftData only** for persistence (no CoreData, Realm, etc.)
- **Modern patterns**: `@Observable`, `#Preview`, `async/await`

## Configuration Details

### Build Settings
- SwiftUI previews enabled
- Whole module optimization in Release
- Supports iPhone and iPad (TARGETED_DEVICE_FAMILY = "1,2")

### Deployment
- Minimum: iOS 26.1
- iPhone orientations: Portrait, Landscape Left/Right
- iPad orientations: All including upside-down

## Project Structure Guidelines

### Directory Organization

- **System/**: App entry point and configuration files
- **DataModel/**: SwiftData models (`@Model` macro) and data container actors
- **DTO/**: Data Transfer Objects for network/API communication (`Codable`)
- **Network/**: Network protocols, repository, URL definitions, image downloading
- **ViewModel/**: `@Observable` classes with `@MainActor` isolation
- **Views/**: Full-screen SwiftUI views
- **Components/**: Reusable SwiftUI components (use subdirectories for groups)
- **Extensions/**: Swift extensions and custom ViewModifiers

### Adding New Models

**Network DTOs** (for API responses):
- Conform to `Codable` and `Identifiable`
- Place in `DTO/` directory as separate files
- Use snake_case mapping for API fields via `CodingKeys` (e.g., `synopsis = "sypnosis"`)
- Include conversion methods when applicable (e.g., `toManga`, `toAuthor`)
- Use helper extensions like `String.cleanedURL` for URL sanitization
- Example files: `MangaDTO.swift`, `AuthorDTO.swift`, `UserMangaCollectionDTO.swift`

**SwiftData Models** (for persistence):
- Use `@Model` macro
- Place in `DataModel/` directory as separate files
- Add `Sendable` conformance if crossing actor boundaries
- Use `@MainActor` isolation for UI-bound models
- Include `@Attribute(.unique)` constraints on IDs
- Use `#Index` for searchable fields
- Add computed properties and test data in extensions
- Example files: `Model.swift`, `FavoriteManga.swift`, `UserMangaCollection.swift`

**DTO → Model Conversion**:
- Handled by `DataContainer` actor (`DataModel/DataContainer.swift`)
- Uses dictionary-based lookups to prevent duplicates
- Maintains relationships between entities (e.g., Manga ↔ Authors)
- DTOs include `toManga`, `toAuthor` methods for conversion

### Working with the Network Layer

**NetworkRepository Protocol**:
- Defined in `Network/Network.swift`
- Inherits from `NetworkInteractor` (from NetworkAPI package)
- All methods use `async throws` pattern
- 11+ endpoint methods implemented

**Adding New Endpoints**:
1. Define URL in `Network/URL.swift` (e.g., `case customSearch`)
2. Add method to `NetworkRepository` protocol
3. Implement in `Network` struct using `getJSON()` or `postJSON()`
4. Create corresponding DTO in `DTO/` directory if needed (e.g., `NewFeatureDTO.swift`)

## Implementation Status

### ✅ Completed

**Core Infrastructure**:
- SwiftData models: Manga, Author, Theme, Genre, Demographic, FavoriteManga, UserMangaCollection
- DTOs reorganized in separate directory: MangaDTO, AuthorDTO, UserMangaCollectionDTO, pagination DTOs
- Enums: MangaStatus, AuthorRole with proper API mapping
- Network layer consolidated in Network.swift (from NetworkAPI package)
- NetworkRepository with 11+ API methods
- DataContainer with DTO→SwiftData mapping
- String extensions (cleanedURL, formattedDate for ISO 8601)
- ModelContext persistence functions (nonisolated global functions)

**Views (iPhone)**:
- ContentView with infinite scroll and pull-to-refresh
- MangaView detail screen - REDISEÑADA (hero header, synopsis expandible, layout estilo revista)
- SearchView with advanced search functionality (title, author, genres, themes, demographics)
- UserCollectionView with list/grid modes, filters (authors, genres, demographics, themes)
- EditCollectionSheet for managing collection entries
- AuthorsListView - Lista paginada de autores con @Query
- AuthorDetailView - Vista detalle con mangas del autor
- FavoritesView - Gestión de favoritos
- UserProfileView - Perfil y estadísticas
- MainTab navigation structure (4 tabs)

**Views (iPad)** - Layouts adaptativos completos:
- ContentViewiPad - Grid multi-columna adaptativo
- AuthorsListViewiPad - NavigationSplitView con sidebar de autores
- AuthorDetailViewiPad - Grid layout para mangas del autor
- SearchViewiPad - Grid layout para resultados
- UserCollectionViewiPad - Rows enriquecidos con información completa
- UserProfileViewiPad - Layout adaptativo para estadísticas

**Search Components** (Search/ directory):
- AdvancedSearchFiltersSheet - Main filters sheet with multiple sections
- MultiSelectGenresView - Multi-selection for genres with checkmarks
- MultiSelectThemesView - Multi-selection for themes with checkmarks
- MultiSelectDemographicsView - Multi-selection for demographics with checkmarks
- FilterChip - Visual chip component for active filters

**Components**:
- MangaRow, MangaGridView for list/grid display
- AuthorRow, MangaByAuthorRow for author/manga display
- CollectionEntryRow, CollectionGridCard for collection items
- CurrentlyReadingRow, CompleteMangaCard for user profile
- VolumeChip, StatCard for detailed info
- RatingView with partial star support
- MainPictureView, BackgroundPictureView with async loading
- StretchModifier for parallax effects
- MangaSwipeActionsModifier for consistent swipe actions

**ViewModels**:
- SearchViewModel with advanced search (title, author, genres, themes, demographics, debounce)
- FavoritesViewModel for favorites management
- UserCollectionViewModel for user's manga collection (volumes owned, reading progress)
- AuthorsViewModel for author pagination
- AuthorDetailViewModel with shared cache for mangas by author
- MainPictureVM for image caching
- BestMangasViewModel for content management

**Data Flow**:
- Pagination with @AppStorage persistence
- Preview system with sample data (8 manga entries)
- Hero animations with matched geometry
- Search by title (begins with)

### ❌ Pending Implementation

**Views**:
- User authentication views (login, register)

**Network**:
- User authentication endpoints implementation (register, login, token renewal)
- Token storage and session management

**Features**:
- Error state views with retry mechanism
- Loading state improvements (skeleton screens, shimmer)
- Sort controls in ContentView (by score, date, title)
- User authentication system (login, register, session management)
- Cloud sync for user collection (requires authentication)
- Scroll infinito en SearchView (paginación ready)

### 🔍 Recent Changes

**iPad Support + MangaView Redesign** (2026-02-25 - Sesión madrugada):
- **6 vistas iPad completas** (1,915 líneas): NavigationSplitView, grid layouts adaptativos
- **MangaView rediseñada** (582 líneas): hero header, synopsis expandible, layout estilo revista
- **Sistema de Autores completo**: AuthorsListView, AuthorDetailView, ViewModels con cache
- **Optimizaciones**: Cache compartido en AuthorDetailViewModel, formattedDate extension
- **22 archivos modificados**: +2,789 líneas / -137 líneas
- **Issues conocidos**: EditCollectionSheet no carga en primer intento, warning "Modifying state during view update"

**Network Layer Refactoring** (2026-02-25):
- Consolidado Network.swift desde NetworkAPI package
- Eliminados 7 archivos obsoletos (-554 líneas)
- Funciones de persistencia ahora son nonisolated global functions (Swift 6 compliance)

**Advanced Search Implementation** (2026-02-24):
- New `/Search/` directory with 6 components
- SearchViewModel expanded with 7+ filters (title, author, genres, themes, demographics, contains)
- CustomSearch POST endpoint with pagination (page, per parameters)
- UI híbrida: chips visuales + sheet de filtros
- Liquid Glass design: toolbar buttons with icons only
- Network layer fixes: double encoding resolved, simplified list methods
- getGenres/getThemes/getDemographics now return [String] directly

**Architecture Changes** (2026-02-15):
- DTOs reorganized from `Model/` to `DTO/` directory with separate files per DTO
- New enums: `MangaStatus`, `AuthorRole` with proper API mapping
- New DTO: `UserMangaCollectionDTO` for user collection data
- Pagination DTOs: `MangaPageDTO`, `AuthorPageDTO`, `PageMetadataDTO`
- String extensions: `cleanedURL` for URL sanitization

**New Models** (2026-02-15):
- `UserMangaCollection` - SwiftData model for user's manga collection
  - Tracks volumes owned, reading progress, complete collection status
  - Includes computed properties for progress tracking

**New ViewModels** (2026-02-15):
- `UserCollectionViewModel` - Manages user's manga collection
  - Collection management (add/remove manga)
  - Reading progress tracking (current volume, progress percentage)
  - Volume ownership management (add/remove specific volumes)
  - Statistics (total volumes, complete collections, currently reading)

**Latest Commits**:
- `e92c047` - "Limpieza de archivos obsoletos tras refactorización del Network layer"
- `dcd4f91` - "Añadidas vistas optimizadas para iPad y mejoras visuales en MangaView"

## User Collection System

### Overview

The app includes a comprehensive system for tracking the user's manga collection, including ownership and reading progress.

### UserMangaCollection Model

**Location**: `DataModel/UserMangaCollection.swift`

**Properties**:
- `id: UUID` - Unique identifier (indexed)
- `mangaID: Int` - Reference to the manga (indexed)
- `readingVolume: Int?` - Current volume being read
- `completeCollection: Bool` - Whether user owns complete collection
- `volumesOwned: [Int]` - Array of owned volume numbers
- `dateAdded: Date` - When added to collection
- `lastUpdated: Date` - Last modification timestamp

**Computed Properties**:
- `volumesOwnedCount: Int` - Total volumes owned
- `hasStartedReading: Bool` - Whether reading has started
- `readingProgress(totalVolumes:) -> Double?` - Reading progress percentage
- `collectionProgress(totalVolumes:) -> Double?` - Collection completion percentage
- `ownsVolume(_ volumeNumber: Int) -> Bool` - Check specific volume ownership

**DTO Conversion**:
- `toDTO(manga:) -> UserMangaCollectionDTO` - Converts to DTO for API
- `static from(_ dto: UserMangaCollectionDTO) -> UserMangaCollection` - Creates from DTO

### UserCollectionViewModel

**Location**: `ViewModel/UserCollectionViewModel.swift`

**Pattern**: `@Observable @MainActor` with injected `ModelContext`

**Collection Management**:
- `addToCollection(manga:volumes:)` - Add manga to collection
- `removeFromCollection(_ mangaID:)` - Remove manga from collection
- `isInCollection(_ mangaID:) -> Bool` - Check if manga is in collection
- `getCollectionEntry(_ mangaID:) -> UserMangaCollection?` - Get collection entry

**Reading Progress**:
- `updateReadingVolume(mangaID:volume:)` - Update current reading volume
- `readNextVolume(mangaID:)` - Mark next volume as being read
- `getCurrentReadingVolume(_ mangaID:) -> Int?` - Get current reading volume

**Volume Ownership**:
- `addVolume(mangaID:volumeNumber:)` - Add a single volume
- `removeVolume(mangaID:volumeNumber:)` - Remove a volume
- `addVolumes(mangaID:volumes:)` - Add multiple volumes at once
- `ownsVolume(mangaID:volumeNumber:) -> Bool` - Check volume ownership
- `getOwnedVolumes(_ mangaID:) -> [Int]` - Get all owned volumes

**Complete Collection**:
- `toggleCompleteCollection(mangaID:)` - Toggle complete collection flag
- `setCompleteCollection(mangaID:isComplete:)` - Set complete collection flag
- `hasCompleteCollection(_ mangaID:) -> Bool` - Check if complete

**Statistics**:
- `collectionCount() -> Int` - Total manga in collection
- `totalVolumesOwned() -> Int` - Total volumes across all manga
- `completeCollectionsCount() -> Int` - Count of complete collections
- `currentlyReadingCount() -> Int` - Count of manga being read
- `readingProgress(mangaID:totalVolumes:) -> Double?` - Reading progress
- `collectionProgress(mangaID:totalVolumes:) -> Double?` - Collection progress

### Usage Pattern

```swift
// In a View
@Environment(\.modelContext) private var modelContext
@State private var collectionVM = UserCollectionViewModel()

var body: some View {
    // ...
    .onAppear {
        collectionVM.setModelContext(modelContext)
    }
}

// Add to collection
collectionVM.addToCollection(manga: someManga, volumes: [1, 2, 3])

// Update reading progress
collectionVM.updateReadingVolume(mangaID: mangaID, volume: 5)

// Add a volume
collectionVM.addVolume(mangaID: mangaID, volumeNumber: 6)

// Check progress
if let progress = collectionVM.readingProgress(mangaID: mangaID, totalVolumes: manga.volumes) {
    // Display progress
}
```

## Code Quality Requirements

1. **NO Deprecated APIs**: Always use latest non-deprecated alternatives
2. **Strict Concurrency**: Must pass Swift 6.2 checking with zero warnings
3. **Actor Isolation**: `@MainActor` for UI, custom actors for background work
4. **Sendable Types**: Required for types crossing concurrency boundaries
5. **SwiftData Only**: No CoreData, Realm, or other persistence frameworks

## Swift 6.2 Best Practices

### Concurrency Patterns

- UI components and ViewModels: `@MainActor` isolated
- Network/data processing: Custom actors or `Task` for concurrency
- Always `await` when crossing actor boundaries
- Use typed throws for better error handling

### Avoiding Deprecated APIs

- ✅ `@Observable` (not `ObservableObject`)
- ✅ `#Preview` macro (not `PreviewProvider`)
- ✅ `async/await` (not completion handlers)
- ✅ SwiftData `ModelContext` (not CoreData `NSManagedObjectContext`)

## Known Issues & TODOs

### Critical
1. **NetworkError Sendable Conformance**: NetworkError doesn't conform to Sendable (Swift 6.2 strict concurrency requirement)
2. **Local Package Dependency**: NetworkAPI is a local package in iCloud Drive - may cause issues on different machines

### Implementation TODOs
1. **Network/URLRequest.swift**: POST method implementation commented out (authentication methods)
2. **MainTab.swift**: Placeholder views for iPad and additional tabs (empty implementations)
3. **Error Logging**: Replace print statements with proper logging framework
4. **Untracked Assets**: New icon files (`fondo_*.png`, `logoM.png`) in root need to be added to project or moved to Assets.xcassets
5. **SearchView Pagination**: Implement infinite scroll for search results (pagination ready)

## Testing

- **PreviewContainer.swift**: Modern `PreviewModifier` with in-memory ModelContainer
- **PreviewData.swift**: 8 sample manga entries for testing
- **PreviewTrait**: Custom `.sampleData` trait for `#Preview`

## Common Commands

### Building & Running

```bash
# Build the project
xcodebuild -scheme MisMangas -configuration Debug build

# Build for Release
xcodebuild -scheme MisMangas -configuration Release build

# Clean build folder
xcodebuild -scheme MisMangas clean

# Open in Xcode
open MisMangas.xcodeproj
```

### Running on Simulators

```bash
# List available simulators
xcrun simctl list devices available

# Run on specific simulator (after building)
xcodebuild -scheme MisMangas -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build

# Or simply open project in Xcode and use Cmd+R to run
```

### SwiftUI Previews

SwiftUI previews are enabled in the project. Use Xcode's preview canvas (Cmd+Option+Return) to view component previews. All views use the modern `#Preview` macro with the custom `.sampleData` trait for testing.

### Checking Swift Version

```bash
swift --version  # Should show Swift 6.2
xcodebuild -version  # Should show Xcode 26.2+
```

## Dependencies

### NetworkAPI (Local Swift Package)

- **Location**: `~/Library/Mobile Documents/com~apple~CloudDocs/Swift Develope/NetworkAPI`
- **Type**: Local Swift Package via XCLocalSwiftPackageReference
- **Purpose**: Provides `NetworkInteractor` protocol and networking utilities
- **Key Types**:
  - `NetworkInteractor`: Base protocol for network operations
  - Used by `Network` struct in `Network/Network.swift`

**Important**: This is a local package dependency. If you encounter build errors related to NetworkAPI, verify the package exists at the specified iCloud Drive path.

---

## PLAN DE DESARROLLO

Este plan organiza el desarrollo restante de la app en fases progresivas.

### FASE 1: Completar Funcionalidades Básicas 🎯
**Prioridad**: ALTA | **Estimación**: 1-2 días

#### 1.1 UserCollectionView ✅ COMPLETADA
- [x] Implementar lista/grid usando `@Query` de UserMangaCollection
- [x] Toggle entre vista lista y grid
- [x] Navegación con EditCollectionSheet
- [x] Empty state cuando no hay mangas
- [x] Filtros por autores, géneros, demographics, temas
- [x] Swipe actions y context menu
- [x] Gestión de volúmenes y progreso de lectura

#### 1.2 ListByAuthors View ✅ COMPLETADA
- [x] Lista de autores con SwiftData @Query
- [x] Navegación a lista de mangas del autor seleccionado
- [x] Contador de mangas por autor (en AuthorDetailViewModel)
- [x] Paginación de autores (AuthorsViewModel)
- [x] Layouts iPhone + iPad (NavigationSplitView)
- [x] Integración con endpoint `getMangaByAuthor`
- [x] Cache compartido para eficiencia (AuthorDetailViewModel)

#### 1.3 User Authentication System (SIGUIENTE PRIORIDAD)
- [ ] Implementar POST request en URLRequest.swift
- [ ] Endpoints de autenticación (register, login, renewToken)
- [ ] UserAuthViewModel para gestión de sesión
- [ ] Login/Register views
- [ ] Token storage seguro (Keychain)
- [ ] Session persistence

### FASE 2: Mejorar MangaView (Detalle) ✅ COMPLETADA
**Prioridad**: ALTA | **Completada**: 2026-02-25

#### 2.1 Información Completa ✅
- [x] Mostrar synopsis completa (expandible/colapsable)
- [x] Mostrar capítulos y volúmenes
- [x] Mostrar fecha de inicio/fin (formato DD-MM-YYYY)
- [x] Mostrar demographics (Shounen, Seinen, etc.) con chips
- [x] Mostrar temas (tags) en FlowLayout custom
- [x] Mostrar géneros en FlowLayout custom
- [x] Status badge con colores según estado

#### 2.2 Mejoras Visuales ✅
- [x] Layout estilo revista con hero header
- [x] Secciones organizadas con iconos
- [x] Tipografía y espaciado mejorados
- [x] Gradient overlay en hero image
- [x] Rating centrado con RatingView

### FASE 3: Estados de Error y Carga ⚠️
**Prioridad**: MEDIA | **Estimación**: 1 día

#### 3.1 Error Handling
- [ ] Error state en ContentView (sin conexión, error API)
- [ ] Botón de "Retry" en error states
- [ ] Error state en SearchView
- [ ] Toast/Alert para errores transitorios
- [ ] Logging de errores

#### 3.2 Loading States
- [ ] Skeleton screens para ContentView
- [ ] Loading indicator para SearchView
- [ ] Shimmer effect opcional
- [ ] Progress indicator en infinite scroll más visible

### FASE 4: Filtros y Ordenación 🔍
**Prioridad**: MEDIA | **Estimación**: 1-2 días

#### 4.1 Filtros
- [ ] Filtro por género (modal/sheet)
- [ ] Filtro por demographic
- [ ] Filtro por tema
- [ ] Filtro por estado de publicación
- [ ] Filtro por rango de score
- [ ] Aplicar múltiples filtros
- [ ] Limpiar filtros

#### 4.2 Ordenación
- [ ] Ordenar por score (descendente/ascendente)
- [ ] Ordenar por título (A-Z, Z-A)
- [ ] Ordenar por fecha de publicación
- [ ] Ordenar por número de capítulos
- [ ] Picker/Menu para seleccionar orden

#### 4.3 UI de Filtros
- [ ] Sheet con opciones de filtro
- [ ] Indicador visual de filtros activos
- [ ] Botón de filtros en toolbar

### FASE 5: iPad & Layouts Adaptativos ✅ COMPLETADA
**Prioridad**: MEDIA-BAJA | **Completada**: 2026-02-25

#### 5.1 iPad Layout ✅
- [x] Sidebar navigation para iPad (NavigationSplitView)
- [x] Master-detail layout (AuthorsListViewiPad)
- [x] Grid multi-columna adaptativo (2-3-4 columnas)
- [x] 6 vistas iPad completas (1,915 líneas)
- [x] Detección automática de dispositivo (UIDevice.current.userInterfaceIdiom)

#### 5.2 Responsive Design ✅
- [x] Layouts adaptativos por dispositivo
- [x] Grid columns adaptativas según tamaño
- [x] Spacing y padding optimizados
- [x] NavigationStack (iPhone) vs NavigationSplitView (iPad)

### FASE 6: Búsqueda Avanzada 🔎 ✅ COMPLETADA
**Prioridad**: BAJA | **Estimación**: 1 día

#### 6.1 Mejoras de Búsqueda
- [x] Integrar `searchMangasContains` (búsqueda parcial) - implementado con toggle
- [x] Debounce en búsqueda (optimización) - 500ms debounce
- [x] Búsqueda por autor - nombre y apellido
- [ ] Historial de búsquedas recientes
- [ ] Sugerencias de búsqueda

#### 6.2 CustomSearch ✅ COMPLETADA
- [x] Implementar CustomSearch struct
- [x] POST request con paginación (page, per)
- [x] Endpoint customSearch en NetworkRepository
- [x] UI para búsqueda avanzada multi-criterio
- [x] Filtros: título, autor, géneros, temas, demografías
- [x] UI híbrida: chips visuales + sheet de filtros
- [x] MultiSelect views con checkmarks (Liquid Glass design)
- [x] Corrección de doble encoding en POST request

### FASE 7: Pulido Final ✨
**Prioridad**: BAJA | **Estimación**: 1-2 días

#### 7.1 Animaciones
- [ ] Transiciones mejoradas entre vistas
- [ ] Animaciones de lista (insert/delete)
- [ ] Spring animations en interacciones
- [ ] Loading animations personalizadas

#### 7.2 Accesibilidad
- [ ] VoiceOver labels
- [ ] Dynamic Type support
- [ ] Contrast mejorado
- [ ] Accessibility identifiers para testing

#### 7.3 Rendimiento
- [ ] Optimización de imágenes
- [ ] Lazy loading mejorado
- [ ] Cache management
- [ ] Memory footprint analysis

#### 7.4 Testing
- [ ] Unit tests para ViewModels
- [ ] Integration tests para Network layer
- [ ] UI tests para flujos principales
- [ ] Snapshot tests

---

## PRIORIZACIÓN RECOMENDADA

### Sprint 1 (Semana 1) ✅ COMPLETADO
1. ✅ UserCollectionView completa (lista/grid, filtros, gestión de volúmenes)
2. ✅ ListByAuthors completa (AuthorsListView + AuthorDetailView + ViewModels)
3. ✅ MangaView rediseñada (hero header, synopsis expandible, layout profesional)
4. ✅ iPad layouts completos (6 vistas adaptativas)
5. ✅ Búsqueda avanzada (7+ filtros, UI híbrida)

### Sprint 2 (Semana 2) - EN PROGRESO
1. ⏳ User Authentication System (SIGUIENTE PRIORIDAD)
   - Endpoints de autenticación
   - Login/Register views
   - Token storage (Keychain)
   - Session management
2. ⏳ Scroll infinito en SearchView
3. ⏳ Error handling completo con retry
4. ⏳ Loading states mejorados (skeleton screens)

### Sprint 3 (Semana 3) - PENDIENTE
1. ⏳ Filtros y ordenación en ContentView
2. ⏳ Cloud sync de colección (requiere auth)
3. ⏳ Pulido visual y animaciones
4. ⏳ Testing básico

---

## NOTAS DE DESARROLLO

### Decisiones Técnicas Pendientes
- [ ] ¿Persistir filtros/ordenación entre sesiones?
- [ ] ¿Implementar cache offline para mangas favoritos?
- [ ] ¿Sincronización con backend para favoritos?
- [ ] ¿Analytics/tracking de uso?

### Deuda Técnica Conocida
1. NetworkError no conforme a Sendable (Swift 6.2 compliance)
2. POST method comentado en URLRequest.swift
3. Error handling con prints (reemplazar por logging apropiado)
4. Algunos componentes sin tests

### Documentación
- ✅ **ARQUITECTURA.md** (600+ líneas): Documento completo de arquitectura del proyecto
- ✅ **DOCUMENTACION_RESUMEN.md**: Índice de toda la documentación realizada
- ✅ **Comentarios `///`**: 18+ archivos documentados con comentarios DocC-compatible
  - DataModel: Model.swift, FavoriteManga.swift, DataContainer.swift
  - ViewModels: BestMangasViewModel, SearchViewModel, FavoritesViewModel
  - Network: NetworkRepository.swift (mejorado)
  - DTOs: MangaDTO, AuthorDTO, ThemeDTO, GenreDTO, DemographicDTO, MangaPageDTO, MangaStatus
  - Extensions: ModelContext+MangaPersistence (verificado)

---

## HISTORIAL DE SESIONES

### Sesión 2026-02-03: Documentación y Planificación

**Objetivo**: Limpieza de documentación y creación de plan de desarrollo estructurado

**Cambios realizados**:
1. ✅ Limpieza masiva de CLAUDE.md
   - Reducción de 972 líneas a 183 líneas base (81% de reducción)
   - Eliminación de todo código de ejemplo (~220 líneas de Swift)
   - Eliminación de Session History completa (~280 líneas)
   - Eliminación de Build Commands (~30 líneas)
   - Simplificación de todas las secciones a información estructural esencial

2. ✅ Actualización del estado del proyecto
   - Documentados nuevos componentes: SearchView, SearchViewModel, MangaGridView, AuthorRow
   - Actualizado estado de FavoriteManga model
   - Identificados componentes en progreso: ListByAuthors, FavoritesView

3. ✅ Creación de PLAN DE DESARROLLO completo
   - 7 fases estructuradas con tasks específicas
   - 3 sprints recomendados (roadmap de 3 semanas)
   - Priorización: ALTA, MEDIA, MEDIA-BAJA, BAJA
   - Total: ~200 líneas de plan estructurado

**Estructura del Plan**:
- FASE 1: Completar Funcionalidades Básicas (FavoritesView, ListByAuthors)
- FASE 2: Mejorar MangaView (información completa, mejoras visuales)
- FASE 3: Estados de Error y Carga
- FASE 4: Filtros y Ordenación
- FASE 5: iPad & Layouts Adaptativos
- FASE 6: Búsqueda Avanzada
- FASE 7: Pulido Final (animaciones, accesibilidad, testing)

**Resultado**:
- Documento CLAUDE.md final: 388 líneas
- Documento limpio, mantenible y estructurado
- Plan de desarrollo claro y accionable

**Próximos Pasos** (ACTUALIZADOS 2026-02-22):
- ✅ UserCollectionView completada con filtros y gestión completa
- ⏳ SIGUIENTE: Implementar ListByAuthors con navegación y contador de mangas
- ⏳ DESPUÉS: Sistema de autenticación de usuario (POST requests, login, register)
- ⏳ Cloud sync de colección de usuario con backend

### Sesión 2026-02-22: Documentación Completa y Refactorización de Concurrencia

**Objetivo**: Documentar todo el proyecto y solucionar warnings de concurrencia Swift 6

**Cambios realizados**:

1. ✅ **Solución de Warnings de Concurrencia Swift 6**
   - Refactorización de `ModelContext+MangaPersistence.swift`
   - Cambio de extension methods a funciones globales `nonisolated`
   - Eliminación completa de warnings de data races
   - Patrón: `context.insertOrUpdateManga(from:)` → `insertOrUpdateManga(in: context, from:)`
   - ✅ **BUILD SUCCEEDED** con ZERO warnings de código

2. ✅ **Documentación Masiva del Proyecto** (18+ archivos)

   **DataModel** (4 archivos):
   - `Model.swift`: Documentados Manga, Author, Theme, Genre, Demographic con características y relaciones
   - `FavoriteManga.swift`: Documentado con ejemplo de uso
   - `DataContainer.swift`: Cada método documentado con parámetros, returns y throws
   - `UserMangaCollection.swift`: Verificado (ya bien documentado)

   **ViewModels** (4 archivos):
   - `BestMangasViewModel.swift`: Documentado con características y ejemplos SwiftUI
   - `SearchViewModel.swift`: Documentado incluyendo explicación de debounce
   - `FavoritesViewModel.swift`: Todas las funciones CRUD documentadas
   - `UserCollectionViewModel.swift`: Verificado (ya bien documentado)

   **Network** (3 archivos):
   - `NetworkRepository.swift`: Mejorado con documentación completa de endpoints
   - `NetworkError.swift`: Verificado (bien documentado)
   - `ImageDownloader.swift`: Verificado (excelente documentación previa)

   **DTOs** (7 archivos):
   - `MangaDTO.swift`: Documentado con explicación de conversión y campos especiales
   - `AuthorDTO.swift`: Documentado completamente
   - `ThemeDTO.swift`: Documentado con ejemplo JSON
   - `GenreDTO.swift`: Documentado con ejemplo JSON
   - `DemographicDTO.swift`: Documentado con ejemplo JSON
   - `MangaPageDTO.swift`: Documentado con estructura de paginación
   - `MangaStatus.swift`: Todos los estados documentados

3. ✅ **Creación de Documentación de Arquitectura**

   **ARQUITECTURA.md** (600+ líneas):
   - Descripción general del proyecto y tecnologías
   - Estructura completa de directorios con explicaciones
   - Capas de arquitectura detalladas (Presentación, Datos, DTOs)
   - Flujos de datos completos (carga, búsqueda, favoritos, colección)
   - Persistencia con funciones globales explicadas
   - Concurrencia y aislamiento de actores
   - Navegación y gestión de estado
   - Optimizaciones implementadas
   - Configuración de API con tabla de endpoints
   - Próximas mejoras y deuda técnica
   - Convenciones de código

   **DOCUMENTACION_RESUMEN.md**:
   - Índice completo de archivos documentados
   - Estadísticas de documentación
   - Formato utilizado
   - Verificación de compilación
   - Beneficios de la documentación

4. ✅ **Mejoras Arquitectónicas**
   - Funciones globales `nonisolated` para persistencia
   - Compatible con @ModelActor y @MainActor
   - Sin problemas de data races
   - Código más limpio y mantenible

**Estructura de Documentación**:
- Comentarios `///` en todo el código (DocC-compatible)
- Documentación completa de clases, structs, métodos, propiedades
- Ejemplos de uso incluidos donde es relevante
- Parámetros, returns y throws documentados
- Secciones MARK para organización

**Resultado**:
- ✅ **18 archivos** con documentación completa en español
- ✅ **2 documentos MD** nuevos (ARQUITECTURA.md, DOCUMENTACION_RESUMEN.md)
- ✅ **ZERO warnings** de concurrencia Swift 6
- ✅ **BUILD SUCCEEDED** sin errores
- ✅ Proyecto completamente documentado y listo para desarrollo

**Próximos Pasos** (Planificación actualizada):
- ✅ **UserCollectionView**: Vista completada con lista/grid, filtros avanzados, gestión de volúmenes
- ⏳ **ListByAuthors**: Próxima vista a implementar
  - Lista de autores desde SwiftData
  - Navegación a mangas del autor
  - Contador de obras por autor
  - Secciones alfabéticas
- ⏳ **Sistema de Autenticación**:
  - POST requests en URLRequest.swift
  - Endpoints: register, login, renewToken
  - UserAuthViewModel
  - Login/Register views
  - Almacenamiento seguro de tokens
- ⏳ **Sincronización Cloud**: Integrar colección de usuario con backend (requiere auth)

### Sesión 2026-02-25: Implementación Masiva de iPad + Sistema de Autores

**Objetivo**: Completar soporte iPad y sistema completo de autores (FASE 1.2, FASE 2, FASE 5)

**Cambios realizados**:

1. ✅ **6 Vistas iPad Completas** (+1,915 líneas)
   - `ContentViewiPad.swift` (135 líneas) - Grid multi-columna adaptativo
   - `AuthorsListViewiPad.swift` (118 líneas) - NavigationSplitView con sidebar
   - `AuthorDetailViewiPad.swift` (219 líneas) - Grid layout para mangas del autor
   - `SearchViewiPad.swift` (172 líneas) - Grid de resultados de búsqueda
   - `UserCollectionViewiPad.swift` (591 líneas) - Rows enriquecidos con info completa
   - `UserProfileViewiPad.swift` (680 líneas) - Estadísticas adaptativas
   - Detección automática de dispositivo en todas las vistas principales

2. ✅ **Sistema Completo de Autores** (FASE 1.2 COMPLETADA)
   - `AuthorsListView.swift` - Lista paginada con @Query y ordenación alfabética
   - `AuthorDetailView.swift` - Vista detalle con layouts iPhone + iPad
   - `AuthorsViewModel.swift` - Paginación de autores con DataContainer
   - `AuthorDetailViewModel.swift` - Cache compartido estático para eficiencia
   - `AuthorRow.swift`, `MangaByAuthorRow.swift` - Componentes de UI
   - Integración con endpoint `getMangaByAuthor`
   - Navegación completa entre vistas

3. ✅ **MangaView Rediseñada** (FASE 2 COMPLETADA - 582 líneas)
   - Hero image header con gradient overlay
   - Layout estilo revista profesional
   - Synopsis expandible/colapsable con "Leer más"
   - FlowLayout custom para chips (géneros, temas, demographics)
   - Status badge con colores según estado
   - Fechas formateadas (DD-MM-YYYY) con `formattedDate` extension
   - Rating centrado con RatingView
   - Secciones organizadas: synopsis, autores, géneros, temas, demographics
   - Botones de acción con sizing consistente

4. ✅ **Optimizaciones y Mejoras**
   - **Cache compartido**: AuthorDetailViewModel usa cache estático entre vistas
   - **StringExtensions**: nuevo método `formattedDate` para ISO 8601
   - **SearchViewModel**: manejo de búsquedas canceladas
   - **Model.swift**: índices optimizados en SwiftData
   - **MainTab.swift**: integración de tab de autores (4 tabs totales)
   - **CollectionEntryRow**: indicadores visuales mejorados

5. ✅ **Refactorización Network Layer** (sesión posterior)
   - Consolidado `Network.swift` desde NetworkAPI package
   - Eliminados 7 archivos obsoletos:
     - ImageDownloader.swift, NetworkError.swift
     - NetworkInteractor.swift, NetworkRepository.swift
     - URLRequest.swift, URLSession.swift
     - MangasViewModel.swift
   - Funciones de persistencia ahora `nonisolated global functions`
   - Swift 6 concurrency compliance completo

**Estadísticas**:
- **Commit dcd4f91**: +2,789 líneas / -137 líneas (22 archivos modificados)
- **Commit e92c047**: -554 líneas (7 archivos eliminados)
- **Total**: 1,915 líneas de código iPad + 582 líneas MangaView

**Issues Conocidos**:
- `EditCollectionSheet` no carga datos en el primer intento
- Warning "Modifying state during view update" en consola

**Resultado**:
- ✅ **FASE 1.2 (Autores)**: 100% completada
- ✅ **FASE 2 (MangaView)**: 100% completada
- ✅ **FASE 5 (iPad)**: 100% completada
- ✅ Sprint 1 del plan: COMPLETADO

**Próximos Pasos**:
- ⏳ FASE 1.3: Sistema de autenticación de usuario (SIGUIENTE PRIORIDAD)
- ⏳ Scroll infinito en SearchView
- ⏳ Fix de EditCollectionSheet (bug conocido)
- ⏳ Error handling completo con retry

### Sesión 2026-02-24: Implementación de Búsqueda Avanzada

**Objetivo**: Implementar sistema completo de búsqueda avanzada con múltiples filtros y UI híbrida

**Cambios realizados**:

1. ✅ **Reorganización de Archivos de Búsqueda**
   - Creada carpeta `/Search/` para componentes de búsqueda
   - SearchView.swift movido a Search/
   - SearchViewModel.swift se mantiene en ViewModel/ (decisión del usuario)
   - Nueva estructura organizativa para búsqueda

2. ✅ **Expansión de SearchViewModel**
   - Agregados filtros avanzados:
     - `searchTitle` con debounce de 500ms
     - `authorFirstName` y `authorLastName` para búsqueda por autor
     - `selectedGenres: Set<String>` - multi-selección de géneros
     - `selectedThemes: Set<String>` - multi-selección de temas
     - `selectedDemographics: Set<String>` - multi-selección de demografías
     - `useContains: Bool` - toggle entre "begins with" y "contains"
   - Método `performSearch()` usando `network.customSearch()`
   - Propiedades computadas:
     - `hasActiveFilters` - detecta filtros activos
     - `activeFiltersCount` - cuenta filtros
     - `activeFilterChips` - genera etiquetas para chips
   - Métodos de gestión:
     - `removeFilter()` - elimina filtro específico
     - `clearAllFilters()` - limpia todos los filtros

3. ✅ **Componentes de UI Creados**

   **FilterChip.swift**:
   - Chip visual en forma de cápsula
   - Botón X para eliminar filtro
   - Diseño Liquid Glass

   **MultiSelectGenresView.swift**:
   - Sheet con lista de géneros
   - Checkmarks para selección múltiple
   - Carga géneros desde API (`network.getGenres()`)
   - Estados: loading, empty, content
   - Toolbar con X (cancel) y checkmark (confirm)

   **MultiSelectThemesView.swift**:
   - Sheet con lista de temas
   - Mismo patrón que géneros
   - Carga temas desde API (`network.getThemes()`)

   **MultiSelectDemographicsView.swift**:
   - Sheet con lista de demografías
   - Mismo patrón que géneros/temas
   - Carga demografías desde API (`network.getDemographics()`)

   **AdvancedSearchFiltersSheet.swift**:
   - Sheet principal de filtros avanzados
   - Secciones organizadas con Form:
     - Autor (nombre y apellido)
     - Géneros (botón + lista con X)
     - Temas (botón + lista con X)
     - Demografías (botón + lista con X)
     - Opciones (toggle búsqueda flexible)
   - Navegación entre sheets de selección

4. ✅ **Modificación de SearchView**
   - UI híbrida implementada:
     - Chips horizontales para filtros activos (con botón X)
     - Botón "Limpiar todo" para eliminar todos los filtros
     - Botón de toolbar con badge numérico
     - Icono multicolor cuando hay filtros activos
     - Sheet de filtros avanzados
   - Empty states:
     - Estado inicial: sugerencia para usar filtros
     - Sin resultados: mensaje específico
   - Lista de resultados con navegación a MangaView
   - Swipe actions para favoritos y colección

5. ✅ **Correcciones Técnicas en Network Layer**

   **Doble Encoding Solucionado**:
   - Problema: `customSearch()` encodaba dos veces el body
   - Primera encoding: `JSONEncoder().encode(search)` → Data
   - Segunda encoding: `.post()` encodaba Data como string
   - Resultado: servidor recibía string JSON escapado
   - Solución: pasar objeto directamente a `.post()`
   - Error 400 resuelto

   **Métodos de Lista Simplificados**:
   - `getGenres() -> [String]` (antes `[GenreDTO]`)
   - `getThemes() -> [String]` (antes `[ThemeDTO]`)
   - `getDemographics() -> [String]` (antes `[DemographicDTO]`)
   - Razón: API devuelve arrays de strings simples
   - MultiSelect views trabajan directamente con strings

   **Paginación en CustomSearch**:
   - `customSearch(_ search:, page:, per:)` con parámetros opcionales
   - URL: `/search/manga?page=1&per=20`
   - SearchViewModel usa `page: 1, per: 20` por defecto
   - Retorna `MangaPageDTO` con `.items` y `.metadata`
   - Preparado para scroll infinito futuro

6. ✅ **Diseño Liquid Glass Aplicado**
   - Toolbars con solo iconos (sin texto)
   - Botón izquierdo: X con `role: .cancel`
   - Botón derecho: checkmark azul (sin role, solo confirma)
   - Estilo minimalista y limpio
   - Aplicado en:
     - MultiSelectGenresView
     - MultiSelectThemesView
     - MultiSelectDemographicsView
     - EditCollectionSheet (revisado)

7. ✅ **Mejoras Adicionales**
   - Validación de volúmenes en UserCollectionViewModel
   - Swipe actions respetan límite de volúmenes del manga
   - EditCollectionSheet: cambios se guardan en tiempo real (no requiere botón save)
   - Compilación exitosa sin errores ni warnings

**Estructura de Archivos Creada**:
```
MisMangas/Search/
├── SearchView.swift              - Vista principal con UI híbrida
├── AdvancedSearchFiltersSheet.swift - Sheet de filtros principales
├── FilterChip.swift              - Chip visual para filtros activos
├── MultiSelectGenresView.swift   - Selector de géneros
├── MultiSelectThemesView.swift   - Selector de temas
└── MultiSelectDemographicsView.swift - Selector de demografías
```

**Endpoint CustomSearch**:
- **URL**: `POST /search/manga?page=1&per=20`
- **Body**: `CustomSearch` (JSON)
  ```json
  {
    "searchTitle": "one piece",
    "searchAuthorFirstName": "Eiichiro",
    "searchAuthorLastName": "Oda",
    "searchGenres": ["Action", "Adventure"],
    "searchThemes": ["Pirates", "Fantasy"],
    "searchDemographics": ["Shounen"],
    "searchContains": true
  }
  ```
- **Response**: `MangaPageDTO` con paginación
- **Lógica**: Filtros combinados con AND

**Resultado**:
- ✅ **Búsqueda avanzada 100% funcional**
- ✅ **6 nuevos componentes** en carpeta Search/
- ✅ **SearchViewModel expandido** con 7+ filtros
- ✅ **UI híbrida** con chips + sheet
- ✅ **Diseño Liquid Glass** aplicado
- ✅ **Paginación** integrada
- ✅ **Error 400 resuelto** (doble encoding)
- ✅ **BUILD SUCCEEDED** sin errores

**Próximos Pasos**:
- ⏳ Implementar scroll infinito en SearchView (usar paginación)
- ⏳ Historial de búsquedas recientes
- ⏳ ListByAuthors view (siguiente prioridad FASE 1)
- ⏳ Sistema de autenticación de usuario
