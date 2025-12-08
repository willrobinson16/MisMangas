# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MisMangas is a SwiftUI iOS application for managing manga collections. The project targets iOS 26.1+ and uses Swift 5.0 with modern concurrency features (Swift Approachable Concurrency and MainActor isolation).

**Bundle Identifier:** `com.grobinson.MisMangas`
**Development Team:** 2WATSHBXAF

## Architecture

The project follows a clean architecture pattern with clear separation of concerns:

```
MisMangas/
├── System/          - App entry point and configuration
├── Model/           - Data Transfer Objects (DTOs) and domain models
├── Interface/       - Network/API layer definitions
├── Repository/      - Data access layer
├── ViewModel/       - Business logic and state management
├── Views/           - SwiftUI view screens
├── Components/      - Reusable SwiftUI components
└── ContentView.swift - Root view
```

### Data Layer

The app uses DTOs (Data Transfer Objects) for modeling manga data. Key models in `Model/ModelDTO.swift`:

- **MangaDTO**: Main manga entity with metadata (title, score, chapters, volumes, dates, etc.)
- **ThemeDTO**: Manga themes/tags
- **AuthorDTO**: Author information with role (e.g., Story, Art)
- **GenreDTO**: Genre classifications
- **DemographicDTO**: Target demographic information
- **Status**: Enum for publication status (finished, currentlyPublishing)

All DTOs conform to `Codable` and `Identifiable` protocols for JSON serialization and SwiftUI list rendering.

## Build Commands

### Building the Project

```bash
# Build for Debug
xcodebuild -project MisMangas.xcodeproj -scheme MisMangas -configuration Debug build

# Build for Release
xcodebuild -project MisMangas.xcodeproj -scheme MisMangas -configuration Release build

# Clean build folder
xcodebuild -project MisMangas.xcodeproj -scheme MisMangas clean
```

### Running on Simulator

```bash
# List available simulators
xcrun simctl list devices available

# Run on default simulator
xcodebuild -project MisMangas.xcodeproj -scheme MisMangas -destination 'platform=iOS Simulator,name=iPhone 15' build
```

### Code Analysis

```bash
# Build and analyze
xcodebuild -project MisMangas.xcodeproj -scheme MisMangas analyze
```

## Swift Version & Features

- **Swift 5.0** with modern features enabled
- **MainActor isolation** by default for UI components
- **Approachable Concurrency** enabled
- **Member import visibility** upcoming feature enabled
- **String catalogs** for localization with symbol generation

## Important Configuration Details

### Build Settings

- SwiftUI previews are enabled (`ENABLE_PREVIEWS = YES`)
- Asset symbol extensions auto-generated
- Whole module optimization in Release builds
- User script sandboxing enabled
- Supports both iPhone and iPad (TARGETED_DEVICE_FAMILY = "1,2")

### Code Signing

- Automatic code signing
- Development team: 2WATSHBXAF

### Deployment

- Minimum deployment target: iOS 26.1
- Supported orientations (iPhone): Portrait, Landscape Left, Landscape Right
- Supported orientations (iPad): All orientations including upside-down

## Working with the Project

### Adding New Models

When adding DTOs, ensure they conform to both `Codable` and `Identifiable`. Place them in `Model/` directory.

### Project Structure Guidelines

- **Interface/**: Define protocol interfaces for network/API clients here
- **Repository/**: Implement data fetching and persistence logic
- **ViewModel/**: Create `@Observable` or `ObservableObject` classes for view state
- **Views/**: Full-screen SwiftUI views
- **Components/**: Reusable SwiftUI view components that can be used across views

### Git Workflow

The project uses `main` as the default branch. Recent commit shows initial project setup.
