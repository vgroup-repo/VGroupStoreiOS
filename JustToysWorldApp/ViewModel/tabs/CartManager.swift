//
//  CartManager.swift
//  JustToysWorldApp
//
//  Created by Satyam on 04/12/25.
//

import Foundation
import CoreData
import Combine
import SwiftUI

class CartManager: ObservableObject {
    @Published var cartItems: [CDCartItem] = []
    
    private let persistenceController = PersistenceController.shared
    private let maxQuantityItem: Int64 = 10
    private let minQuantityItem: Int64 = 1
   
    @Published var showToast: Bool = false
    @Published var toastMessage: String = ""
    
    init() {
        fetchAllCartItems()
    }
    
    func fetchAllCartItems() {
        let fetchRequest: NSFetchRequest<CDCartItem> = CDCartItem.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "title", ascending: true)]
        let context = persistenceController.container.viewContext
        
        do {
            self.cartItems = try context.fetch(fetchRequest)
        } catch {
            print("Failed to fetch cart items: \(error)")
        }
    }
    
    // MARK: - Quantity Update Methods
    
    func increaseCartQuantityItem(item: CDCartItem) {
        // Max quantity check
        guard item.quantity < maxQuantityItem else {
            print("Cart: Cannot increase quantity beyond \(maxQuantityItem).")
            return
        }
        
        item.quantity += 1
        persistenceController.saveContext()
        // Re-fetch to update the published array and badge count
        fetchAllCartItems()
        print("Cart: Increased \(item.title ?? "Item") quantity to \(item.quantity).")
    }
    
    func decreaseCartQuantityItem(item: CDCartItem) {
        // Min quantity check: stop when quantity is 1
        guard item.quantity > minQuantityItem else {
            print("Cart: Cannot decrease quantity below \(minQuantityItem).")
            return
        }
        
        item.quantity -= 1
        persistenceController.saveContext()
        // Re-fetch to update the published array and badge count
        fetchAllCartItems()
        print("Cart: Decreased \(item.title ?? "Item") quantity to \(item.quantity).")
    }
    
    func addProductItemToCart(product: Products) {
        let context = persistenceController.container.viewContext
        
        let fetchRequest: NSFetchRequest<CDCartItem> = CDCartItem.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "productId == %@", product.id)
        
        do {
            let existingItems = try context.fetch(fetchRequest)
            
            if let existingItem = existingItems.first {
                // Only increment if not at max quantity
                if existingItem.quantity < maxQuantityItem {
                    existingItem.quantity += 1
                    print("Cart: Increased quantity for \(product.title). New Qty: \(existingItem.quantity)")
                } else {
                    print("Cart: Cannot add, \(product.title) is already at max quantity (\(maxQuantityItem)).")
                }
            } else {
                let newItem = CDCartItem(context: context)
                newItem.productId = product.id
                newItem.title = product.title
                newItem.price = product.price
                newItem.imageUrl = product.imageUrl
                newItem.quantity = 1 // Start at 1
                print("Cart: Added new item \(product.title).")
                showToastMessage("Item added to cart.")
            }
            
            persistenceController.saveContext()
            fetchAllCartItems()
            
        } catch {
            print("Failed to add to cart: \(error)")
        }
    }
    
    func removeSelectedItemFromCart(item: CDCartItem) {
        let context = persistenceController.container.viewContext
        print("Cart: Attempting to delete \(item.title ?? "Unknown") from Core Data.")
        
        context.delete(item)
        
        do {
            persistenceController.saveContext()
            fetchAllCartItems()
            print("Cart: Successfully deleted item.")
            showToastMessage("Item removed from cart")
        } catch {
            print("Failed to remove item from cart: \(error)")
        }
    }
    func featureCommingSoon(){
        showToastMessage("Feature coming soon!")
    }
    
    func clearCart() {
        let context = persistenceController.container.viewContext
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CDCartItem.fetchRequest()
        let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try context.execute(batchDeleteRequest)
            persistenceController.saveContext()
            self.cartItems = []
            print("Cart: All items cleared.")
        } catch {
            print("Failed to clear cart: \(error)")
        }
    }
    var count: Int {
            return cartItems.count
        }


        private func showToastMessage(_ msg: String) {
            toastMessage = msg
            showToast = true

            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.showToast = false
            }
        }
}

struct ToastView: View {
    let message: String

    var body: some View {
        Text(message)
            .font(.system(size: 14, weight: .medium))
            .multilineTextAlignment(.center)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .fill(Color.black.opacity(0.75))
            )
            .foregroundColor(.white)
            .shadow(color: .black.opacity(0.25), radius: 6)
    }
}
