//
//  DashboardViewModel.swift
//  JustToysWorldApp
//
//  Created by Satyam on 27/11/25.
//

import Foundation
import SwiftUI
import Combine
import CoreData

class DashboardViewModel: ObservableObject {
    @Published var dataItems: [Products] = []
    //@Published var isLoading = false
    @StateObject private var loader = LoaderManager()
    @Published var searchText = ""
    @Published var errorMessage: String?
    var filteredDataItems: [Products] {
        if searchText.isEmpty {
            return dataItems
        } else {
            return dataItems.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    private let networkService = ShopifyNetworkClient()
    private var cancellables = Set<AnyCancellable>()
    func loadAndSaveProducts(to context: NSManagedObjectContext, completion: @escaping () -> Void) {
        loader.show()
        //self.isLoading = true
        self.errorMessage = nil
        
        networkService.performGraphQLRequest(
            route: .graphqlProducts,
            model: ProductsResponse.self
        )
        
        .mapError { error -> Error in
            return error
        }
        .sink { [weak self] completion in
            
            DispatchQueue.main.async {
                //self?.isLoading = false
                self?.loader.hide()
                if case let .failure(error) = completion {
                    self?.errorMessage = "Failed to fetch products: \(error.localizedDescription)"
                    print("API Failure: \(error)")
                }
            }
        } receiveValue:
        { response in
            let domainProducts = response.products.map { $0.domainProduct }
            
            context.perform {
                // Delete all existing products
                let fetchRequest: NSFetchRequest<NSFetchRequestResult> = CDProduct.fetchRequest()
                let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                do {
                    try context.execute(batchDeleteRequest)
                } catch {
                    print("Error deleting old product data: \(error)")
                }
                
                // Create new CDProduct entities from API data
                CDProduct.create(from: domainProducts, in: context)
               
                if context.hasChanges {
                    do {
                        try context.save()
                        print("Core Data: Successfully stored \(domainProducts.count) products from API.")
                    } catch {
                        print("Core Data Save Error: \(error)")
                    }
                }
            }
        }
        .store(in: &cancellables)
    }
    func getCustomeDetailsByEmail() {
        let email  =  UserDefaults.standard.object(forKey: "email") as! String
        loader.show()
         let client = ShopifyNetworkClient()
         let customerCreds = CustomerRequest(email: email)
         client.performGraphQLRequest(
             route: .graphqlCustomerDetails(customer: customerCreds),
             model: CustomersResponse.self
         )
         .sink(receiveCompletion: { (completion: Subscribers.Completion<APIError>) in
         }, receiveValue: { response in
             let domainProducts = response.customers.map { $0.domainCustomer }
             print("domainProducts>>>>>>",domainProducts)
             self.loader.hide()
             let id = domainProducts.isEmpty ? "" : domainProducts[0].id
             let firstname = domainProducts.count > 0 ? domainProducts[0].firstName : ""
             let lastname = domainProducts.count > 0 ? domainProducts[0].lastName : ""
             let email = domainProducts.count > 0 ? domainProducts[0].email : ""
             print("firstname",firstname)
             print("lastname",lastname)
             print("email",email)
             let userDefult = UserDefaults.standard
             userDefult.set(firstname, forKey: "firstname")
             userDefult.set(lastname, forKey: "lastname")
             userDefult.set(email, forKey: "email")
             userDefult.synchronize()
             
         })
         .store(in: &cancellables)
    }
}
