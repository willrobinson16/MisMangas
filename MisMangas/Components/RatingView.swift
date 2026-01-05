//
//  RatingView.swift
//  MisMangas
//
//  Created by Guillermo Robinson on 5/1/26.
//

import SwiftUI

struct RatingView: View {
    let rating: Double
    
    private var roundedRating: Double {
        (rating * 100).rounded() / 100
    }
    
    private var normalizedRating: Double {
        roundedRating / 2 // Convierte escala 0-10 a 0-5
    }
    
    private var fullStars: Int {
        Int(normalizedRating)
    }
    
    private var partialStar: Double {
        normalizedRating - Double(fullStars)
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 2) {
            // Estrellas completas
            ForEach(0..<fullStars, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .foregroundStyle(.yellow)
            }
            
            // Estrella parcial si hay
            if partialStar > 0 {
                ZStack(alignment: .leading) {
                    // Estrella gris de fondo
                    Image(systemName: "star.fill")
                        .foregroundStyle(.gray.opacity(0.3))
                    
                    // Estrella amarilla recortada
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .mask(alignment: .leading) {
                            GeometryReader { geometry in
                                Rectangle()
                                    .frame(width: geometry.size.width * partialStar)
                            }
                        }
                }
                .fixedSize()
            }
            
            // Estrellas vacías para completar 5
            let emptyStars = 5 - fullStars - (partialStar > 0 ? 1 : 0)
            ForEach(0..<emptyStars, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .foregroundStyle(.gray.opacity(0.3))
            }
            
            Text(roundedRating.formatted(.number.precision(.fractionLength(2))))
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.leading, 10)
        }
        .font(.headline)
    }
}

#Preview {
    VStack(spacing: 20) {
        RatingView(rating: 0.0)
        RatingView(rating: 2.5)
        RatingView(rating: 5.0)
        RatingView(rating: 7.5)
        RatingView(rating: 8.0)
        RatingView(rating: 9.5)
        RatingView(rating: 10.0)
    }
    .padding()
}
