# MisMangas

SwiftUI iOS application for managing manga collections using Swift 6.2 with strict concurrency.

## Technical Stack

- **Platform**: iOS 26.1+
- **Language**: Swift 6.2
- **Architecture**: Clean Architecture with MVVM
- **Persistence**: SwiftData
- **Concurrency**: Complete concurrency checking (Swift 6.2)
- **UI**: SwiftUI (no deprecated APIs)

## Project Structure

```
MisMangas/
├── System/              - App entry point and configuration
├── DataModel/           - SwiftData models (@Model classes)
├── DTO/                 - Data Transfer Objects for API
├── Network/             - Network layer
├── ViewModel/           - Observable ViewModels
├── Views/               - Full-screen SwiftUI views
├── Components/          - Reusable UI components
├── Extensions/          - Swift extensions
├── ContentView.swift    - Main manga list
└── MainTab.swift        - TabView navigation
```

## Features

### Core Functionality
- Browse manga catalog with infinite scroll and pagination
- Advanced search with multiple filters (title, author, genres, themes, demographics)
- View detailed manga information with redesigned hero layout
- Favorites management with local SwiftData persistence
- User collection tracking (volumes owned, reading progress, complete collection flags)
- User authentication system with JWT tokens
- Cloud synchronization of user collection
- Authors list with pagination and detailed author views
- iPad-optimized layouts with NavigationSplitView

### Data Models
- **Manga**: Title, authors, score, chapters, volumes, synopsis
- **Author**: Name and role (Story/Art)
- **Genre/Theme/Demographic**: Categorization
- **FavoriteManga**: User favorites with date tracking
- **UserMangaCollection**: User's collection with volume tracking and reading progress

### ViewModels
- `SearchViewModel` - Advanced search with 7+ filters and debounce
- `FavoritesViewModel` - Favorites management with SwiftData
- `UserCollectionViewModel` - Collection, reading progress, and cloud sync
- `AuthViewModel` - User authentication and session management
- `AuthorsViewModel` - Author pagination
- `AuthorDetailViewModel` - Author details with shared cache
- `BestMangasViewModel` - Top mangas content management

### User Collection System
Track your manga collection with:
- Volume ownership tracking (individual volumes or complete collection)
- Reading progress (current volume being read)
- Complete collection flag (automatic or manual)
- Progress statistics and analytics
- Cloud synchronization with backend
- Offline-first architecture with pending sync queue

### User Authentication
Secure authentication system:
- JWT-based authentication with token refresh
- Keychain storage for secure token persistence
- Login and registration views
- Session management with automatic logout on token expiration
- Cloud sync of user collection on login

## API

**Base URL**: `https://mymanga-acacademy-5607149ebe3d.herokuapp.com`

The app uses a local Swift Package (NetworkAPI) for network operations.

## Development

### Build Commands

```bash
# Build Debug
xcodebuild -scheme MisMangas -configuration Debug build

# Build Release
xcodebuild -scheme MisMangas -configuration Release build

# Clean
xcodebuild -scheme MisMangas clean

# Open in Xcode
open MisMangas.xcodeproj
```

### Requirements

- Xcode 26.2+
- Swift 6.2
- iOS 26.1+ Simulator or Device

### Dependencies

- **NetworkAPI**: Local Swift Package (~/Library/Mobile Documents/com~apple~CloudDocs/Swift Develope/NetworkAPI)

## Code Standards

- ✅ No deprecated APIs
- ✅ Swift 6.2 strict concurrency compliance
- ✅ `@Observable` for ViewModels (not ObservableObject)
- ✅ `#Preview` macro (not PreviewProvider)
- ✅ `async/await` (no completion handlers)
- ✅ SwiftData only (no CoreData)
- ✅ `@MainActor` for UI components

## Bundle Identifier

`com.grobinson.MisMangas`

## License

Development Team: 2WATSHBXAF
