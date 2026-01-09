//
//  AppCoordinator.swift
//  JustToysWorldApp
//
//  Created by Satyam on 27/11/25.
//

import Foundation
import SwiftUI
import Combine

// MARK: - App State (Global Single Source of Truth)
class AppState: ObservableObject {
    @Published var isAuthenticated: Bool = false
    @Published var currentUserId: String? = nil
    @Published var authError: String? = nil
}

// MARK: - App Navigation Flow Destinations
enum AppScreen: Hashable, Identifiable {
    case splash
    case login
    case signup
    case forgotPassword
    case mainTabs
    case home
    case search
    case cart
    case profile
    
    var id: String { String(describing: self) }
}

// MARK: - Coordinator (Navigation Manager)
class AppCoordinator: ObservableObject {
    
    // Dependencies injected at ContentView
    @ObservedObject var appState: AppState
    
    
    // For navigation within tabs (not used for tab switching)
    @Published var path = NavigationPath()
    
    // State for presenting modals/sheets (Login -> Signup)
    @Published var showingModal: AppScreen? = nil
    
    init(appState: AppState) {
        self.appState = appState
        appState.$isAuthenticated
            .dropFirst()
            .sink { [weak self] isAuthenticated in
                if !isAuthenticated {
                    // Navigate back to login on logout
                    self?.path = NavigationPath()
                }
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    @ViewBuilder
    func startFlow() -> some View {
        let userdefult = UserDefaults.standard
        let access_token = userdefult.object(forKey: "accessToken") as? String
        if access_token != nil {
            ECommerceTabView()
        } else {
            LoginView(coordinator: self)
        }
    }
    
    // MARK: Navigation Actions
    
    func goToSignup() {
        showingModal = .signup
    }
    func goToLogin() {
        showingModal = .login
    }
    
    func goToForgotPassword() {
        showingModal = .forgotPassword
    }
    
    func dismissModal() {
        showingModal = nil
    }
    func goToMaintab() {
        showingModal = nil
    }
    func navigate(to screen: AppScreen) {
        path.append(screen)
    }
}

enum AppRoute {
    case splash
    case login
    case signup
    case forgotPassword
    case mainTabs
    case home
    case search
    case cart
    case profile
}
