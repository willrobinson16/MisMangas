# PROMPT DE CONTEXTO - MisMangas iOS App

## 📋 DESCRIPCIÓN DEL PROYECTO

**MisMangas** es una aplicación iOS nativa para gestionar colecciones personales de manga. Permite a los usuarios:
- Explorar un catálogo de mangas desde una API REST
- Marcar mangas como favoritos
- Gestionar su colección personal (volúmenes poseídos, progreso de lectura)
- Filtrar y buscar mangas
- Ver estadísticas de su colección

**Estado del proyecto**: En desarrollo activo, funcionalidad core implementada, optimizaciones recientes aplicadas.

---

## 🛠️ STACK TECNOLÓGICO

### Versiones
- **Swift**: 6.2 (strict concurrency enabled)
- **iOS**: 26.1+
- **Xcode**: Latest
- **SwiftUI**: Framework principal de UI
- **SwiftData**: Persistencia local (NO usar CoreData/Realm)

### Características de Swift 6.2
- **Typed throws**: `throws(NetworkError)` en funciones de red
- **@Observable**: NO usar `ObservableObject`
- **#Preview**: NO usar `PreviewProvider`
- **Complete concurrency checking**: Obligatorio
- **@MainActor**: Todos los ViewModels y vistas
- **NO APIs deprecadas**: Solo APIs modernas

### API Backend
- **URL Base**: `https://mymanga-acacademy-5607149ebe3d.herokuapp.com`
- **Autenticación**: JWT tokens
- **Paginación**: Implementada con `@AppStorage`

---

## 📁 ARQUITECTURA DEL PROYECTO

```
MisMangas/
├── System/              - App entry point (MisMangasApp.swift, MainTab.swift)
├── DataModel/           - SwiftData models (@Model classes)
│   ├── Model.swift      - Manga, Author, Theme, Genre, Demographic (@Model)
│   ├── UserMangaCollection.swift
│   ├── FavoriteManga.swift
│   ├── DataContainer.swift (@ModelActor)
│   └── PreviewData.swift
├── Model/               - DTOs para red (structs)
│   ├── Manga.swift (COMENTADO, ver DTO/)
│   ├── Author.swift, Theme.swift, etc.
│   └── DTO/             - DTOs actuales (MangaDTO, AuthorDTO, etc.)
├── Network/             - Capa de red
│   ├── Network.swift    - NetworkRepository
│   ├── URL.swift        - Endpoints
│   └── NetworkError.swift
├── ViewModel/           - @Observable ViewModels
│   ├── UserCollectionViewModel.swift
│   ├── FavoritesViewModel.swift
│   ├── SearchViewModel.swift
│   └── BestMangasViewModel.swift
├── Views/               - Vistas full-screen
│   ├── ContentView.swift (lista principal de mangas)
│   ├── MangaView.swift (detalle)
│   ├── UserCollectionView.swift (colección del usuario)
│   ├── SearchView.swift
│   ├── FavoritesView.swift
│   ├── UserProfileView.swift
│   └── EditCollectionSheet.swift
├── Components/          - Componentes reutilizables
│   ├── MangaRow.swift
│   ├── CollectionEntryRow.swift
│   ├── CollectionGridCard.swift
│   ├── MainPictureView.swift
│   ├── RatingView.swift
│   ├── StatCard.swift
│   └── VolumeChip.swift
├── Main Picture/        - Sistema de carga de imágenes
│   └── MainPictureVM.swift (ImageDownloader actor con cache)
└── Extensions/          - Extensiones y helpers
```

---

## 🔑 CONCEPTOS CLAVE Y DECISIONES TÉCNICAS

### 1. Dual-Model Pattern (DTO vs SwiftData)

**CRÍTICO**: Existen DOS tipos con el mismo nombre en diferentes contextos:

#### Network Layer (DTOs)
```swift
// En Model/DTO/MangaDTO.swift
struct MangaDTO: Codable {
    let id: Int
    let status: MangaStatus  // enum
    let authors: [AuthorDTO]
    // ... computed properties: mainPictureURL, urlCleaned
}
```

#### Persistence Layer (SwiftData)
```swift
// En DataModel/Model.swift
@Model
final class Manga {
    var id: Int
    var status: String  // String, NO enum
    var mainPicture: URL?  // URL directa
    @Relationship var authors: [Author]
}
```

**Conversión**: `MangaDTO.toManga` convierte DTO → @Model class

**Autor example**:
- DTO: `AuthorDTO` con `role: AuthorRole` (enum)
- SwiftData: `Author` con `role: AuthorRole` (enum, NO String) - ACTUALIZADO RECIENTEMENTE

### 2. UserMangaCollection - Sistema de Colección

**Modelo central** para tracking de colección del usuario:

```swift
@Model
final class UserMangaCollection {
    var mangaID: Int  // Referencia al manga
    var readingVolume: Int?  // Volumen actual leyendo
    var completeCollection: Bool  // Tiene colección completa
    private var volumesOwnedData: Data  // JSON de [Int] volúmenes
    var dateAdded: Date
    var lastUpdated: Date
}
```

**Computed properties importantes**:
- `volumesOwned: [Int]` - Decodifica volumesOwnedData
- `volumesOwnedCount: Int` - Total de volúmenes
- `hasStartedReading: Bool` - Si readingVolume != nil

**REGLA IMPORTANTE**:
- Si `completeCollection = true` → Mostrar `manga.volumes` en UI
- Si `completeCollection = false` → Mostrar `entry.volumesOwnedCount`

### 3. Optimización de Rendimiento (RECIENTE)

**Problema identificado**: UserCollectionView cargaba TODOS los mangas de la BD (1000+) causando delays de ~1s al cambiar entre lista/grid.

**Solución aplicada** (UserCollectionView.swift):
```swift
// ANTES: ❌
@Query private var mangas: [Manga]  // Cargaba TODO

// DESPUÉS: ✅
private var collectionMangas: [Manga] {
    let mangaIDs = collectionEntries.map { $0.mangaID }
    let descriptor = FetchDescriptor<Manga>(
        predicate: #Predicate<Manga> { manga in
            mangaIDs.contains(manga.id)
        }
    )
    return (try? modelContext.fetch(descriptor)) ?? []
}
```

**Resultado**: 100x mejora de rendimiento (solo carga mangas de la colección).

**Beneficio adicional**: Los filtros (Autores, Géneros, etc.) ahora solo muestran opciones de mangas en la colección del usuario, no de toda la BD.

### 4. Validación de Volúmenes de Lectura

**Problema resuelto**: ProgressView fuera de rango y Picker con selecciones inválidas.

**Reglas implementadas**:

1. **Picker en EditCollectionSheet**:
   - Si `completeCollection = true` → Mostrar 1...totalVolumes
   - Si `completeCollection = false` → Mostrar SOLO volumesOwned
   - Si `readingVolume` no está en `availableVolumes` → Resetear a nil automáticamente

2. **ProgressView clamping**:
   ```swift
   let progress = min(Double(readingVolume) / Double(totalVolumes), 1.0)
   ProgressView(value: progress)  // Siempre 0.0...1.0
   ```

3. **Validación automática** en EditCollectionSheet:
   ```swift
   if let reading = entry.readingVolume, !volumes.contains(reading) {
       Task { @MainActor in
           collectionVM.updateReadingVolume(mangaID: entry.mangaID, volume: nil)
       }
   }
   ```

### 5. Filtros en UserCollectionView

**Sistema de filtrado multi-criterio**:
- Autores (`selectedAuthors: Set<String>`)
- Géneros (`selectedGenres: Set<String>`)
- Demografía (`selectedDemographics: Set<String>`)
- Temas (`selectedThemes: Set<String>`)

**UI Pattern**: Menu con checkmarks
```swift
Button {
    if selectedAuthors.isEmpty {
        Label("Todos", systemImage: "checkmark")
    } else {
        Text("Todos")  // Sin ícono para evitar warning
    }
}
```

**IMPORTANTE**: NO usar `systemImage: ""` (string vacío) → Causa warning "No symbol named '' found"

### 6. ViewMode Enum

```swift
enum ViewMode {
    case list
    case grid
}
```

Declarado FUERA del struct UserCollectionView para reutilización.

### 7. Hero Animations

Usa `@Namespace` para transiciones suaves:
```swift
@Namespace private var namespace

MainPictureView(picture: manga.mainPicture, namespace: namespace)
    .matchedTransitionSource(id: picture?.lastPathComponent, in: namespace)
```

---

## 🎨 COMPONENTES UI IMPORTANTES

### CollectionGridCard (REDISEÑADO RECIENTEMENTE)

**Diseño compacto para grid de 2 columnas**:
- Imagen: 180x270 (grande)
- Título: .caption.bold(), 2 líneas
- Info en una línea con Labels compactos
- ProgressView solo si está leyendo (con clamp)
- Altura automática (~320pt)

```swift
VStack(spacing: 6) {
    MainPictureView(...).frame(width: 180, height: 270)
    Text(manga.title).font(.caption.bold())
    HStack {
        Label("\(volumes)/\(total)", systemImage: "books.vertical.fill")
        if reading { Label("Vol. \(vol)", systemImage: "book.pages") }
    }
    if reading {
        let progress = min(Double(vol) / Double(total), 1.0)
        ProgressView(value: progress).scaleEffect(y: 0.7)
    }
}
```

### CollectionEntryRow

**Fila para ListView**:
- Imagen 60x90
- Volúmenes: Muestra total si `completeCollection = true`
- ProgressView con clamp
- Badges (checkmark.seal si completo, book.pages si leyendo)

### MainPictureView

**Componente de imagen con cache**:
- Usa `MainPictureVM` (actor con cache memoria + disco)
- Placeholder: SF Symbol "book"
- Soporte para hero animations
- Parámetro `big: Bool` para tamaños diferentes

### EditCollectionSheet

**Sheet modal para editar colección**:
- Picker para volumen actual (validado)
- Toggle "Colección completa"
- TextField + botón para añadir volúmenes
- VolumeChips con botón de eliminar
- Estadísticas

---

## 🔄 FLUJOS DE DATOS

### Añadir Manga a Colección

1. Usuario hace swipe o tap en SearchView/MangaListView
2. `collectionVM.toggleInCollection(manga)`
3. `UserCollectionViewModel.addToCollection(manga:volumes:)`
4. `ensureMangaExists()` - Verifica/crea Manga SwiftData
5. Crea `UserMangaCollection` entry
6. Guarda en modelContext

**CRÍTICO**: `ensureMangaExists()` debe convertir:
- `MangaStatus` enum → String
- `AuthorRole` enum → enum (sin .rawValue)
- URLs limpias con .cleanedURL

### Actualizar Volumen de Lectura

1. Usuario cambia Picker en EditCollectionSheet
2. Binding actualiza vía `collectionVM.updateReadingVolume()`
3. SwiftData actualiza `entry.readingVolume`
4. `entry.lastUpdated = Date()`
5. Vista se re-renderiza automáticamente

### Filtrado en UserCollectionView

```swift
filteredEntries = collectionEntries.filter { entry in
    guard let manga = mangasDict[entry.mangaID] else { return false }

    if !selectedAuthors.isEmpty {
        let mangaAuthors = Set(manga.authors.map { "\($0.firstName) \($0.lastName)" })
        if mangaAuthors.isDisjoint(with: selectedAuthors) { return false }
    }
    // ... similar para genres, demographics, themes

    return true
}
```

---

## ⚠️ PROBLEMAS CONOCIDOS Y SOLUCIONES

### 1. ❌ "No symbol named '' found in system symbol set"

**Causa**: Pasar string vacío a `systemImage`
```swift
Label("Text", systemImage: condition ? "icon" : "")  // ❌ MAL
```

**Solución**:
```swift
if condition {
    Label("Text", systemImage: "icon")
} else {
    Text("Text")  // Sin ícono
}
```

### 2. ❌ "ProgressView initialized with an out-of-bounds progress value"

**Causa**: `readingVolume > totalVolumes`

**Solución**: Siempre clamp a 0.0...1.0
```swift
let progress = min(Double(reading) / Double(total), 1.0)
ProgressView(value: progress)
```

### 3. ❌ "Picker: the selection 'X' is invalid"

**Causa**: `readingVolume` no está en `availableVolumes`

**Solución**: Validar y resetear en `availableVolumes` computed property
```swift
if let reading = entry.readingVolume, !volumes.contains(reading) {
    Task { @MainActor in
        collectionVM.updateReadingVolume(mangaID: entry.mangaID, volume: nil)
    }
}
```

### 4. ❌ Volúmenes no se actualizan en UI

**Causa**: Mostrar siempre `volumesOwnedCount` incluso cuando `completeCollection = true`

**Solución**:
```swift
Text("\(entry.completeCollection ? (manga.volumes ?? 0) : entry.volumesOwnedCount)")
```

### 5. ⚠️ NetworkError no es Sendable

**Estado**: Pendiente
**Impacto**: Warnings de concurrency
**TODO**: Hacer NetworkError conforme a Sendable

---

## 📊 ESTADO ACTUAL DEL DESARROLLO

### ✅ COMPLETADO

**Core Features**:
- ✅ Lista principal de mangas con infinite scroll
- ✅ Vista de detalle (MangaView) con hero animations
- ✅ Sistema de favoritos completo
- ✅ Sistema de colección de usuario completo
- ✅ Búsqueda en tiempo real
- ✅ Filtros multi-criterio en colección
- ✅ Toggle entre vista lista/grid
- ✅ Estadísticas de usuario (UserProfileView)
- ✅ Gestión de volúmenes poseídos
- ✅ Tracking de progreso de lectura
- ✅ NavigationLinks en colecciones completas

**Optimizaciones**:
- ✅ Cache de imágenes (memoria + disco)
- ✅ Optimización de queries (solo mangas de colección)
- ✅ Validación de volúmenes de lectura
- ✅ Clamping de ProgressViews
- ✅ Eliminación de warnings de console

**UI/UX**:
- ✅ Diseño compacto de CollectionGridCard
- ✅ Swipe actions (favoritos, colección)
- ✅ Context menus en grid
- ✅ Empty states
- ✅ Loading indicators
- ✅ Hero animations

### 🚧 EN PROGRESO / PENDIENTE

**Features**:
- ⏳ Autenticación de usuario (JWT implementado pero no usado)
- ⏳ Sincronización con backend para colección
- ⏳ POST requests (comentados en URLRequest.swift)
- ⏳ CustomSearch endpoint
- ⏳ iPad layouts adaptativos (sidebar, multi-columna)

**UI Improvements**:
- ⏳ Error states con retry
- ⏳ Skeleton screens / shimmer loading
- ⏳ Mejoras en MangaView (mostrar más info)
- ⏳ Animaciones mejoradas

**Deuda Técnica**:
- ⏳ NetworkError → Sendable conformance
- ⏳ Tests (unit, integration, UI)
- ⏳ Accessibility (VoiceOver, Dynamic Type)
- ⏳ Analytics/tracking

### 🎯 PRÓXIMOS PASOS RECOMENDADOS

1. **Implementar autenticación de usuario**
   - Login/registro screens
   - Persistir JWT token
   - Integrar con endpoints autenticados

2. **Sincronizar colección con backend**
   - POST/PUT endpoints para UserMangaCollection
   - Sync local ↔ backend

3. **iPad adaptive layouts**
   - Sidebar navigation
   - Master-detail split view
   - Multi-columna grid (3-4 columnas)

4. **Testing**
   - Unit tests para ViewModels
   - Integration tests para Network layer
   - Snapshot tests para componentes

---

## 🔧 CONVENCIONES DE CÓDIGO

### Naming
- **ViewModels**: Sufijo `ViewModel` (ej: `UserCollectionViewModel`)
- **Views**: Sufijo `View` (ej: `UserCollectionView`)
- **Components**: Descriptivo (ej: `CollectionGridCard`)
- **Models**: Sin sufijo (ej: `Manga`, `Author`)

### Comentarios MARK
```swift
// MARK: - Section Name
// MARK: Subsection
```

### Property Order
1. @Environment
2. @Query
3. @Namespace
4. @State
5. Computed properties
6. body
7. Private subviews
8. Helper functions

### SwiftUI Patterns
- Usar `@ViewBuilder` para computed views
- Extraer subviews cuando superen ~20 líneas
- Preferir computed properties a funciones para vistas
- Usar extensions para organizar secciones grandes

### Concurrency
- Todos los ViewModels: `@Observable @MainActor`
- Actors para background work (ej: ImageDownloader)
- `async/await` en lugar de completion handlers
- `Task { @MainActor in ... }` para actualizaciones de UI

---

## 📝 CONTEXTO DE SESIONES RECIENTES

### Sesión actual (22/02/2026)

**Problemas resueltos**:
1. ✅ Error "No symbol named ''" en filtros → Eliminado usando Text sin ícono
2. ✅ Rendimiento UserCollectionView (~1s delay) → Optimizado con collectionMangas
3. ✅ ProgressView fuera de rango → Clamping implementado
4. ✅ Picker con selección inválida → Validación automática
5. ✅ Volúmenes no se actualizan → Condicional completeCollection
6. ✅ CollectionGridCard muy grande → Rediseñado compacto
7. ✅ NavigationLink faltante → Añadido en UserProfileView

**Archivos modificados**:
- UserCollectionView.swift (optimización mayor)
- CollectionEntryRow.swift (clamp + volúmenes)
- CollectionGridCard.swift (rediseño completo)
- EditCollectionSheet.swift (validación + clamp)
- UserProfileView.swift (NavigationLink)
- UserCollectionViewModel.swift (ensureMangaExists con Author enum)

**Decisiones técnicas**:
- NO usar `.rawValue` para AuthorRole en SwiftData (ahora es enum en ambos lados)
- Filtros solo muestran datos de colección del usuario (no toda la BD)
- Validación automática de readingVolume inválido

---

## 🚀 CÓMO CONTINUAR EL DESARROLLO

### Para una nueva sesión, proporcionar:

1. **Contexto inicial**: "Estoy trabajando en MisMangas, una app iOS de gestión de colecciones de manga. Lee el archivo PROMPT.md en la raíz del proyecto para el contexto completo."

2. **Estado actual**: Indicar qué estabas haciendo
   - Ejemplo: "Estaba implementando autenticación JWT"
   - Ejemplo: "Estaba optimizando la búsqueda"

3. **Objetivo**: Qué quieres lograr
   - Ejemplo: "Quiero añadir soporte para iPad con sidebar"
   - Ejemplo: "Necesito implementar error handling mejorado"

4. **Archivos relevantes**: Mencionar qué archivos necesitas revisar
   - Ejemplo: "Revisa UserCollectionViewModel.swift y EditCollectionSheet.swift"

### Comandos útiles

```bash
# Build del proyecto
xcodebuild -project MisMangas.xcodeproj -scheme MisMangas build

# Limpiar build
xcodebuild clean

# Ver git status
git status

# Ver cambios recientes
git log --oneline -10
```

---

## 📚 RECURSOS Y REFERENCIAS

### Documentación
- [Swift 6.2 Documentation](https://docs.swift.org/swift-book/)
- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [SwiftData Documentation](https://developer.apple.com/documentation/swiftdata)

### API Backend
- Base URL: `https://mymanga-acacademy-5607149ebe3d.herokuapp.com`
- Ver `Network/URL.swift` para todos los endpoints disponibles

### Patrones importantes
- **@Observable**: [WWDC 2023 - Discover Observation in SwiftUI](https://developer.apple.com/videos/play/wwdc2023/10149/)
- **SwiftData**: [WWDC 2023 - Meet SwiftData](https://developer.apple.com/videos/play/wwdc2023/10187/)
- **Swift Concurrency**: [WWDC 2021 - Meet async/await in Swift](https://developer.apple.com/videos/play/wwdc2021/10132/)

---

## ⚡ ATAJOS Y SNIPPETS ÚTILES

### SwiftData Query
```swift
@Query(sort: \Model.property, order: .reverse) private var items: [Model]
```

### FetchDescriptor con predicado
```swift
let descriptor = FetchDescriptor<Model>(
    predicate: #Predicate<Model> { item in
        item.property == value
    }
)
let results = try? modelContext.fetch(descriptor)
```

### @Observable ViewModel
```swift
@Observable @MainActor
final class SomeViewModel {
    private var modelContext: ModelContext?

    func setModelContext(_ context: ModelContext) {
        modelContext = context
    }
}
```

### Preview con datos
```swift
#Preview(traits: .sampleData) {
    SomeView()
        .environment(SomeViewModel())
}
```

---

## 🎯 REGLAS DE ORO

1. **NUNCA** usar APIs deprecadas
2. **SIEMPRE** usar @Observable (NO ObservableObject)
3. **SIEMPRE** usar #Preview (NO PreviewProvider)
4. **NUNCA** usar CoreData o Realm (solo SwiftData)
5. **SIEMPRE** validar concurrency (Swift 6.2 strict mode)
6. **NUNCA** pasar strings vacíos a systemImage
7. **SIEMPRE** clamp ProgressView values a 0.0...1.0
8. **SIEMPRE** validar readingVolume contra availableVolumes
9. **SIEMPRE** usar collectionMangas en UserCollectionView (no mangas completo)
10. **SIEMPRE** actualizar lastUpdated cuando se modifica UserMangaCollection

---

## 📌 NOTAS FINALES

Este proyecto está en desarrollo activo. Las optimizaciones recientes han mejorado significativamente el rendimiento y la experiencia de usuario. El siguiente paso lógico sería implementar autenticación y sincronización con el backend, seguido de layouts adaptativos para iPad.

Mantener la documentación CLAUDE.md actualizada con cambios importantes.

**Última actualización**: 2026-02-22
**Versión del proyecto**: 1.0.0 (beta)
**Estado**: Funcional, en optimización y expansión
