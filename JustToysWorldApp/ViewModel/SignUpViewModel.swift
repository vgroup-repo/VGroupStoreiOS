//
//  SignUpViewModel.swift
//  JustToysWorldApp
//
//  Created by Satyam on 24/11/25.
//

import Foundation
import Combine
import SwiftUI
class SignUpViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var firstname = ""
    @Published var lastname = ""
    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var localErrorMessage: String?
    @Published var recoverySuccess = false
    @Published var alertToShow: CustomAlertData?
    @EnvironmentObject var loginVM: LoginViewModel
    let appState: AppState
    private var cancellables = Set<AnyCancellable>()
    
    init(appState: AppState) {
        self.appState = appState
    }
    func validationFields() -> Bool {
        let emailFormat = Validator.isValidEmail(self.email)
        if firstname.isEmpty {
            
            alertToShow = CustomAlertData(
                title: Text("Warning"),
                message: Text("Please enter your firstname"),
                primaryButton: .default(Text("OK")) {},
                secondaryButton: nil
            )
            return false
        }
        else if lastname.isEmpty {
            
            alertToShow = CustomAlertData(
                title: Text("Warning"),
                message: Text("Please enter your lastname"),
                primaryButton: .default(Text("OK")) {},
                secondaryButton: nil
            )
            return false
        }
        else if email.isEmpty {
            
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
        else if confirmPassword.isEmpty {
            alertToShow = CustomAlertData(
                title: Text("Warning"),
                message: Text("Please enter confirm password"),
                primaryButton: .default(Text("OK")) {},
                secondaryButton: nil
            )
            return false
        }
        else if password != confirmPassword{
            alertToShow = CustomAlertData(
                title: Text("Warning"),
                message: Text("password and confirm password should be not same"),
                primaryButton: .default(Text("OK")) {},
                secondaryButton: nil
            )
            return false
        }
        return true
    }
    var isSignupValid: Bool {
        !firstname.isEmpty && !lastname.isEmpty && !email.isEmpty && password.count >= 6 && confirmPassword.count >= 6
    }
    //MARK: - Signup API Calling...
    func handleSignup(coordinator: AppCoordinator,loader:LoaderManager) {
        loader.show()
        let client = ShopifyNetworkClient()
        let signupRequest = SignupRequest(email: self.email, password: self.password, firstname: self.firstname, lastname: self.lastname)
        client.performGraphQLRequest(
            route: .graphqlSignup(customer: signupRequest),
            model: CustomerMutationPayload<SignupResponse>.self
        )
        .sink(receiveCompletion: { (completion: Subscribers.Completion<APIError>) in
            
        }, receiveValue: { (payload: CustomerMutationPayload<SignupResponse>) in
            if let signupResult = payload.customerCreate {
                if let customer = signupResult.customer {
                    loader.hide()
                    print("Signup Success. Customer ID: \(customer.id)")
//                    let userdefaults = UserDefaults.standard
//                    userdefaults.set(self.email, forKey: "email")
//                    userdefaults.set(self.password, forKey: "password")
//                    userdefaults.set(self.firstname, forKey: "firstname")
//                    userdefaults.set(self.lastname, forKey: "lastname")
                    
                    self.clearFields()
                    self.loginVM.handleLogin(coordinator: coordinator,email: self.email,pass: self.password, loader: loader)
                } else if let errors = signupResult.customerUserErrors {
                    print("Signup failed: \(errors.map { $0.message }.joined(separator: ", "))")
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
        self.lastname = ""
        self.firstname = ""
        localErrorMessage = nil
        recoverySuccess = false
    }
}

