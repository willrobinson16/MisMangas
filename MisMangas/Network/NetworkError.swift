//
//  NetworkError.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 8/12/25.
//

import Foundation

/// Enum que representa todos los posibles errores de red que pueden ocurrir durante las peticiones a la API.
/// Proporciona un manejo de errores tipado y específico para facilitar el diagnóstico y la gestión de fallos en la capa de red. Implementa `LocalizedError` para ofrecer mensajes descriptivos al usuario.
public enum NetworkError: LocalizedError {
    /// Error general de red que encapsula cualquier excepción no específica lanzada por `URLSession
    case general(Error)
    /// Error de código de estado HTTP no exitoso. Contiene el código de estado recibido del servidor
    case status(Int)
    /// Error de decodificación JSON. Se lanza cuando la respuesta no puede ser parseada al tipo esperado
    case json(Error)
    /// Error de datos inválidos. Se usa cuando los datos recibidos no cumplen con el formato esperado
    case dataNotValid
    /// Error de respuesta no HTTP. Se lanza cuando `URLSession` no devuelve una `HTTPURLResponse` válida
    case nonHTTP

    public var errorDescription: String? {
        switch self {
        case .general(let error):
            error.localizedDescription
        case .status(let int):
            "HTTP status code: \(int)"
        case .json(let error):
            "JSON error: \(error)"
        case .dataNotValid:
            "Invalid data received from server"
        case .nonHTTP:
            "URLSession did no return a HTTPURLResponse"
        }
    }
}
