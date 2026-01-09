//
//  SignUpView.swift
//  JustToysWorldApp
//
//  Created by Satyam on 20/11/25.
//

import SwiftUI

struct SignupView: View {
    @ObservedObject var coordinator: AppCoordinator
    @ObservedObject var viewModel: SignUpViewModel
    @StateObject private var loader = LoaderManager()
    @FocusState private var focusedField: Field?
    enum Field: Hashable { case firstname,lastname, email, password }
    @Environment(\.dismiss) var dismiss
    @State private var showLoginView = false
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 200)
                .padding(.top, -20)
            
            ValidationView(errorMessage: viewModel.localErrorMessage) {
                VStack(spacing: 10) {
                    CustomInputField(placeholder: "First Name", text: $viewModel.firstname, isSecure: false,keyboardType: .default,contentType: .givenName)
                    CustomInputField(placeholder: "Last Name", text: $viewModel.lastname, isSecure: false,keyboardType: .default,contentType: .familyName)
                    CustomInputField(placeholder: "Email", text: $viewModel.email, isSecure: false,keyboardType: .emailAddress,contentType: .emailAddress)
                    CustomSecureInputField(placeholder: "Password", text: $viewModel.password, )
                    CustomSecureInputField(placeholder: "Confirm Password", text: $viewModel.confirmPassword, )
                    
                }
                .padding(.vertical)
                .padding(.top, -45)
            }
            
            Button(action: {
                if viewModel.validationFields(){
                    viewModel.handleSignup(coordinator: coordinator, loader: loader)
                }
            }) {
                HStack {
                    if viewModel.isLoading { ProgressView().tint(.white) }
                    Text(viewModel.isLoading ? "Signing Up..." : "Sign Up")
                        .font(.montserrateButtonBoldTitle)
                }
            }
            .frame(maxWidth: .infinity).padding()
            .background(Color.buttonColor)
            .foregroundColor(.white).cornerRadius(25)
           // .disabled(!viewModel.isSignupValid || viewModel.isLoading)
            HStack{
                Text("Already have an account? ")
                    .font(.montserrate(.regular, size: 16))
                    .foregroundColor(.white)
                Text("Login").foregroundColor(.blue)
                    .underline()
                    .onTapGesture {
                        showLoginView = true
                    }
            }
            Spacer()
        }
        .customAlert(item: $viewModel.alertToShow)
        .padding(60)
        .frame(minWidth: 400, minHeight: 400)
        
        .navigationDestination(isPresented: $showLoginView) {
            LoginView(coordinator: coordinator)
        }
        
        .navigationBarBackButtonHidden(true)
        .toolbar(.hidden, for: .navigationBar)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.themeColor)
        
        
    }
}
