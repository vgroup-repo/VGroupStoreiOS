//
//  PersistenceController.swift
//  JustToysWorldApp
//
//  Created by Satyam on 04/12/25.
//

import Foundation
import CoreData

struct Products: Identifiable, Equatable {
    let id: String
    let title: String
    //let handle: String
    let price: Double
    let imageUrl: String?
}
struct APIProduct: Decodable {
    let id: String
    let name: String
    let price: Double
    let imageURL: String?
    
    // Mapping from API model to Domain model
    var domainProductList: Products {
        return Products(
            id: id,
            title: name,
            price: price,
            imageUrl: imageURL
        )
    }
}
struct ProductsListResponse: Decodable {
    let products: [APIProduct]
}
class PersistenceController {
    static let shared = PersistenceController()
    let container: NSPersistentContainer
    private let productLoader = DashboardViewModel()
    
    init(inMemory: Bool = false) {
        let model = NSManagedObjectModel.mergedModel(from: [Bundle.main])
        container = NSPersistentContainer(name: "JustToysWorldApp", managedObjectModel: model!)
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        loadInitialData()
    }
    
    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                print("Unresolved save error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    
    private func loadInitialData() {
        let context = container.newBackgroundContext()
        context.perform {
            do {
                let fetchRequest: NSFetchRequest<CDProduct> = CDProduct.fetchRequest()
                let count = try context.count(for: fetchRequest)
                
                guard count == 0 else {
                    print("Core Data: Products already exist (\(count) items). Skipping API load.")
                    return
                }
                
                print("Core Data: Store is empty. Initiating API load...")
                self.productLoader.loadAndSaveProducts(to: context) {
                    print("Initial data loading process finished.")
                }
                
            } catch {
                print("Failed to check initial data count: \(error)")
            }
        }
    }
}
extension CDProduct {
    var domainProductss: Products? {
        guard let id = id, let title = title else { return nil }
        _ = title.lowercased().replacingOccurrences(of: " ", with: "-")
        return Products(id: id, title: title, price: price, imageUrl: imageUrl)
    }
    
    static func create(from product: Products, in context: NSManagedObjectContext) -> CDProduct {
        let cdProduct = CDProduct(context: context)
        cdProduct.id = product.id
        cdProduct.title = product.title
        cdProduct.price = product.price
        cdProduct.imageUrl = product.imageUrl
        return cdProduct
    }
}
extension CDProduct {
    
    static func create(from products: [Products], in context: NSManagedObjectContext) {
        for product in products {
            let cdProduct = CDProduct(context: context)
            cdProduct.id = product.id
            cdProduct.title = product.title
            cdProduct.price = product.price
            cdProduct.imageUrl = product.imageUrl
        }
    }
}
