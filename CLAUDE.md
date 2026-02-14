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
├── Model/               - DTOs for network communication
├── Network/             - Network layer (errors, interactor, repository, endpoints)
├── ViewModel/           - ViewModels for complex view logic
├── Views/               - Full-screen SwiftUI views
├── Components/          - Reusable SwiftUI components
├── Extensions/          - Swift extensions and custom modifiers
├── ContentView.swift    - Main manga list view
└── MainTab.swift        - TabView navigation container
```

## Data Layer

### Dual-Model Approach

**Network Layer (DTOs)**: Data Transfer Objects in `Model/ModelDTO.swift`
- MangaDTO, AuthorDTO, ThemeDTO, GenreDTO, DemographicDTO
- MangaStatus enum with snake_case API mapping
- All conform to `Codable` and `Identifiable`

**Persistence Layer (SwiftData)**: Models in `DataModel/Model.swift`
- Manga, Author, Theme, Genre, Demographic
- Use `@Model` macro with performance optimizations
- Unique constraints on IDs, indexes on searchable fields
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
- **Model/**: DTOs for network/API communication (`Codable`)
- **Network/**: Network protocols, repository, URL definitions, image downloading
- **ViewModel/**: `@Observable` classes with `@MainActor` isolation
- **Views/**: Full-screen SwiftUI views
- **Components/**: Reusable SwiftUI components (use subdirectories for groups)
- **Extensions/**: Swift extensions and custom ViewModifiers

### Adding New Models

**Network DTOs**:
- Conform to `Codable` and `Identifiable`
- Place in `Model/` directory

**SwiftData Models**:
- Use `@Model` macro
- Place in `DataModel/` directory
- Add `Sendable` conformance if crossing actor boundaries
- Use `@MainActor` isolation for UI-bound models

## Implementation Status

### ✅ Completed

**Core Infrastructure**:
- SwiftData models: Manga, Author, Theme, Genre, Demographic, FavoriteManga
- Network layer with typed errors (5 error types)
- NetworkRepository with 11+ API methods
- DataContainer with DTO→SwiftData mapping
- ImageDownloader actor with dual-layer caching (memory + disk)

**Views**:
- ContentView with infinite scroll and pull-to-refresh
- MangaView detail screen with stretchy header
- SearchView with real-time search functionality
- MainTab navigation structure (3 tabs)

**Components**:
- MangaRow, MangaGridView for list/grid display
- AuthorRow for author display
- RatingView with partial star support
- MainPictureView with async loading
- StretchModifier for parallax effects

**ViewModels**:
- SearchViewModel with search functionality
- FavoritesViewModel for favorites management
- MainPictureVM for image caching

**Data Flow**:
- Pagination with @AppStorage persistence
- Preview system with sample data (8 manga entries)
- Hero animations with matched geometry
- Search by title (begins with)

### 🚧 In Progress

**Views (Partially Implemented)**:
- ListByAuthors (structure created, empty body)
- FavoritesView (placeholder only)

### ❌ Pending Implementation

**Views**:
- Complete ListByAuthors view implementation
- Complete FavoritesView with grid/list toggle
- iPad adaptive layouts (sidebar, multi-column)

**Network**:
- POST request implementation
- CustomSearch endpoint
- NetworkError Sendable conformance
- Search by "contains" integration

**Features**:
- Error state views with retry mechanism
- Loading state improvements (skeleton screens, shimmer)
- Enhanced MangaView (synopsis, volumes, chapters display)
- Filter controls (by genre, theme, demographic)
- Sort controls (by score, date, title)
- Favorites add/remove functionality
- Reading list management

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

## Known TODOs

1. **URL.swift**: CustomSearch struct defined but not implemented
2. **URLRequest.swift**: POST method commented out
3. **MainTab.swift**: Empty views for iPad and additional tabs

## Testing

- **PreviewContainer.swift**: Modern `PreviewModifier` with in-memory ModelContainer
- **PreviewData.swift**: 8 sample manga entries for testing
- **PreviewTrait**: Custom `.sampleData` trait for `#Preview`

---

## PLAN DE DESARROLLO

Este plan organiza el desarrollo restante de la app en fases progresivas.

### FASE 1: Completar Funcionalidades Básicas 🎯
**Prioridad**: ALTA | **Estimación**: 1-2 días

#### 1.1 FavoritesView
- [ ] Implementar lista/grid de favoritos usando `@Query` de FavoriteManga
- [ ] Toggle entre vista lista y grid
- [ ] Navegación a MangaView con hero animation
- [ ] Empty state cuando no hay favoritos
- [ ] Pull-to-refresh

#### 1.2 Funcionalidad de Favoritos
- [ ] Botón de favoritos en MangaView (corazón)
- [ ] Lógica para añadir/eliminar favoritos en FavoritesViewModel
- [ ] Conversión Manga → FavoriteManga
- [ ] Feedback visual al añadir/eliminar

#### 1.3 ListByAuthors View
- [ ] Lista de autores con SwiftData @Query
- [ ] Navegación a lista de mangas del autor seleccionado
- [ ] Contador de mangas por autor
- [ ] Búsqueda/filtrado de autores
- [ ] Secciones alfabéticas (A-Z)

### FASE 2: Mejorar MangaView (Detalle) 📖
**Prioridad**: ALTA | **Estimación**: 1 día

#### 2.1 Información Completa
- [ ] Mostrar synopsis completa (expandible/colapsable)
- [ ] Mostrar capítulos y volúmenes
- [ ] Mostrar fecha de inicio/fin
- [ ] Mostrar demographics (Shounen, Seinen, etc.)
- [ ] Mostrar temas (tags) en chips
- [ ] Mostrar géneros en chips
- [ ] Botón para abrir URL externa (MyAnimeList)

#### 2.2 Mejoras Visuales
- [ ] Mejorar layout con secciones claras
- [ ] Añadir iconos a cada sección
- [ ] Mejorar tipografía y espaciado
- [ ] Sombras y efectos sutiles

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

### FASE 5: iPad & Layouts Adaptativos 📱
**Prioridad**: MEDIA-BAJA | **Estimación**: 2 días

#### 5.1 iPad Layout
- [ ] Sidebar navigation para iPad
- [ ] Master-detail layout
- [ ] Grid multi-columna adaptativo (2-3-4 columnas)
- [ ] Toolbar adaptativo
- [ ] Soporte para Split View

#### 5.2 Responsive Design
- [ ] Breakpoints para diferentes tamaños
- [ ] Font scaling dinámico
- [ ] Spacing adaptativo
- [ ] Safe area handling mejorado

### FASE 6: Búsqueda Avanzada 🔎
**Prioridad**: BAJA | **Estimación**: 1 día

#### 6.1 Mejoras de Búsqueda
- [ ] Integrar `searchMangasContains` (búsqueda parcial)
- [ ] Historial de búsquedas recientes
- [ ] Sugerencias de búsqueda
- [ ] Búsqueda por autor
- [ ] Debounce en búsqueda (optimización)

#### 6.2 CustomSearch
- [ ] Implementar CustomSearch struct
- [ ] POST request en URLRequest.swift
- [ ] Endpoint customSearch en NetworkRepository
- [ ] UI para búsqueda avanzada multi-criterio

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

### Sprint 1 (Semana 1)
1. ✅ FavoritesView completa
2. ✅ Funcionalidad de añadir/eliminar favoritos
3. ✅ ListByAuthors completa
4. ✅ MangaView mejorada con toda la información

### Sprint 2 (Semana 2)
1. ✅ Error handling completo
2. ✅ Loading states mejorados
3. ✅ Filtros básicos (género, demographic)
4. ✅ Ordenación (score, título)

### Sprint 3 (Semana 3)
1. ✅ iPad layouts
2. ✅ Búsqueda avanzada
3. ✅ Pulido visual
4. ✅ Testing básico

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

**Próximos Pasos**:
- Comenzar FASE 1 del plan: Implementar FavoritesView completa
- Implementar ListByAuthors con navegación y filtrado
- Añadir funcionalidad de añadir/eliminar favoritos en MangaView
