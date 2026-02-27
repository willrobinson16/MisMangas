//
//  URLRequest.swift
//  EmpleadosAPI
//
//  Created by Guillermo Robinson on 19/11/25.
//

import Foundation

extension URLRequest {
    private static let appToken = "sLGH38NhEJ0_anlIWwhsz1-LarClEohiAHQqayF0FY"
    
    /// Crea una petición GET preconfigurada para consumir API REST con JSON.
    ///
    /// - Parameter url: La URL del endpoint de la API al que se realizará la petición.
    /// - Returns: Un `URLRequest` configurado con método GET, headers JSON y timeout establecido.
    public static func get(url: URL, token: String? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.timeoutInterval = 60
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")

        if let token {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        return request
    }
    
    /// Crea una petición HTTP preconfigurada con un cuerpo JSON codificable.
    ///
    /// - Parameters:
    ///   - url: La URL del endpoint de la API.
    ///   - body: El objeto `Codable` que se enviará como cuerpo de la petición.
    ///   - method: El método HTTP a utilizar (por defecto "POST").
    /// - Returns: Un `URLRequest` configurado con el método especificado, headers JSON y body codificado.
    public static func post<JSON>(url: URL, body: JSON, method: String = "POST") -> URLRequest where JSON: Codable {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.timeoutInterval = 60
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(body)
        return request
    }
}
