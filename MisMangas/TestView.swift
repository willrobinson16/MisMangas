//
//  TestView.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 13/2/26.
//
import SwiftUI
import NetworkAPI

struct TestView: View {
    var body: some View {
        VStack {
            Button("Obtener mangas") {
                Task {
                    let network = Network()
                    do {
                        let mangas = try await network.getMangas()
                        print("Funciona! Mangas: \(mangas.count)")
                        print("---")
                        mangas.forEach { manga in
                            print("\(manga.title)")
                            print("Director: \(manga.authors)")
                            print("Año: \(manga.startDate ?? "")")
                            print("Puntuación: \(manga.score)")
                            print("")
                        }
                    } catch {
                        print("Error al obtener mangas: \(error.localizedDescription)")
                    }
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

#Preview {
    TestView()
}
