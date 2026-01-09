//
//  ProductCard.swift
//  JustToysWorldApp
//
//  Created by Satyam on 28/11/25.
//

import SwiftUI

struct ProductCard: View {
    let product: Products
    @EnvironmentObject var cartManager: CartManager
    var body: some View {
        VStack(spacing: 8) {
            ProductImageView(url: product.imageUrl ?? "logo")
                            .frame(height: 70)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
            
            Text(product.title)
                .font(.montserrate(.semiBold, size: 13))
                .foregroundColor(.black)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(minHeight: 40)
            
           
            Text("Price: $\(product.price, specifier: "%.2f")")
                .font(.montserrate(.semiBold, size: 13))
                .foregroundColor(.black)
            
            
            StarRatingView(rating: 4)
                .padding(.bottom, 5)
            CustomAddToCartButton(product: product)
                           .frame(width: 150) 
        }
        .padding(.bottom, 8)
        .background(Color.white)
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 2)
    }
    
}
struct CustomAddToCartButton: View {
    @EnvironmentObject var cartManager: CartManager
    let product: Products
    
    var body: some View {
        Button(action: {
            cartManager.addProductItemToCart(product: product)
        }) {
            Text("Add To Cart")
                .font(.montserrate(.semiBold, size: 12))
                .foregroundColor(.white)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .background(Color.themeColor) 
                .cornerRadius(20)
        }
        .padding(.horizontal, 8)
    }
}
