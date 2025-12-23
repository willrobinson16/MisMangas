//
//  URLSession.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 8/12/25.
//

import Foundation

extension URLSession {
    /// Esta función envuelve la funcionalidad nativa de `URLSession` añadiendo validación de respuesta HTTP y conversión automática de errores generales a tipos específicos de NetworkError. Garantiza que la respuesta sea válida y del tipo `HTTPURLResponse antes de devolverla.
    /// - Parameter request: La petición URLRequest a ejecutar
    /// - Returns: Una tupla conteniendo los datos de respuesta (`Data`) y la respuesta HTTP (`HTTPURLResponse`)
    /// - Throws: NetworkError.nonHTTP si la respuesta no es HTTP o NetworkError.general para otros errores de red
    func getData(for request: URLRequest) async throws(NetworkError) -> (data: Data, response: HTTPURLResponse) {
        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw NetworkError.nonHTTP
            }
            return (data, httpResponse)
        } catch {
            throw .general(error)
        }
    }
}
