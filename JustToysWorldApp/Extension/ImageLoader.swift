//
//  ImageLoader.swift
//  JustToysWorldApp
//
//  Created by Satyam on 02/12/25.
//


import SwiftUI
import Combine
import Foundation

// MARK: - 1. Image Loader Service (ObservableObject)
class ImageLoader: ObservableObject {
    @Published var image: UIImage?
    @Published var isLoading = false
    
    private let urlString: String
    private var cancellable: AnyCancellable?
    
    init(urlString: String) {
        self.urlString = urlString
    }
    
   
    func load() {
        guard let url = URL(string: urlString), !urlString.isEmpty else {
            print("ImageLoader: Invalid URL provided.")
            return
        }
        
       
        if isLoading { return }
        isLoading = true
        
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) } // Convert raw Data to UIImage
            .replaceError(with: nil) // Treat any network or decoding error as a nil image
            .receive(on: DispatchQueue.main) // Ensure UI updates happen on the main thread
            .sink { [weak self] loadedImage in
                guard let self = self else { return }
              
                self.image = loadedImage
                self.isLoading = false
            }
    }
    
    func cancel() {
        cancellable?.cancel()
        isLoading = false
    }
}
