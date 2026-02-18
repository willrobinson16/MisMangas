//
//  StatCard.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 16/2/26.
//

import SwiftUI

/// Tarjeta de estadística para mostrar métricas del usuario
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)

            Text(value)
                .font(.title.bold())

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    StatCard(
        title: "Mangas",
        value: "42",
        icon: "books.vertical.fill",
        color: .orange
    )
    .padding()
}
