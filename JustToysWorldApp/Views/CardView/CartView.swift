//
//  CartView.swift
//  JustToysWorldApp
//
//  Created by Satyam on 27/11/25.
//
import Foundation
import Combine
import SwiftUI

struct CartView: View {
    @EnvironmentObject var cartManager: CartManager
    @State private var promoCode: String = ""
    let shippingFee: Double = 15.0
    let taxRate: Double = 0.0
    private var subTotal: Double {
        cartManager.cartItems.reduce(0) { total, item in
            total + (item.price * Double(item.quantity))
            
        }
    }
    
    private var total: Double {
        subTotal + shippingFee
    }
    
    
    private func deleteItem(item: CDCartItem) {
        if let index = cartManager.cartItems.firstIndex(where: { $0.id == item.id }) {
            cartManager.cartItems.remove(at: index)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Text("Cart")
                    .font(.montserrate(.bold, size: 18))
                    .foregroundColor(.buttonColor)
                    .padding(.leading)
                Spacer()
            }
            .padding(.bottom, 5)
            Spacer()
            
            if cartManager.cartItems.isEmpty {
                Text("Your Cart is Empty")
                    .font(.montserrate(.bold, size: 18))
                    .foregroundColor(.buttonColor)
                    .padding(.leading)
                Spacer()
            }
            else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        
                        // MARK: - Cart Items List
                        VStack(spacing: 0) {
                            ForEach(cartManager.cartItems, id: \.self) { item in
                                CartItemRow(item: item) {
                                    cartManager.removeSelectedItemFromCart(item: item)
                                }
                                Divider()
                            }
                        }
                        .padding(.horizontal)
                        
                        // MARK: - Promo Code Field
                        CustomInputField(placeholder: "Enter Promo Code", text: $promoCode, isSecure: false,keyboardType: .default,contentType: .givenName)
                            .overlay(
                                RoundedRectangle(cornerRadius: 30)
                                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                            )
                            .padding(.horizontal)
                        
                        // MARK: - Price Breakdown
                        
                        VStack(spacing: 15) {
                            
                            // Sub Total
                            HStack {
                                Text("Sub Total")
                                Spacer()
                                Text("$\(subTotal, specifier: "%.2f")")
                            }
                            
                            // Shipping & Tax
                            HStack {
                                Text("Shipping & Tax")
                                Spacer()
                                Text("$\(shippingFee, specifier: "%.2f")")
                            }
                            
                            // Total (Bold and Red)
                            HStack {
                                Text("Total")
                                    .font(.montserrate(.bold, size: 12))
                                    .foregroundColor(.buttonColor)
                                Spacer()
                                Text("$\(total, specifier: "%.2f")")
                                    .font(.montserrate(.bold, size: 12))
                                    .foregroundColor(.buttonColor)
                            }
                        }
                        .font(.montserrate(.semiBold, size: 12))
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                        .padding(.top, 10)
                        
                        // MARK: - Checkout Button
                        Button {
                            print("Proceed to Checkout. Total: $\(total, default: "%.2f")")
                            cartManager.featureCommingSoon()
                        } label: {
                            Text("Checkout")
                                .font(.montserrateButtonMediumTitle)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 15)
                                .background(Color.buttonColor)
                                .cornerRadius(25)
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        .padding(.bottom, 50)
                    }
                }
                .background(Color.white)
                .edgesIgnoringSafeArea(.horizontal)
                .padding(10)
            }
            
            
        }.onAppear {
            cartManager.fetchAllCartItems()
        }
        .safeAreaInset(edge: .top) {
            LogoHeader()
        }
        .overlay(
            Group {
                if cartManager.showToast {
                    ToastView(message: cartManager.toastMessage)
                        .transition(.scale.combined(with: .opacity))
                        .zIndex(999) // stay above tab bar
                }
            },
            alignment: .bottom
        )
        .animation(.easeInOut(duration: 0.25), value: cartManager.showToast)
        
        .background(Color.white.edgesIgnoringSafeArea(.all))
        .navigationBarHidden(true)
    }
}

