//
//  MisMangasApp.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 6/12/25.
//

import SwiftUI
import SwiftData

@main
struct MisMangasApp: App {
    var body: some Scene {
        WindowGroup {
            MainTab()
        }
        .modelContainer(for: Manga.self) { result in
            guard case .success(let container) = result else {
                return
            }
            Task.detached(priority: .high) {
                let modelContainer = DataContainer(modelContainer: container)
                do {
                    try await modelContainer.loadInitialData()
                } catch {
                    print(error)
                }
            }
        }
    }
}
