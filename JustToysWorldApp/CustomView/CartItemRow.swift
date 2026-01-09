//
//  CartItemRow.swift
//  JustToysWorldApp
//
//  Created by Satyam on 28/11/25.
//

import SwiftUI

struct CartItemRow: View {
    let item: CDCartItem
    var onDelete: () -> Void
    @EnvironmentObject var cartManager: CartManager
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            ProductImageView(url: item.imageUrl ?? "logo")
                .frame(width: 100, height: 80)
                .background(Color(UIColor.systemGray5).opacity(0.1))
                .cornerRadius(8)
                .padding(.top, 5)
                .padding(.bottom,5)
            VStack(alignment: .leading, spacing: 5) {
                Text(item.title ?? "")
                    .font(.montserrate(.semiBold, size: 13))
                    .foregroundColor(.buttonColor)
                    .lineLimit(2)
                
                Text("Price: $\(item.price, specifier: "%.2f")")
                    .font(.montserrate(.medium, size: 11))
                    .foregroundColor(.gray)
                
                Spacer()
                
                HStack(spacing: 5) {
                           
                            Button(action: {
                                cartManager.decreaseCartQuantityItem(item: item)
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(item.quantity > 1 ? .themeColor : .gray)
                            }
                            .disabled(item.quantity <= 1)
                            
                    Text("\(item.quantity)")
                        .font(.montserrate(.semiBold, size: 13))
                        .foregroundColor(.black)
                        .frame(width: 20)
                            
                            Button(action: {
                                cartManager.increaseCartQuantityItem(item: item)
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundColor(item.quantity < 10 ? .themeColor : .gray)
                            }
                            .disabled(item.quantity >= 10)
                        }
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash.fill")
                    .foregroundColor(.gray)
                    .font(.title3)
            }
        }
        .padding(.vertical, 10)
    }
}
