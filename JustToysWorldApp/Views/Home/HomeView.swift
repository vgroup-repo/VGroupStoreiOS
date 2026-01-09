//
//  HomeView.swift
//  JustToysWorldApp
//
//  Created by Satyam on 28/11/25.
//

import SwiftUI

struct HomeView: View {
    
    @ObservedObject var viewModel: DashboardViewModel
    @EnvironmentObject var networkMonitor: NetworkMonitor
    @EnvironmentObject var dataFetcher: DataFetcher
    @EnvironmentObject var cartManager : CartManager
    
    @FetchRequest(
        sortDescriptors: [SortDescriptor(\.title)],
        animation: .default
    )
    private var cdProducts: FetchedResults<CDProduct>
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    private let tabBarHeight: CGFloat = 64
    
    var body: some View {
        ZStack {
            
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                SearchBar(
                    searchText: $viewModel.searchText,
                    onSearch: {}
                )
                .padding(.bottom, 15)
                HStack {
                    Text("Toys")
                        .font(.montserrate(.bold, size: 18))
                        .foregroundColor(.buttonColor)
                        .padding(.leading)
                    Spacer()
                }
                .padding(.bottom, 5)
                
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 15) {
                        ForEach(cdProducts, id: \.self) { cdProduct in
                            if let product = cdProduct.domainProductss {
                                ProductCard(product: product)
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 15)
                    .padding(.bottom, tabBarHeight)
                }
                .scrollIndicators(.hidden)
            }
        }
        .safeAreaInset(edge: .top) {
            LogoHeader()
        }
        .onAppear(){
            viewModel.getCustomeDetailsByEmail()
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
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
    }
}
