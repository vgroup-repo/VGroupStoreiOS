//
//  ForgotViewModel.swift
//  JustToysWorldApp
//
//  Created by Satyam on 09/12/25.
//

import Foundation
import Combine
import SwiftUI
class ForgotViewModel: ObservableObject {
    @Published var email = ""
    @Published var alertToShow: CustomAlertData?
    @Published var isLoading = false
    @Published var localErrorMessage: String?
    @Published var recoverySuccess = false
    
    let appState: AppState
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization (DI)
    init(appState: AppState) {
        self.appState = appState
      
    }
    
    var isLoginValid: Bool {
        !email.isEmpty
    }
    var isEmailValid: Bool {
       
        !email.isEmpty && email.contains("@") && email.contains(".")
    }
    //MARK: - Forgot Password API Calling...
    func handleForgotPassword(coordinator:AppCoordinator) {

    }
}
