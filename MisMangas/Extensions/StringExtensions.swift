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
}
