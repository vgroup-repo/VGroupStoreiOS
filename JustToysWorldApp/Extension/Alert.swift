//
//  Alert.swift
//  JustToysWorldApp
//
//  Created by Satyam on 24/11/25.
//

import Foundation
import SwiftUI
import SwiftUI

struct CustomAlertData: Identifiable {
    let id = UUID()
    let title: Text
    let message: Text
    let primaryButton: Alert.Button
    let secondaryButton: Alert.Button?
}
extension View {
    func customAlert(item: Binding<CustomAlertData?>) -> some View {
        self.alert(item: item) { data in
            if let secondary = data.secondaryButton {
                return Alert(title: data.title, message: data.message, primaryButton: data.primaryButton, secondaryButton: secondary)
            } else {
                return Alert(title: data.title, message: data.message, dismissButton: data.primaryButton)
            }
        }
    }
}


struct SimpleAlertView: View {
    @State private var showingAlert = false

    var body: some View {
        Button("Show Alert") {
            showingAlert = true
        }
        .alert("Alert Title", isPresented: $showingAlert) {
            Button("OK") {
                print("ok pressed")
            }
        } message: {
            Text("This is the alert message.")
        }
    }
}

struct OkActionAlertView: View {
    @State private var showingActionAlert = false
    func handleOkAction() {
        print("OK button pressed and action handler executed!")
    }

    var body: some View {
        Button("Show Action Alert") {
            showingActionAlert = true
        }
        .alert("Confirmation", isPresented: $showingActionAlert) {
            Button("OK") {
                handleOkAction()
            }
        } message: {
            Text("Are you sure you want to proceed?")
        }
    }
}

struct OkCancelAlertView: View {
    @State private var showingTwoButtonAlert = false

    func handleOkAction() {
        print("OK was pressed (Action executed)")
    }
    func handleCancelAction() {
        print("Cancel was pressed (Action ignored)")
    }

    var body: some View {
        Button("Show Two-Button Alert") {
            showingTwoButtonAlert = true
        }
        .alert("Confirm Choice", isPresented: $showingTwoButtonAlert) {
           
            Button("OK", role: .destructive) {
                handleOkAction()
            }
            Button("Cancel", role: .cancel) {
                handleCancelAction()
            }
        } message: {
            Text("Do you want to confirm or cancel this action?")
        }
    }
}

// MARK: - Custom Alert View
struct CustomAlertView: View {
    @Binding var isPresented: Bool
    let title: String
    let message: String
    let buttonText: String
    
    var body: some View {
        ZStack {
            if isPresented {
                Color.black.opacity(0.3).edgesIgnoringSafeArea(.all).onTapGesture { isPresented = false }.transition(.opacity)

                VStack(spacing: 15) {
                    Text(title).font(.title2).fontWeight(.bold)
                    Text(message).multilineTextAlignment(.center).foregroundColor(.gray)
                    
                    Button(buttonText) { isPresented = false }
                        .buttonStyle(.borderedProminent).tint(.blue)
                }
                .padding(30).frame(width: 300)
                .background(Color(.systemBackground)).cornerRadius(16).shadow(radius: 15)
                .transition(.scale)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isPresented)
    }
}

// MARK: - Validation Placeholder View (Inline Error Message)
struct ValidationView<Content: View>: View {
    let errorMessage: String?
    let content: Content
    
    init(errorMessage: String?, @ViewBuilder content: () -> Content) {
        self.errorMessage = errorMessage
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            content
            if let message = errorMessage, !message.isEmpty {
                Text(message).foregroundColor(.black).font(.montserrate(.medium, size: 17)).transition(.opacity)
            }
        }
    }
}


struct Validator {
    
    // MARK: - Email
    static func isValidEmail(_ email: String) -> Bool {
        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", emailRegex).evaluate(with: email)
    }
    
    // MARK: - Name (letters + spaces, min 2 chars)
    static func isValidName(_ name: String) -> Bool {
        let nameRegex = #"^[A-Za-z ]{2,}$"#
        return NSPredicate(format: "SELF MATCHES %@", nameRegex).evaluate(with: name)
    }
    
    // MARK: - Mobile (Indian 10-digit)
    static func isValidMobile(_ mobile: String) -> Bool {
        let mobileRegex = #"^[6-9]\d{9}$"#
        return NSPredicate(format: "SELF MATCHES %@", mobileRegex).evaluate(with: mobile)
    }
}
