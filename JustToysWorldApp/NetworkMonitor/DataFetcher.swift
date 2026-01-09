//
//  DataFetcher.swift
//  JustToysWorldApp
//
//  Created by Satyam on 02/12/25.
//

import Foundation
import Network
import Combine
class DataFetcher: ObservableObject {
    @Published var homeData: String = "Loading Home Data..."
    @Published var cartData: String = "Loading Cart Data..."
    var refreshAction: (() -> Void)?
    func fetchHomeData() {
        print("API Call: Fetching PRODUCTS API...")
        homeData = "Home Data Loaded (\(Date.now.formatted(date: .omitted, time: .standard)))"
       
    }
    
    func fetchCartData() {
        print("API Call: Fetching CART API...")
        cartData = "Cart Data Loaded (\(Date.now.formatted(date: .omitted, time: .standard)))"
      
    }
}
