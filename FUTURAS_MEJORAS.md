# Futuras Mejoras - MisMangas

Documento que lista todas las mejoras técnicas y características pendientes para implementar después de la entrega académica inicial.

**Última Actualización:** 26 de Febrero de 2026  
**Estado:** Proyecto en Fase Académica - Listo para Entrega

---

## 1. SEGURIDAD (CRÍTICAS)

### 1.1 Remover Token Hardcodeado
- **Archivo:** `Network/URLRequest+Auth.swift` (Línea 21)
- **Descripción:** El token de aplicación está hardcodeado en el código fuente
- **Prioridad:** CRÍTICA
- **Acción:** 
  - Mover token a servidor backend
  - Implementar endpoint seguro para obtener token dinámicamente
  - Usar App Attest para validar cliente antes de dar token

### 1.2 Implementar Framework de Logging Profesional
- **Archivos Afectados:** Todos (83+ print statements eliminados)
- **Descripción:** Reemplazar print() con OSLog para logging seguro
- **Prioridad:** ALTA
- **Ejemplo:**
  ```swift
  import os.log
  private let logger = Logger(subsystem: "com.grobinson.MisMangas", category: "Auth")
  logger.info("User authenticated", metadata: ["email": "\(email, privacy: .private)"])
  ```

### 1.3 Mejorar Validación de Email
- **Archivo:** `User/AuthViewModel.swift` (Línea 260-265)
- **Descripción:** Regex de email muy permisivo, permite emails inválidos
- **Prioridad:** ALTA
- **Acción:**
  - Usar regex RFC 5322 compliant
  - Implementar validación en servidor (autoridad)
  - Requerir confirmación de email

### 1.4 Fortalecer Requisitos de Contraseña
- **Archivos:** `User/RegisterView.swift`, `User/AuthViewModel.swift`
- **Descripción:** Solo valida longitud mínima (8 caracteres)
- **Prioridad:** ALTA
- **Requisitos Nuevos:**
  - Mínimo 12 caracteres
  - Mezcla de mayúsculas, minúsculas, números y símbolos
  - Sin palabras de diccionario
  - Sin patrones secuenciales (1234, abcd)
  - Usar librería zxcvbn para fortaleza

### 1.5 Implementar Rate Limiting en Autenticación
- **Archivos:** `User/AuthViewModel.swift`, `User/UserAuthRepository.swift`
- **Descripción:** Sin protección contra ataques de fuerza bruta
- **Prioridad:** ALTA
- **Implementación:**
  - Bloquear cuenta después de 5 intentos fallidos
  - Backoff exponencial entre reintentos
  - CAPTCHA después de 3 intentos
  - Alertas de seguridad por email

### 1.6 Implementar Certificate Pinning
- **Archivo:** `Network/Network.swift`
- **Descripción:** Solo HTTPS, sin validación adicional de certificado
- **Prioridad:** MEDIA
- **Acción:** Añadir validación de certificado del servidor

---

## 2. ARQUITECTURA & RENDIMIENTO

### 2.1 Mejorar Gestión de Tasks en Vistas
- **Archivos:** Múltiples vistas con `.onAppear { Task { } }`
- **Descripción:** Tasks sin cancelación adecuada → memory leaks
- **Prioridad:** MEDIA
- **Solución:**
  ```swift
  @State private var loadingTask: Task<Void, Never>?
  
  .onAppear {
      loadingTask = Task { await loadData() }
  }
  .onDisappear {
      loadingTask?.cancel()
  }
  ```

### 2.2 Optimizar Caché de Imágenes
- **Archivos:** `Main Picture/MainPictureVM.swift`, `Views/MangaView.swift`
- **Descripción:** Nueva instancia de VM por cada vista = descargas duplicadas
- **Prioridad:** MEDIA
- **Acción:**
  - Usar ImageCache compartido con @Environment
  - Implementar LRU cache con límite de memoria
  - Persistir en disco con expiración (7 días)
  - Usar SwiftData para metadatos de cache

### 2.3 Reemplazar Serialización JSON de Volúmenes
- **Archivo:** `DataModel/UserMangaCollection.swift` (Línea 28)
- **Descripción:** Usar JSON para serializar array simple en SwiftData
- **Prioridad:** BAJA (Código Quality)
- **Solución:** Usar @Relationship de SwiftData o Codable directo

### 2.4 Implementar Mecanismo de Reintento en Red
- **Archivos:** `Network/Network.swift`, todos los repositorios
- **Descripción:** Sin reintentos automáticos en fallos transitorios
- **Prioridad:** MEDIA
- **Implementación:**
  - Backoff exponencial (1s, 2s, 4s, 8s, 16s)
  - Máximo 3 reintentos
  - No reintentar en errores 4xx (salvo 429)

### 2.5 Reemplazar UIApplication por SwiftUI API
- **Archivo:** `User/RegisterView.swift` (Línea 259)
- **Descripción:** Uso de UIApplication.shared para descartar teclado
- **Prioridad:** BAJA
- **Solución:** Usar `.focused()` o `.scrollDismissesKeyboard()`

---

## 3. CARACTERÍSTICAS NUEVAS

### 3.1 Modo Offline
- **Descripción:** Funcionamiento limitado sin conexión
- **Prioridad:** MEDIA
- **Features:**
  - Caché persistente de mangas vistos
  - Edición local de colección (sincronizar luego)
  - Indicador visual de modo offline
  - Auto-sincronización cuando vuelve conexión

### 3.2 Búsqueda Avanzada - Historial
- **Archivo:** `Search/SearchView.swift`
- **Descripción:** Guardar búsquedas recientes del usuario
- **Prioridad:** BAJA
- **Implementación:**
  - Guardar últimas 10 búsquedas en SwiftData
  - Mostrar en SearchView cuando está vacío
  - Botón para limpiar historial

### 3.3 Sincronización Automática en Background
- **Archivo:** `User/SyncManager.swift`
- **Descripción:** Sincronizar cambios sin que usuario lo pida
- **Prioridad:** MEDIA
- **Requisitos:**
  - Background App Refresh (iOS 13+)
  - Sincronizar cada 15 minutos si hay cambios
  - Solo si conectado a WiFi
  - Notificaciones de éxito/error

### 3.4 Estadísticas de Colección
- **Archivos:** Nuevos componentes en Views
- **Descripción:** Dashboard con estadísticas de lectura
- **Prioridad:** BAJA
- **Métricas:**
  - Total mangas en colección
  - Total volúmenes poseídos
  - Manga con más progreso
  - Mangas completados
  - Tiempo promedio de lectura

### 3.5 Sistema de Notificaciones Push
- **Descripción:** Notificaciones cuando hay actualizaciones
- **Prioridad:** BAJA
- **Tipos:**
  - Nuevo manga agregado (según preferencias)
  - Nuevo volumen disponible (de manga en colección)
  - Invitación a compartir colección
  - Reminders de lectura

---

## 4. MEJORAS DE UX/UI

### 4.1 Estados de Carga Mejorados
- **Descripción:** Skeleton screens en lugar de indicadores generales
- **Prioridad:** MEDIA
- **Archivos Afectados:**
  - ContentView (mangas list)
  - SearchView (resultados)
  - MangaView (detalles)

### 4.2 Indicador de Fin de Lista
- **Archivos:** `ViewModel/AuthorsViewModel.swift`, etc.
- **Descripción:** Mostrar "No hay más resultados" al final
- **Prioridad:** BAJA
- **Implementación:** Footer con texto o icono

### 4.3 Animaciones de Transición
- **Descripción:** Mejorar transiciones entre vistas
- **Prioridad:** BAJA
- **Features:**
  - Hero animations (ya parcialmente presente)
  - Swipe back gestures
  - Page transitions suaves

### 4.4 Temas de Color Dinámicos
- **Descripción:** Modo claro/oscuro plus colores personalizados
- **Prioridad:** BAJA
- **Implementación:**
  - Preferencias de tema en UserProfileView
  - Sincronización en servidor

---

## 5. TESTING & CALIDAD

### 5.1 Unit Tests para ViewModels
- **Prioridad:** MEDIA
- **Archivos Objetivo:**
  - AuthViewModel
  - SearchViewModel
  - UserCollectionViewModel
  - BestMangasViewModel

### 5.2 Integration Tests para Network Layer
- **Prioridad:** MEDIA
- **Cobertura:**
  - Autenticación (login, register, refresh)
  - Colección (get, add, update, delete)
  - Búsqueda (custom, by genre, etc.)

### 5.3 UI Tests para Flujos Críticos
- **Prioridad:** BAJA
- **Flujos:**
  - Login → MainTab → Search → MangaDetail
  - Agregar manga a colección → Editar → Remover
  - Sincronización en background

### 5.4 Snapshot Tests para Componentes
- **Prioridad:** BAJA
- **Herramienta:** Recomendación: SnapshotTesting
- **Cobertura:** MangaRow, MangaGridCard, AuthorRow, etc.

---

## 6. DOCUMENTACIÓN & MANTENIMIENTO

### 6.1 Actualizar CLAUDE.md
- **Descripción:** Documento de instrucciones para desarrollo futuro
- **Contenido a Actualizar:**
  - Nuevas características implementadas
  - Cambios arquitectónicos
  - Decisiones técnicas importantes

### 6.2 Crear CHANGELOG.md
- **Descripción:** Historial de cambios por versión
- **Formato:**
  ```markdown
  ## [1.1.0] - 2026-03-XX
  ### Added
  - Offline mode support
  ### Fixed
  - Token hardcoding removed
  ```

### 6.3 Documentación de API Endpoints
- **Archivo:** `Network/Network.swift`
- **Contenido:**
  - Descripción de cada endpoint
  - Parámetros y respuestas
  - Códigos de error esperados
  - Ejemplos de uso

### 6.4 Guía de Contribución
- **Archivo:** `CONTRIBUTING.md`
- **Secciones:**
  - Setup del proyecto
  - Convenciones de código
  - Proceso de PR
  - Testing requirements

---

## 7. INFRAESTRUCTURA & DEPLOYMENT

### 7.1 Configurar CI/CD
- **Plataforma Recomendada:** GitHub Actions
- **Checks:**
  - Build success
  - Tests pass (cuando existan)
  - SwiftLint (si aplica)
  - Code coverage (meta: >70%)

### 7.2 Creación de Esquema de Versionado
- **Formato:** SemVer (Major.Minor.Patch)
- **Ejemplo:** 1.0.0 → 1.1.0 → 1.1.1
- **Gestión de Versiones:** Git tags

### 7.3 Configuración de Entornos
- **Environments:**
  - Development (localhost)
  - Staging (heroku staging app)
  - Production (heroku main app)
- **Implementación:** Xcode Build Schemes

### 7.4 Monitoreo en Producción
- **Herramientas:** Sentry o similares para crash reporting
- **Métricas:** Performance, errors, usage analytics
- **Privacy:** Conforme a GDPR/CCPA

---

## 8. DEPENDENCIAS & LIBRERÍAS

### 8.1 Considerar Agregar Librerías
- **Logging:** swift-log (SwiftLog)
- **Password Validation:** zxcvbn-ios
- **Date Parsing:** SwiftDate (si es necesario)
- **Image Caching:** Kingfisher (alternative a custom implementation)

### 8.2 Actualizar NetworkAPI Package
- **Descripción:** Actualizar cuando sea disponible
- **Consideraciones:**
  - Mantener compatibilidad con Swift 6.2
  - Verificar cambios breaking
  - Revisar security updates

---

## 9. ANÁLISIS DE SEGURIDAD A FUTURO

### 9.1 Auditoría de Seguridad Externa
- **Prioridad:** MEDIA
- **Scope:**
  - OWASP Top 10 Mobile
  - Análisis de penetración
  - Revisión de credenciales
  - Validación de encriptación

### 9.2 Implementar App Attest (iOS 14+)
- **Descripción:** Verificación del dispositivo antes de acciones sensibles
- **Prioridad:** MEDIA
- **Acciones Protegidas:**
  - Registro de usuario
  - Cambio de contraseña
  - Transferencias de datos sensibles

### 9.3 Protección de Datos en Reposo
- **Descripción:** Encriptar datos sensibles en SwiftData
- **Prioridad:** MEDIA
- **Implementación:**
  - Usar FileProtection de SwiftData
  - Encriptar tokens (aunque ya en Keychain)
  - Limpiar cache cuando se cierre sesión

---

## 10. ANÁLISIS TÉCNICO PENDIENTE

### 10.1 Profiling de Memoria
- **Herramienta:** Xcode Memory Debugger
- **Objetivo:** Identificar memory leaks
- **Enfoque:** Tasks no canceladas, referencias fuertes

### 10.2 Análisis de Rendimiento
- **Herramienta:** Xcode Instruments
- **Métricas:**
  - CPU usage
  - Memory footprint
  - Disk I/O
  - Network bandwidth

### 10.3 Auditoría de Concurrencia
- **Verificación:** Swift 6.2 strict concurrency
- **Herramienta:** `swift build -Xswiftc -strict-concurrency=complete`
- **Acción:** Verificar cero warnings

---

## 11. ROADMAP SUGERIDO

### Fase 2 (Semanas 1-2)
- [ ] Remover token hardcodeado
- [ ] Implementar logging profesional (OSLog)
- [ ] Mejorar validaciones de email/password
- [ ] Implementar rate limiting

### Fase 3 (Semanas 3-4)
- [ ] Optimizar caché de imágenes
- [ ] Implementar retry automático
- [ ] Añadir unit tests
- [ ] Crear documentación de API

### Fase 4 (Mes 2)
- [ ] Modo offline básico
- [ ] Sincronización en background
- [ ] Estadísticas de colección
- [ ] Mejoras de UI (skeleton screens)

### Fase 5+ (Largo plazo)
- [ ] Integration tests
- [ ] UI tests
- [ ] Notificaciones push
- [ ] Auditoría de seguridad
- [ ] CI/CD completo

---

## 12. CHECKLIST PRE-PRODUCCIÓN

- [ ] Remover todos los print() statements (✅ HECHO)
- [ ] Remover token hardcodeado
- [ ] Implementar validaciones fuertes
- [ ] Implementar logging profesional
- [ ] Rate limiting en auth
- [ ] Certificate pinning
- [ ] Memory leaks audit
- [ ] Performance profiling
- [ ] Security audit
- [ ] Privacy policy ready
- [ ] Terms of service ready
- [ ] GDPR/CCPA compliance
- [ ] App Store review guidelines compliance

---

## 13. CONTACTOS & REFERENCIAS

### Documentación Importante
- [Apple Security Overview](https://developer.apple.com/security/)
- [OWASP Mobile Security Top 10](https://owasp.org/www-project-mobile-top-10/)
- [Swift Security Best Practices](https://swift.org/blog/)
- [App Store Review Guidelines](https://developer.apple.com/app-store/review/guidelines/)

### Herramientas Recomendadas
- **Xcode Instruments** - Profiling
- **Xcode Memory Debugger** - Memory analysis
- **swift-format** - Code formatting
- **SwiftLint** - Static analysis
- **Sentry** - Error tracking

---

**Documento creado:** 26 de Febrero de 2026  
**Autor:** Análisis Técnico MisMangas  
**Estado:** Listo para Entrega Académica - Mejoras Futuras Documentadas
