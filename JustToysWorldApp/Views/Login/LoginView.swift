//
//  LoginView.swift
//  JustToysWorldApp
//
//  Created by Satyam on 20/11/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel: LoginViewModel
    @StateObject var forgotModel: ForgotViewModel
    @StateObject var signModel: SignUpViewModel
    @ObservedObject var coordinator: AppCoordinator
    @StateObject private var loader = LoaderManager()

    @FocusState private var focusedField: Field?
    @State private var showingForgotPassword = false
    @State private var showingSignup = false
    @State private var showingHomePage = false
    enum Field: Hashable { case email, password }
    
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        _viewModel = StateObject(wrappedValue: LoginViewModel(appState: coordinator.appState))
        _forgotModel = StateObject(wrappedValue: ForgotViewModel(appState: coordinator.appState))
        _signModel = StateObject(wrappedValue: SignUpViewModel(appState: coordinator.appState))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                
                Spacer()
                Text("")
                Spacer()
                
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 250, height: 200)
                
                // MARK: - Inputs
                ValidationView(errorMessage: viewModel.localErrorMessage) {
                    VStack(spacing: 15) {
                        CustomInputField(
                            placeholder: "Email",
                            text: $viewModel.email,
                            isSecure: false,
                            keyboardType: .emailAddress,
                            contentType: .emailAddress
                        )
                        CustomSecureInputField(
                            placeholder: "Password",
                            text: $viewModel.password
                        )
                    }
                    .padding(.top, -45)
                }
                
                // MARK: - Forgot + Register
                HStack {
                    Button("Forgot Password?") {
                        viewModel.clearFields()
                        showingForgotPassword = true
                    }
                    .font(.montserrate(.regular, size: 16))
                    .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button("Register") {
                        viewModel.clearFields()
                        showingSignup = true
                    }
                    .font(.montserrate(.regular, size: 16))
                    .foregroundColor(.white)
                }
                .padding(.top, -10)
                
                // MARK: - Login
                Button(action: {
                    if viewModel.validationFields(){
                        viewModel.handleLogin(coordinator: coordinator,email: viewModel.email,pass: viewModel.password, loader: loader)
                    }
                        
                }) {
                    HStack {
                        if viewModel.isLoading { ProgressView().tint(.white) }
                        Text(viewModel.isLoading ? "Logging In..." : "Login")
                            .font(.montserrateButtonBoldTitle)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.buttonColor)
                .foregroundColor(.white)
                .cornerRadius(25)
                //.disabled(!viewModel.isLoginValid || viewModel.isLoading)
                
                Spacer()
            }
            .customAlert(item: $viewModel.alertToShow)
            .padding(60)
            .frame(minWidth: 400, minHeight: 400)
            .background(Color.themeColor)
            .navigationDestination(isPresented: $showingForgotPassword) {
                ForgotPasswordView(coordinator: coordinator, viewModel: forgotModel)
            }
            .navigationDestination(isPresented: $showingSignup) {
                SignupView(coordinator: coordinator, viewModel: signModel)
            }
            .navigationDestination(isPresented: $viewModel.isHome) {
                ECommerceTabView()
            }
            
        }
        .background(Color.themeColor)
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarBackButtonHidden(true)
        .showLoader(loader)
    }
}
