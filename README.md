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
