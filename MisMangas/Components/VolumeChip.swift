//
//  VolumeChip.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 15/2/26.
//

import SwiftUI

/// Chip visual para mostrar un volumen con botón de eliminación
struct VolumeChip: View {
    let volumeNumber: Int
    let onRemove: () -> Void

    var body: some View {
        HStack(spacing: 4) {
            Text("Vol. \(volumeNumber)")
                .font(.caption)

            Button {
                onRemove()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color.secondary.opacity(0.2))
        .clipShape(Capsule())
    }
}

#Preview {
    VolumeChip(volumeNumber: 5) {
    }
}
