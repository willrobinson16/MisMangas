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
├── Network/             - Network layer (errors, repository, endpoints)
├── User/                - Authentication and user management
├── ViewModel/           - ViewModels for complex view logic
├── Views/               - Full-screen SwiftUI views (iPhone)
├── Views/iPad/          - iPad-optimized layouts
├── Components/          - Reusable SwiftUI components
├── Search/              - Advanced search components (filters, multi-select views)
└── Extensions/          - Swift extensions and custom modifiers
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
- **Categories**: Mangas, authors, authentication (JWT), user collection

## Swift Version & Features

- **Swift 6.2** with strict concurrency checking
- **Typed throws**: `throws(NetworkError)` for network operations
- **MainActor isolation** for UI components
- **Sendable** conformance for types crossing actor boundaries
- **SwiftData only** for persistence (no CoreData, Realm, etc.)
- **Modern patterns**: `@Observable`, `#Preview`, `async/await`

## Code Quality Requirements

### ✅ MANDATORY

1. **NO Deprecated APIs**: Always use latest non-deprecated alternatives
   - ✅ `@Observable` (not `ObservableObject`)
   - ✅ `#Preview` macro (not `PreviewProvider`)
   - ✅ `async/await` (not completion handlers)
   - ✅ SwiftData `ModelContext` (not CoreData `NSManagedObjectContext`)

2. **Strict Concurrency**: Must pass Swift 6.2 checking with ZERO warnings
   - ✅ `@MainActor` for UI components and ViewModels
   - ✅ Custom actors or `Task` for background work
   - ✅ Always `await` when crossing actor boundaries
   - ✅ Use typed throws for better error handling

3. **Actor Isolation**:
   - UI components and ViewModels: `@MainActor` isolated
   - Network/data processing: Custom actors or nonisolated functions
   - Persistence functions: `nonisolated` global functions (not extensions)

4. **Sendable Types**: Required for types crossing concurrency boundaries

5. **SwiftData Only**: No CoreData, Realm, or other persistence frameworks

### ⚠️ Security Rules

- **Tokens in Keychain**: NEVER store tokens in UserDefaults or files
- **HTTPS only**: All network requests must use HTTPS
- **Input validation**: Always validate user inputs before sending to API
- **NO hardcoded secrets**: Use configuration files (`.xcconfig`) for sensitive data
- **Conditional logging**: Use `#if DEBUG` for logs containing sensitive info

### 🎨 Code Style

- Prefer editing existing files over creating new ones
- Use `///` for documentation (DocC-compatible)
- Organize code with `// MARK: -` sections
- Spanish comments are acceptable for this project
- NO emojis in code unless explicitly requested

## Current Implementation Status

### ✅ Completed Features

**Core Infrastructure**:
- SwiftData models: Manga, Author, Theme, Genre, Demographic, FavoriteManga, UserMangaCollection
- DTOs in separate directory with proper Codable conformance
- Network layer with JWT authentication
- DataContainer with DTO→SwiftData mapping
- Persistence functions as nonisolated global functions

**Views (iPhone)**:
- ContentView with infinite scroll and pull-to-refresh
- MangaView detail screen (redesigned with hero header, expandable synopsis)
- SearchView with advanced search (7+ filters)
- UserCollectionView with list/grid modes and filters
- EditCollectionSheet for collection management
- AuthorsListView with pagination
- AuthorDetailView with mangas by author
- FavoritesView
- UserProfileView with statistics
- LoginView and RegisterView

**Views (iPad)**:
- 6 iPad-optimized views with adaptive layouts
- NavigationSplitView for authors
- Multi-column grids
- Enriched rows with complete information

**ViewModels**:
- AuthViewModel - JWT authentication with Keychain
- SearchViewModel - Advanced search with debounce (500ms)
- FavoritesViewModel - Favorites management
- UserCollectionViewModel - Collection with cloud sync
- AuthorsViewModel - Author pagination
- AuthorDetailViewModel - Shared cache for efficiency
- BestMangasViewModel - Top mangas content

**Components**:
- MangaRow, MangaGridView, CollectionEntryRow, CollectionGridCard
- AuthorRow, MangaByAuthorRow
- RatingView, MainPictureView, BackgroundPictureView
- FilterChip, MultiSelect views (genres, themes, demographics)
- AdvancedSearchFiltersSheet

**Tests**:
- 5 test files with ~100 assertions
- AuthViewModelTests, SearchViewModelTests, KeychainManagerTests
- UserMangaCollectionTests, StringExtensionsTests
- ⚠️ Tests not configured in Xcode scheme (cannot run currently)

### 🔴 Critical Issues

1. **Hardcoded App Token** in `URLRequest+Auth.swift:21`
   - Token: `sLGH38NhEJ0_anlIWwhsz1-LarClEohiAHQqayF0FY`
   - **Action**: Move to `.xcconfig` file and add to `.gitignore`
   - **Risk**: CRITICAL - Anyone with code access can use this token

### ⚠️ Known Issues

1. **Tests not executable**: Xcode scheme not configured for test action
2. **Logging with print()**: Should use OSLog with conditional compilation
3. **No input validation**: SearchViewModel doesn't sanitize user input
4. **No rate limiting**: Client-side rate limiting not implemented
5. **Cache without limits**: Image cache has no memory limit or eviction policy

## Working with Authentication

### JWT Flow

1. **Register**: POST `/users` with App-Token header
2. **Login**: POST `/users/jwt/login` with Basic Auth (email:password)
3. **Get User Info**: GET `/users/jwt/me` with Bearer token
4. **Refresh Token**: GET `/users/renew` with current Bearer token
5. **Logout**: Delete token from Keychain locally

### Token Storage

- **Save**: `try KeychainManager.shared.saveToken(token)`
- **Get**: `try await KeychainManager.shared.getToken()`
- **Delete**: `try KeychainManager.shared.deleteToken()`
- **Check**: `await KeychainManager.shared.hasToken()`

### AuthViewModel Usage

```swift
@Environment(AuthViewModel.self) private var authVM

// Login
await authVM.login(email: email, password: password)

// Check auth status
if authVM.isAuthenticated {
    // User is logged in
}

// Handle errors
if let error = authVM.errorMessage {
    // Show error to user
}
```

## Working with User Collection

### UserCollectionViewModel

```swift
@Environment(UserCollectionViewModel.self) private var collectionVM

// Add to collection
collectionVM.addToCollection(mangaID: manga.id, volumes: [1, 2, 3])

// Update reading volume
collectionVM.updateReadingVolume(mangaID: manga.id, volume: 5)

// Check if in collection
if collectionVM.isInCollection(manga.id) {
    // Manga is in user's collection
}

// Sync with server
await collectionVM.syncPendingChanges()
```

### Offline-First Pattern

1. **Local change**: Update SwiftData immediately (optimistic UI)
2. **Background sync**: Try to sync with server
3. **On failure**: Mark as pending sync with `markAsPendingSync(operation:)`
4. **Manual sync**: Show sync button when `hasPendingChanges == true`

## Working with Search

### SearchViewModel

```swift
@Environment(SearchViewModel.self) private var searchVM

// Set filters
searchVM.searchTitle = "One Piece"
searchVM.selectedGenres.insert("Action")
searchVM.authorFirstName = "Eiichiro"

// Perform search
await searchVM.performSearch()

// Clear filters
searchVM.clearAllFilters()

// Check active filters
if searchVM.hasActiveFilters {
    let count = searchVM.activeFiltersCount
}
```

### Search Features

- **Debounce**: 500ms delay before search triggers
- **Toggle**: `useContains` switches between "begins with" and "contains"
- **Filters**: Title, author name, genres, themes, demographics
- **Chips**: Visual representation of active filters

## API Endpoints Reference

### Mangas
- `GET /list/mangas?page={page}&per={per}` - Paginated manga list
- `GET /list/best?page={page}&per={per}` - Top rated mangas
- `POST /search/manga?page={page}&per={per}` - Custom search with filters
- `GET /search/manga/title?search={title}` - Search by title (begins with)
- `GET /search/manga/contains?search={title}` - Search by title (contains)

### Authors
- `GET /list/authors?page={page}&per={per}` - Paginated author list
- `GET /list/author/{id}/mangas` - Mangas by specific author

### Authentication (JWT)
- `POST /users` - Register (App-Token header required)
- `POST /users/jwt/login` - Login (Basic Auth)
- `GET /users/jwt/me` - Get current user info (Bearer token)
- `GET /users/renew` - Refresh JWT token (Bearer token)

### User Collection
- `GET /collection/manga` - Get user's collection (Bearer token)
- `POST /collection/manga` - Add/update manga in collection (Bearer token)
- `DELETE /collection/manga/{id}` - Remove manga from collection (Bearer token)

### Lists
- `GET /list/genres` - All genres (returns `[String]`)
- `GET /list/themes` - All themes (returns `[String]`)
- `GET /list/demographics` - All demographics (returns `[String]`)

## Common Development Tasks

### Adding a New View

1. Create file in `Views/` (iPhone) or `Views/iPad/` (iPad)
2. Use `#Preview` macro for previews
3. Inject dependencies via `@Environment`
4. Use `@MainActor` if accessing UI or ViewModels
5. Follow existing naming patterns (e.g., `SomethingView.swift`)

### Adding a New ViewModel

1. Create file in `ViewModel/` directory
2. Use `@Observable @MainActor` for UI-bound ViewModels
3. Inject `ModelContext` via `setModelContext(_ context:)` method
4. Use `async/await` for network operations
5. Handle errors gracefully with `errorMessage: String?`

### Adding a New Model

**SwiftData Model**:
1. Create file in `DataModel/`
2. Use `@Model` macro
3. Add `@Attribute(.unique)` for ID fields
4. Add `#Index` for searchable fields
5. Include computed properties if needed

**DTO**:
1. Create file in `DTO/`
2. Conform to `Codable` and `Identifiable`
3. Use `CodingKeys` for snake_case mapping
4. Add conversion method (e.g., `toManga()`) if needed

### Adding a New Endpoint

1. Add case to `URLEndpoint` enum in `Network/URL.swift`
2. Add method to appropriate repository (`Network`, `UserAuth`, `Collection`)
3. Create DTO if needed
4. Use `async throws` pattern
5. Handle errors with typed throws if possible

## Testing Guidelines

### Writing Tests

- Use `XCTest` framework
- Place tests in `Tests/` directory
- Name test files with `Tests` suffix (e.g., `AuthViewModelTests.swift`)
- Use `@MainActor` for ViewModels that require it
- Use `setUp()` and `tearDown()` for test lifecycle
- Write descriptive test names (e.g., `testValidEmailFormat`)

### Running Tests

**⚠️ Current Issue**: Tests are not configured in Xcode scheme

**Workaround**:
1. Open Xcode
2. Product → Scheme → Edit Scheme
3. Go to "Test" tab
4. Add test targets
5. Enable all test files

## Build Commands

```bash
# Build Debug
xcodebuild -scheme MisMangas -configuration Debug build

# Build Release
xcodebuild -scheme MisMangas -configuration Release build

# Clean build folder
xcodebuild -scheme MisMangas clean

# Open in Xcode
open MisMangas.xcodeproj

# Verify Swift version
swift --version  # Should show Swift 6.2
```

## Priority Tasks

### 🔴 CRITICAL (Before Production)

1. **Move App Token to config file**
   - Create `Config.xcconfig` with `APP_TOKEN = $(APP_TOKEN)`
   - Add to `.gitignore`
   - Rotate the exposed token on server

2. **Configure Xcode Test Scheme**
   - Enable tests in scheme
   - Run all tests and verify they pass

### 🟡 IMPORTANT (MVP+)

3. **Implement centralized logger**
   - Replace `print()` with `Logger` from `os.log`
   - Use `#if DEBUG` for sensitive logs

4. **Add input validation**
   - Sanitize user input in SearchViewModel
   - Character limits on form fields
   - Trim whitespace before API calls

5. **Implement rate limiting**
   - Throttling in DataContainer
   - Cooldown between pagination requests

## Documentation Files

- **README.md** - GitHub presentation (Spanish)
- **ARQUITECTURA.md** - Detailed architecture documentation (Spanish)
- **SECURITY_ANALYSIS.md** - Complete security analysis report
- **DOCUMENTACION_RESUMEN.md** - Documentation index

## Project Status

**Version**: MVP Functional
**Last Updated**: 2026-02-26
**Status**: Production-ready with critical fixes

### Sprint 1-2 Completed ✅
- Core functionality (catalog, search, favorites, collection)
- JWT authentication system
- iPad adaptive layouts
- Advanced search with 7+ filters
- Cloud synchronization

### Pending
- Configure tests in Xcode scheme
- Resolve hardcoded token vulnerability
- Centralized logging
- Rate limiting
- Input validation improvements

---

**Last Review**: 2026-02-26
**For**: Claude Code development assistance
