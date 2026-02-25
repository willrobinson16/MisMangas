//
//  StringExtensions.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 15/2/26.
//

import Foundation

//MARK: - Helper Extensions
extension String {
    nonisolated var cleanedURL: String {
        self
           .replacingOccurrences(of: "\\", with: "")
           .replacingOccurrences(of: "\"", with: "")
   }

    /// Formatea una fecha ISO a formato DD-MM-YYYY
    ///
    /// Convierte fechas en formato ISO 8601 (con o sin hora) al formato español DD-MM-YYYY
    ///
    /// - Note: Maneja tanto fechas simples como fechas con hora y zona horaria
    ///
    /// ## Ejemplos:
    /// ```swift
    /// "1998-09-03".formattedDate              // "03-09-1998"
    /// "1998-09-03T00:00:00Z".formattedDate    // "03-09-1998"
    /// ```
    var formattedDate: String {
        // Extraer solo la parte de la fecha (antes de 'T' si existe)
        let datePart = self.split(separator: "T").first?.description ?? self

        let components = datePart.split(separator: "-")
        guard components.count == 3 else { return self }

        let year = components[0]
        let month = components[1]
        let day = components[2]

        return "\(day)-\(month)-\(year)"
    }
}
