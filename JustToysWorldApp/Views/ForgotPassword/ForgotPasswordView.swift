//
//  ForgotPasswordView.swift
//  JustToysWorldApp
//
//  Created by Satyam on 27/11/25.
//

import Foundation
import Combine
import SwiftUI

struct ForgotPasswordView: View {
    @ObservedObject var coordinator: AppCoordinator
    @ObservedObject var viewModel: ForgotViewModel
    
    @FocusState private var focusedField: Field?
    enum Field: Hashable { case email }
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 10) {
            Spacer()
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 200)
            Text("Enter the email address associated with your account.")
                .font(.montserrate(.regular, size: 16))
                .foregroundColor(.secondary)
                .padding(.top, -30)
            
            if viewModel.recoverySuccess {
                Text("Recovery link sent to \(viewModel.email)!")
                    .foregroundColor(.green)
                    .padding()
            } else {
                CustomInputField(placeholder: "Email", text: $viewModel.email, isSecure: false,keyboardType: .emailAddress,contentType: .emailAddress)
                
                Button("Send Recovery Link") {
                    viewModel.handleForgotPassword(coordinator: coordinator)
                }
                .frame(maxWidth: .infinity).padding()
                .disabled(!viewModel.isEmailValid || viewModel.isLoading)
                .background(viewModel.isLoginValid && !viewModel.isLoading ? Color.buttonColor : Color.gray)
                .font(.montserrateButtonBoldTitle)
                .foregroundColor(.white).cornerRadius(25)
                .padding(.top,20)
                
            }
            
            if let error = viewModel.localErrorMessage {
                Text(error).foregroundColor(.red)
            }
            Spacer()
        }
        .padding(40)
        
        .navigationTitle("Forgot Password")
        
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    
                    Image("icon_back")
                        .resizable()
                        .scaledToFit()
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text("Forgot Password")
                    .foregroundColor(.white)
                    .font(.montserrate(.semiBold, size: 17))
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.themeColor)
    }
}
