//
//  ProfileViewModel.swift
//  JustToysWorldApp
//
//  Created by Satyam on 09/12/25.
//

import Foundation
import Combine
import SwiftUI
class ProfileViewModel: ObservableObject {
    @Published var firstName: String = ""
    @Published var lastName: String = ""
    @Published  var email: String = ""
    @Published  var password: String = ""
    @Published  var isEditing: Bool = false
    @Published  var login = false
    let appState: AppState
    
    init(appState: AppState) {
        self.appState = appState
        
      
    }
     var buttonText: String {
        isEditing ? "Save Changes" : "Update Profile"
    }
    
    
     func setProfileData()
    {
        let userdefaults = UserDefaults.standard
        self.email = userdefaults.object(forKey: "email") as? String ?? ""
        self.password = "**********"
        self.firstName = userdefaults.object(forKey: "firstname") as? String ?? ""
        self.lastName = userdefaults.object(forKey: "lastname") as? String ?? ""
        
    }
    // MARK: - Action Handler
    
     func updateButtonAction() {
        if isEditing {
            // Save logic here (e.g., API call, Core Data save, etc.)
            print("--- Saving Changes ---")
            print("First Name: \(firstName)")
            print("Email: \(email)")
            // After successful save, exit editing mode
            let userdefaults = UserDefaults.standard
            userdefaults.set(self.email, forKey: "email")
            userdefaults.set(self.password, forKey: "password")
            userdefaults.set(self.firstName, forKey: "firstName")
            userdefaults.set(self.lastName, forKey: "lastName")
           isEditing = false
        } else {
            // Enter editing mode
           isEditing = true
        }
    }
     func logoutBtn(){
        let userdefaults = UserDefaults.standard
        userdefaults.removeObject(forKey: "accessToken")
        userdefaults.removeObject(forKey: "email")
        userdefaults.removeObject(forKey: "password")
        userdefaults.removeObject(forKey: "firstname")
        userdefaults.removeObject(forKey: "lastname")
        login = true
    }
}
