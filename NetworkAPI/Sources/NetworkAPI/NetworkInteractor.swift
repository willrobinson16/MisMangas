//
//  NetworrkInteractor.swift
//  EmpleadosAPI
//
//  Created by Guillermo Robinson on 19/11/25.
//

import Foundation

///// Protocolo de interacción con la API
public protocol NetworkInteractor {}

extension NetworkInteractor {
    /// Función que realiza una petición GET a la API y decodifica la respuesta JSON en el tipo especificado.
    /// Esta función maneja automáticamente la decodificación de datos JSON y la validación del código de estado HTTP.
    /// - Parameters:
    ///   - request: La petición URLRequest configurada con la URL y headers necesarios
    ///   - type: El tipo Codable al que se decodificará la respuesta JSON
    /// - Returns: Una instancia del tipo especificado con los datos decodificados
    /// - Throws: NetworkError.json si falla la decodificación o NetworkError.status si el código de estado no es 200
    public func getJSON<JSON>(_ request: URLRequest, type: JSON.Type) async throws(NetworkError) -> JSON where JSON: Codable {
        let (data, httpResponse) = try await URLSession.shared.getData(for: request)
        
        if httpResponse.statusCode == 200 {
            do {
                return try JSONDecoder().decode(type, from: data)
            } catch {
                throw NetworkError.json(error)
            }
        } else {
            throw NetworkError.status(httpResponse.statusCode)
        }
    }
    
    /// Función que realiza una petición POST a la API y valida el código de estado de la respuesta.
    /// - Parameters:
    ///   - request: La petición URLRequest configurada con la URL, headers y body necesarios
    ///   - status: El código de estado HTTP esperado para considerar la petición exitosa (por defecto 200)
    /// - Throws: NetworkError.status si el código de estado no coincide con el esperado
    public func postJSON(_ request: URLRequest, status: Int = 200) async throws(NetworkError) {
        let (_, httpResponse) = try await URLSession.shared.getData(for: request)
        if httpResponse.statusCode != status {
            throw NetworkError.status(httpResponse.statusCode)
        }
    }
}

