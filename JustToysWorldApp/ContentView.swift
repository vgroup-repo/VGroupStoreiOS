//
//  ContentView.swift
//  JustToysWorldApp
//
//  Created by Satyam on 20/11/25.
//

import SwiftUI
import CoreData
import Foundation
import Combine
// MARK: - Root View: ContentView (App Orchestration)
struct ContentView: View {
    // Initialize dependencies once at the root
    @StateObject var appState = AppState()
    @StateObject var coordinator: AppCoordinator
    
    @State private var showSplash = true

    init() {
        _coordinator = StateObject(wrappedValue: AppCoordinator(appState: AppState()))
    }
    
    var body: some View {
        Group {
            if showSplash {
                SplashView(isFinished: $showSplash)
            } else {
                // NavigationStack is wrapped around the main flow
                NavigationStack(path: $coordinator.path) {
                    coordinator.startFlow()
                        .navigationDestination(for: AppScreen.self) { screen in
                            // Add deep links/detail views here if needed
                            switch screen {
                            default: EmptyView()
                            }
                        }
                }
                // Handle modals (Signup, Forgot Password sheets)
                .sheet(item: $coordinator.showingModal) { screen in
                    switch screen {
                    case .signup:
                        SignupView(
                            coordinator: coordinator,
                            viewModel:SignUpViewModel(appState: coordinator.appState)//, networkService: NetworkClient()
                        )
                    case .forgotPassword: // New Sheet handler
                        ForgotPasswordView(
                            coordinator: coordinator,
                            viewModel: ForgotViewModel(appState: coordinator.appState)//, networkService: NetworkClient()
                        )
                    default: EmptyView()
                    }
                }
            }
        }
       
    }
}
