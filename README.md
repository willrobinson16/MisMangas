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
- Browse manga catalog with infinite scroll
- Search manga by title
- View detailed manga information
- Favorites management
- User collection tracking (volumes owned, reading progress)

### Data Models
- **Manga**: Title, authors, score, chapters, volumes, synopsis
- **Author**: Name and role (Story/Art)
- **Genre/Theme/Demographic**: Categorization
- **FavoriteManga**: User favorites with date tracking
- **UserMangaCollection**: User's collection with volume tracking and reading progress

### ViewModels
- `SearchViewModel` - Search functionality
- `FavoritesViewModel` - Favorites management
- `UserCollectionViewModel` - Collection and reading progress management
- `BestMangasViewModel`, `MangasViewModel` - Content management

### User Collection System
Track your manga collection with:
- Volume ownership tracking
- Reading progress (current volume being read)
- Complete collection flag
- Progress statistics and analytics

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
