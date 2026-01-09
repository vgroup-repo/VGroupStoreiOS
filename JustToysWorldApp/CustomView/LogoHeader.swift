//
//  LogoHeader.swift
//  JustToysWorldApp
//
//  Created by Satyam on 28/11/25.
//

import SwiftUI
struct LogoHeader: View {
    var body: some View {
        HStack {
            Spacer()
            Image("negivation_logo")
            
                .resizable()
                .scaledToFit()
                .frame(width: 180, height: 45)
            Spacer()
        }
        .background(Color.themeColor)
    }
}

#Preview {
    LogoHeader()
}
