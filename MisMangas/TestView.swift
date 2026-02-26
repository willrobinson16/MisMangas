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
                        mangas.items.forEach { manga in
                        }
                    } catch {
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
