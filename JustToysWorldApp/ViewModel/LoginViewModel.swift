//
//  LoginViewModel.swift
//  JustToysWorldApp
//
//  Created by Satyam on 24/11/25.
//

import Foundation
import Combine
import SwiftUI
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var alertToShow: CustomAlertData?
    @Published var isLoading = false
    @Published var localErrorMessage: String?
    @Published var recoverySuccess = false
    @Published  var isHome = false
    let appState: AppState
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization (DI)
    init(appState: AppState) {
        self.appState = appState

    }
    
    var isLoginValid: Bool {
        !email.isEmpty && password.count >= 6
    }
    
    func validationFields() -> Bool {
        let emailFormat = Validator.isValidEmail(self.email)
            if email.isEmpty {
                alertToShow = CustomAlertData(
                    title: Text("Warning"),
                    message: Text("Please enter your email id"),
                    primaryButton: .default(Text("OK")) {},
                    secondaryButton: nil
                )
                return false
                
            }else if !emailFormat{
                alertToShow = CustomAlertData(
                    title: Text("Warning"),
                    message: Text("Invalid Email ID"),
                    primaryButton: .default(Text("OK")) {},
                    secondaryButton: nil
                )
                return false
            }else if password.isEmpty {
                alertToShow = CustomAlertData(
                    title: Text("Warning"),
                    message: Text("Please enter your password"),
                    primaryButton: .default(Text("OK")) {},
                    secondaryButton: nil
                )
                return false
            }
            
            return true
        }
    //MARK: - Login API Calling...
    func handleLogin(coordinator: AppCoordinator, email:String, pass:String,loader:LoaderManager) {
        loader.show()
         let client = ShopifyNetworkClient()
         let loginCreds = AuthCredentials(email: email, password: pass)
         client.performGraphQLRequest(
             route: .graphqlLogin(credentials: loginCreds),
             model: CustomerMutationPayload<LoginResponse>.self
         )
         .sink(receiveCompletion: { (completion: Subscribers.Completion<APIError>) in
         }, receiveValue: { (payload: CustomerMutationPayload<LoginResponse>) in
             if let loginResult = payload.customerAccessTokenCreate {
                 if let accessToken = loginResult.customerAccessToken {
                     print("Login Success. Token: \(accessToken.accessToken)")
                     loader.hide()
                     let userDefult = UserDefaults.standard
                     userDefult.set(accessToken.accessToken, forKey: "accessToken")
                     userDefult.set(email, forKey: "email")
                     userDefult.synchronize()
                     self.appState.isAuthenticated = true
                     self.clearFields()
                     self.isHome = true
                 } else if let errors = loginResult.customerUserErrors {
                     print("Login failed: \(errors.map { $0.message }.joined(separator: ", "))")
                     let mess = errors.map { $0.message }.joined(separator: ", ")
                     loader.hide()
                     self.alertToShow = CustomAlertData(
                         title: Text("Error"),
                         message: Text(mess),
                         primaryButton: .default(Text("OK")) {},
                         secondaryButton: nil
                     )
                 }
             }
         })
         .store(in: &cancellables)


        
    }
   
    func clearFields() {
        self.email = ""
        self.password = ""
        localErrorMessage = nil
        recoverySuccess = false
    }
}
