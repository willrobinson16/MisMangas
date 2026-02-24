//
//  ImageDownloader.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 17/12/25.
//

import SwiftUI

/// Actor responsable de gestionar la descarga y almacenamiento en caché de imágenes de forma concurrente y segura.
///
/// `ImageDownloader` proporciona un sistema de caché en memoria y persistencia en disco para optimizar
/// la descarga de imágenes. Utiliza el patrón singleton para garantizar una única instancia compartida
/// y aprovecha las capacidades de actor para manejar el acceso concurrente de forma segura.
///
/// ## Características principales:
/// - Caché en memoria con NSCache (límite automático de memoria)
/// - Prevención de descargas duplicadas para la misma URL
/// - Redimensionamiento automático de imágenes antes de guardarlas en disco
/// - Persistencia en el directorio de caché del sistema
/// - Manejo seguro de concurrencia mediante actor
/// - Gestión automática de memoria bajo presión
actor ImageDownloader {
    /// Instancia compartida del descargador de imágenes (Singleton)
    static let shared = ImageDownloader()

    /// Enumeración que representa los posibles estados de una imagen en el sistema de caché.
    ///
    /// - `downloading`: La imagen está siendo descargada actualmente. Contiene la tarea asociada.
    /// - `downloaded`: La imagen ha sido descargada y está disponible en memoria.
    private enum ImageStatus {
        case downloading(task: Task<UIImage, any Error>)
        case downloaded(image: UIImage)
    }

    /// Wrapper class para ImageStatus para usarlo con NSCache
    private final class ImageStatusWrapper {
        let status: ImageStatus
        init(status: ImageStatus) {
            self.status = status
        }
    }

    /// Cache en memoria con límite automático de 50 imágenes y 100 MB
    /// NSCache automáticamente libera memoria bajo presión del sistema
    private let cache: NSCache<NSString, ImageStatusWrapper> = {
        let cache = NSCache<NSString, ImageStatusWrapper>()
        cache.countLimit = 50  // Máximo 50 imágenes
        cache.totalCostLimit = 100 * 1024 * 1024  // 100 MB
        return cache
    }()

    /// Diccionario auxiliar para tracking de downloads en progreso
    /// Solo contiene URLs de descargas activas
    private var downloadingURLs: Set<String> = []
    
    /// Función privada que aisla la descarga de la imagen desde una URL.
    ///
    /// Este método realiza la descarga real de los datos desde la URL proporcionada
    /// y los convierte en un objeto `UIImage`.
    ///
    /// - Parameter url: La URL de la imagen a descargar.
    /// - Returns: La imagen descargada como `UIImage`.
    /// - Throws: `URLError.badServerResponse` si los datos no pueden convertirse en imagen,
    ///           o cualquier error de red que pueda ocurrir durante la descarga.
    private func getImage(url: URL) async throws -> UIImage {
        let (data, _) = try await URLSession.shared.data(from: url)
        if let image = UIImage(data: data) {
            return image
        } else {
            throw URLError(.badServerResponse)
        }
    }
    
    /// Función principal para obtener una imagen, gestionando su existencia en caché y su estado.
    ///
    /// Este método implementa la lógica principal del sistema de caché:
    /// - Si la imagen ya está en caché y descargada, la retorna inmediatamente.
    /// - Si la imagen está siendo descargada por otra tarea, espera a que finalice y retorna el resultado.
    /// - Si la imagen no está en caché, inicia una nueva descarga y la almacena.
    ///
    /// Después de descargar exitosamente la imagen, automáticamente inicia el proceso de guardado en disco.
    /// En caso de error durante la descarga, elimina la entrada del caché para permitir reintentos futuros.
    ///
    /// - Parameter url: La URL de la imagen a obtener.
    /// - Returns: La imagen solicitada como `UIImage`.
    /// - Throws: Cualquier error que pueda ocurrir durante la descarga o procesamiento de la imagen.
    func image(for url: URL) async throws -> UIImage {
        let key = url.absoluteString as NSString

        // Verificar cache
        if let wrapper = cache.object(forKey: key) {
            return switch wrapper.status {
            case .downloading(let task):
                try await task.value
            case .downloaded(let image):
                image
            }
        }

        let task = Task {
            try await getImage(url: url)
        }

        // Almacenar en cache como downloading
        cache.setObject(ImageStatusWrapper(status: .downloading(task: task)), forKey: key)
        downloadingURLs.insert(url.absoluteString)

        do {
            let image = try await task.value
            downloadingURLs.remove(url.absoluteString)

            // Almacenar en cache como downloaded con cost estimado
            let estimatedCost = Int(image.size.width * image.size.height * 4) // RGBA
            let wrapper = ImageStatusWrapper(status: .downloaded(image: image))
            cache.setObject(wrapper, forKey: key, cost: estimatedCost)

            try await saveImage(url: url)
            return image
        } catch {
            cache.removeObject(forKey: key)
            downloadingURLs.remove(url.absoluteString)
            throw error
        }
    }
    
    /// Función que guarda la imagen en disco de forma persistente.
    ///
    /// Este método realiza las siguientes operaciones:
    /// 1. Verifica que la imagen esté en estado `.downloaded` en el caché.
    /// 2. Redimensiona la imagen a un ancho de 300 puntos para optimizar el almacenamiento.
    /// 3. Convierte la imagen redimensionada a formato JPEG con calidad máxima.
    /// 4. Obtiene la URL del archivo en disco mediante `getFileURL(url:)`.
    /// 5. Guarda los datos en el directorio de caché del sistema de forma atómica.
    /// 6. Elimina la imagen del caché en memoria para liberar recursos.
    ///
    /// La operación de guardado es atómica para evitar corrupción de datos en caso de interrupciones.
    /// Si algún paso falla (redimensionamiento o conversión), el método termina silenciosamente sin guardar.
    ///
    /// - Parameter url: La URL de origen que se usará para determinar el nombre del archivo en disco.
    /// - Throws: Errores de I/O si no se puede escribir en el directorio de caché.
    func saveImage(url: URL) async throws {
        let key = url.absoluteString as NSString
        guard let wrapper = cache.object(forKey: key),
              case .downloaded(let image) = wrapper.status else { return }

        if let resized = await image.resize(width: 300),
           let data = resized.jpegData(compressionQuality: 1.0) {
            try data.write(to: getFileURL(url: url), options: .atomic)
            // Mantener en cache después de guardar (NSCache lo eliminará si hay presión de memoria)
        }
    }
    
    /// Genera la URL del archivo local en el directorio de caché del sistema.
    ///
    /// Utiliza el último componente de la URL de origen como nombre del archivo.
    /// Es `nonisolated` porque no accede a ningún estado mutable del actor,
    /// lo que permite llamarla de forma síncrona sin `await`.
    ///
    /// - Parameter url: La URL de origen de la imagen.
    /// - Returns: La URL completa del archivo en el directorio de caché.
    nonisolated func getFileURL(url: URL) -> URL {
        URL.cachesDirectory.appending(path: url.lastPathComponent)
    }
}
