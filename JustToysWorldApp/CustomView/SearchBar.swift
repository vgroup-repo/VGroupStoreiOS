//
//  SearchBar.swift
//  JustToysWorldApp
//
//  Created by Satyam on 28/11/25.
//

import SwiftUI

struct SearchBar: View {
    @Binding var searchText: String
    let onSearch: () -> Void
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
                .padding(.leading, 10)
            ZStack(alignment: .leading) {
                if searchText.isEmpty {
                    Text("Search")
                        .foregroundColor(.gray)
                        .font(.montserrate(.medium, size: 15))
                }

                TextField("", text: $searchText)
                    .foregroundColor(.black)
                    .font(.montserrate(.medium, size: 15))
            }
            .padding(.vertical, 10)
            .submitLabel(.search)
            .onSubmit(onSearch)
            
            Button(action: onSearch) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.white)
                    .padding(8)
                    .background(Color.buttonColor)
                    .clipShape(Circle())
            }
            .padding(.trailing, 5)
        }
        .background(Color.white)
        .cornerRadius(30)
        .overlay(
            RoundedRectangle(cornerRadius: 30)
                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
        )
        .padding(.horizontal)
    }
}
