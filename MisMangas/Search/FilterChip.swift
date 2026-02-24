//
//  FilterChip.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 24/2/26.
//

import SwiftUI

/// Chip visual para mostrar un filtro activo con botón para eliminarlo
struct FilterChip: View {
    let text: String
    let onRemove: () -> Void
    
    var body: some View {
        HStack(spacing: 4) {
            Text(text)
                .font(.caption)
                .lineLimit(1)
            
            Button {
                onRemove()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color(.secondarySystemBackground))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color(.separator), lineWidth: 0.5)
        )
    }
}

#Preview {
    HStack {
        FilterChip(text: "Género: Acción") {
            print("Eliminar filtro")
        }
        
        FilterChip(text: "Autor: Oda") {
            print("Eliminar filtro")
        }
    }
    .padding()
}
