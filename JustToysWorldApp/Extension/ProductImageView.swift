//
//  ProductImageView.swift
//  JustToysWorldApp
//
//  Created by Satyam on 02/12/25.
//

import SwiftUI
import Combine
import Foundation
struct ProductImageView: View {
    
    @StateObject private var loader: ImageLoader
    private let placeholder: Image
    private let failureImage: Image
    
    init(url: String, placeholder: Image = Image(systemName: "photo.fill"), failureImage: Image = Image(systemName: "xmark.octagon.fill")) {
        _loader = StateObject(wrappedValue: ImageLoader(urlString: url))
        self.placeholder = placeholder
        self.failureImage = failureImage
    }
    
    var body: some View {
        content
            .onAppear {
                loader.load()
            }
            .onDisappear {
                loader.cancel()
            }
    }
    
    @ViewBuilder
    private var content: some View {
        if loader.isLoading {
            placeholder
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.gray.opacity(0.5))
        } else if let image = loader.image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
        } else {
            failureImage
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundColor(.red)
        }
    }
}
