//
//  StarRatingView.swift
//  JustToysWorldApp
//
//  Created by Satyam on 28/11/25.
//

import SwiftUI

struct StarRatingView: View {
    let rating: Int
    let maxRating = 5
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(1...maxRating, id: \.self) { index in
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundColor(index <= rating ? .orange : .gray.opacity(0.3))
            }
        }
    }
}
#Preview {
    StarRatingView(rating: 4)
}
