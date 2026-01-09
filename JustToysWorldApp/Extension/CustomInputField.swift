//
//  CustomInputField.swift
//  JustToysWorldApp
//
//  Created by Satyam on 28/11/25.
//

import Foundation
import SwiftUI
struct CustomInputField: View {
    let placeholder: String
    @Binding var text: String
    let isSecure: Bool
    var keyboardType: UIKeyboardType = .default
    var contentType: UITextContentType? = nil
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Custom Placeholder (Visible when text is empty)
            if text.isEmpty {
                Text(placeholder)
                    .font(.montserrate(.regular, size: 16))
                    .foregroundColor(.gray)
                    .padding(.leading, 25)
            }
            
            // Actual Input Field (Secure or regular)
            Group {
                if isSecure {
                    SecureField("", text: $text)
                        .textContentType(.password)
                        .keyboardType(.default)
                } else {
                    TextField("", text: $text)
                        // Use the parameters passed by the caller
                        .keyboardType(keyboardType)
                        .autocorrectionDisabled()
                        .textContentType(contentType)
                }
            }
            .foregroundColor(.black)
            .font(.montserrate(.regular, size: 16))
            .padding(.leading, 25)
        }
        .frame(height: 50)
        // Consistent background styling
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                .background(Color.white)
        )
        .cornerRadius(25)
    }
}

// MARK: - Specialized Input Field for Password Toggle
struct CustomSecureInputField: View {
    let placeholder: String
    @Binding var text: String
    @State private var isPasswordVisible: Bool = false
    
    var body: some View {
        ZStack(alignment: .leading) {
            
            // Custom Placeholder (Gray)
            if text.isEmpty {
                Text(placeholder)
                    .font(.montserrate(.regular, size: 17))
                    .foregroundColor(.gray)
                    .padding(.leading, 25)
            }
            
            HStack {
                // Conditional rendering: SecureField (default) or TextField (when visible)
                Group {
                    if isPasswordVisible {
                        TextField("", text: $text)
                    } else {
                        SecureField("", text: $text)
                    }
                }
                .foregroundColor(.black)
                .font(.montserrate(.regular, size: 17))
                .textContentType(.password)
                .padding(.leading, 25) // Ensures left alignment matches placeholder

                // Toggle Button (Eye Icon)
                Button(action: {
                    isPasswordVisible.toggle()
                }) {
                    Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 15)
            }
        }
        .frame(height: 50) // Set the Field height
        .background(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                .background(Color.white)
        )
        .cornerRadius(25)
    }
}
struct ProfileField: View {
    let title: String
    @Binding var text: String
    @Binding var isEditable: Bool
    var isSecure: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.montserrate(.regular, size: 17))
                .foregroundColor(.black)
            
            // Text or SecureField based on the 'isSecure' flag
            Group {
                if isSecure {
                    SecureField("", text: $text)
                        .font(.montserrate(.regular, size: 17))
                        .foregroundColor(.black)
                } else {
                    TextField("", text: $text)
                        .font(.montserrate(.regular, size: 17))
                        .foregroundColor(.black)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(isEditable ? Color.white : Color.gray.opacity(0.1)) // Visual cue for editable state
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isEditable ? Color.buttonColor : Color.themeColor, lineWidth: 1)
            )
            .disabled(!isEditable) // Disable interaction when not editing
        }
    }
}
