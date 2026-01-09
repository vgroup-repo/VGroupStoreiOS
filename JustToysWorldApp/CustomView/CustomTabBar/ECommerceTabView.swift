//
//  ECommerceTabView.swift
//  JustToysWorldApp
//
//  Created by Satyam on 28/11/25.
//

import SwiftUI
import CoreData
struct ECommerceTabView: View {

    @State private var selectedTab: Tab = .home
    let persistenceController = PersistenceController.shared

    @StateObject var cartManager = CartManager()
    @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject private var dataFetcher = DataFetcher()

    var body: some View {

        TabView(selection: $selectedTab) {

            HomeView(viewModel: DashboardViewModel())
                .tag(Tab.home)

            SearchView()
                .tag(Tab.search)
                

            CartView()
                .tag(Tab.cart)

            ProfileView(coordinator: AppCoordinator(appState: .init()))
                .tag(Tab.user)
        }
        .toolbar(.hidden, for: .tabBar)
        .environment(\.managedObjectContext,
                      persistenceController.container.viewContext)
        .environmentObject(cartManager)
        .environmentObject(networkMonitor)
        .environmentObject(dataFetcher)
        .safeAreaInset(edge: .bottom) {
            CustomTabBar(selectedTab: $selectedTab)
                .environmentObject(cartManager)
                .background(Color.white)
        }
        .background(Color.white)
    }
}
