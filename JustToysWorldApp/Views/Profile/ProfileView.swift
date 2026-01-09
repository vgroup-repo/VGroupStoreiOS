//
//  ProfileView.swift
//  JustToysWorldApp
//
//  Created by Satyam on 27/11/25.
//

import Foundation
import Combine
import SwiftUI

struct ProfileView: View {
    
    @StateObject var profileViewModel: ProfileViewModel
    @ObservedObject var coordinator: AppCoordinator
    init(coordinator: AppCoordinator) {
        self.coordinator = coordinator
        _profileViewModel = StateObject(wrappedValue: ProfileViewModel(
            appState: coordinator.appState
        ))
    }
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                ScrollView {
                    ZStack(alignment: .bottomTrailing) {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 120, height: 120)
                            .foregroundColor(Color.gray.opacity(0.4))
                            .clipShape(Circle())
                            .shadow(radius: 5)
                        
                        if profileViewModel.isEditing {
                            Image(systemName: "pencil.circle.fill")
                                .resizable()
                                .frame(width: 30, height: 30)
                                .foregroundColor(Color.buttonColor)
                                .background(Color.black)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.bottom, 10)
                    
                    
                    VStack(spacing: 20) {
                        
                        
                        HStack(spacing: 15) {
                            ProfileField(
                                title: "First Name",
                                text: $profileViewModel.firstName,
                                isEditable: $profileViewModel.isEditing
                            )
                            ProfileField(
                                title: "Last Name",
                                text: $profileViewModel.lastName,
                                isEditable: $profileViewModel.isEditing
                            )
                        }
                        
                        
                        ProfileField(
                            title: "Email ID",
                            text: $profileViewModel.email,
                            isEditable: $profileViewModel.isEditing
                        )
                        
                        
                        ProfileField(
                            title: "Password",
                            text: $profileViewModel.password,
                            isEditable: $profileViewModel.isEditing,
                            isSecure: true
                        )
                    }
                    .padding(40)
                    
                    
                    
                    VStack(spacing: 5) {
//                        Button(action: profileViewModel.updateButtonAction) {
//                            Text(profileViewModel.buttonText)
//                                .font(.montserrateButtonBoldTitle)
//                                .foregroundColor(.white)
//                                .frame(maxWidth: .infinity)
//                                .padding()
//                                .background(Color.buttonColor)
//                                .cornerRadius(25)
//                        }
//                        
//                        Spacer()
                        Button(action: { profileViewModel.logoutBtn() }) {
                            Text("Logout")
                                .font(.montserrateButtonBoldTitle)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.buttonColor)
                                .cornerRadius(25)
                        }
                        
                        
                    }
                    .padding(.leading,40)
                    .padding(.trailing,40)
                }
                .background(Color.white)
                .edgesIgnoringSafeArea(.horizontal)
                .padding(10)
            }
            
            .onAppear(){
                profileViewModel.setProfileData()
            }
            
        }
        .navigationDestination(isPresented: $profileViewModel.login) {
            LoginView(coordinator: coordinator)
        }
        .safeAreaInset(edge: .top) {
            LogoHeader()
        }
        
        .toolbar {
            if profileViewModel.isEditing {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        profileViewModel.isEditing = false
                    }
                }
            }
        }
        
    }
}
