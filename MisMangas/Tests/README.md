# MisMangas Unit Tests

Directorio con todas las pruebas unitarias del proyecto MisMangas.

## Estructura

```
Tests/
├── ViewModel/          # Tests para ViewModels
│   ├── AuthViewModelTests.swift
│   └── SearchViewModelTests.swift
├── Network/            # Tests para Network layer
│   └── KeychainManagerTests.swift
├── Models/             # Tests para modelos de datos
│   └── UserMangaCollectionTests.swift
├── Extensions/         # Tests para extensiones de Swift
│   └── StringExtensionsTests.swift
└── README.md           # Este archivo
```

## Tests Implementados

### ViewModel Tests

#### AuthViewModelTests
- Email validation (valid/invalid formats)
- Error message handling
- Initial authentication state
- **Total: 4 test cases**

#### SearchViewModelTests
- Filter management (add/remove genres, authors)
- Multiple filter combinations
- Search state initialization
- Filter count tracking
- Use contains toggle
- **Total: 8 test cases**

### Network Tests

#### KeychainManagerTests
- Token save/retrieve operations
- Token update functionality
- Token deletion
- Token presence checking
- Edge cases (empty tokens, long tokens, special characters)
- Concurrent operations
- **Total: 10 test cases**

### Model Tests

#### UserMangaCollectionTests
- Initialization and properties
- Volume management (add, remove, update)
- Volume sorting and deduplication
- Reading progress calculation
- Collection progress calculation
- Sync state management
- Date tracking
- **Total: 20 test cases**

### Extensions Tests

#### StringExtensionsTests
- URL cleaning (removes backslashes and quotes)
- Date formatting (ISO 8601 to DD-MM-YYYY)
- Edge cases (empty strings, invalid formats)
- **Total: 13 test cases**

## Running Tests

### Desde Xcode
1. Abrir el proyecto en Xcode
2. Seleccionar `Product` > `Test` (⌘U)
3. O seleccionar target de tests en el menú desplegable y correr

### Desde Terminal
```bash
cd /Users/guillermorobinson/Developer/MisMangas
xcodebuild test -scheme MisMangas -destination "platform=iOS Simulator,name=iPhone 16"
```

## Estadísticas

- **Total de tests:** 55 casos de prueba
- **Cobertura:** ViewModel, Network, Models, Extensions
- **Archivos de test:** 5 archivos
- **Clases testeadas:** 5 clases principales

## Tipos de Tests

### Tests Sincrónicos
- AuthViewModelTests
- SearchViewModelTests
- StringExtensionsTests
- UserMangaCollectionTests (mayormente)

### Tests Asincronos
- KeychainManagerTests (algunos casos async)
- KeychainManagerTests (concurrent operations)

## Mejoras Futuras

Próximos tests a implementar:
- [ ] Integration tests para Network layer
- [ ] Tests para FavoritesViewModel
- [ ] Tests para BestMangasViewModel
- [ ] Tests para AuthorDetailViewModel
- [ ] Tests para UserCollectionViewModel
- [ ] Snapshot tests para componentes UI
- [ ] Performance tests para paginación
- [ ] Tests de sincronización offline

## Convenciones de Testing

### Nomenclatura
```swift
func test<WhatIsBeing Tested>()
// Ejemplos:
func testValidEmailFormat()
func testAddVolume()
func testSaveAndRetrieveToken()
```

### Estructura (AAA Pattern)
```swift
func testExample() {
    // Arrange - Preparar datos
    let input = "test"
    
    // Act - Ejecutar función
    let result = myFunction(input)
    
    // Assert - Verificar resultado
    XCTAssertEqual(result, expected)
}
```

### Manejo de Setup/Teardown
```swift
override func setUp() {
    super.setUp()
    // Inicializar antes de cada test
    viewModel = AuthViewModel()
}

override func tearDown() {
    // Limpiar después de cada test
    viewModel = nil
    super.tearDown()
}
```

## Assertion Patterns

```swift
// Igualdad
XCTAssertEqual(actual, expected)

// Verdadero/Falso
XCTAssertTrue(condition)
XCTAssertFalse(condition)

// Nil/Not Nil
XCTAssertNil(value)
XCTAssertNotNil(value)

// Comparación
XCTAssertGreaterThan(actual, expected)
XCTAssertLessThan(actual, expected)

// Valores aproximados (con tolerancia)
XCTAssertEqual(actual, expected, accuracy: 0.01)
```

## Solución de Problemas

### Tests no se ejecutan
1. Verificar que el target de tests está asignado al proyecto
2. Limpiar build folder: `Product` > `Clean Build Folder`
3. Recompilar: `Product` > `Build`

### Tests fallan con errores de aislamiento
- Verificar anotación `@MainActor` en ViewModels
- Usar `async throws` para tests asincronos
- Usar `@testable import MisMangas` para acceso a internals

### Keychain tests fallan
- Limpiar Keychain entre tests (en tearDown)
- Usar sandbox de tests para no afectar app real

## Recursos

- [XCTest Documentation](https://developer.apple.com/documentation/xctest)
- [Testing Best Practices](https://developer.apple.com/tutorials/testing)
- [Swift Testing](https://github.com/apple/swift-testing)

---

**Creado:** 26 de Febrero de 2026  
**Última Actualización:** 26 de Febrero de 2026  
**Estado:** Tests funcionales y listos para ejecución
