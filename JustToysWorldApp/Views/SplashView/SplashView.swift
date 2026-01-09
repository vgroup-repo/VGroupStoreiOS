//
//  SplashView.swift
//  JustToysWorldApp
//
//  Created by Satyam on 20/11/25.
//

import SwiftUI

struct SplashView: View {
    
    @Binding var isFinished: Bool
    @State private var opacityLevel: Double = 0.0
    @State private var scale: CGFloat = 0.8
    
    var body: some View {
        VStack {
            Spacer()
            Image("logo")
                .resizable()
                .scaledToFit()
                .frame(width: 250, height: 200)
            
            ProgressView()
                .padding(.top, 40)
                .scaleEffect(1.5)
                .opacity(opacityLevel)
            Spacer()
            Text("Version V1.0")
                .font(.montserrate(.regular, size: 16))
                .foregroundColor(.white)
        }
        .padding(50)
        .frame(minWidth: 400, minHeight: 500)
        .background(Color.themeColor)
        
        .onAppear {
            
            withAnimation(.easeInOut(duration: 1.0)) {
                opacityLevel = 1.0
                scale = 1.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeOut(duration: 0.5)) {
                    
                    opacityLevel = 0.0
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.isFinished = false
                }
            }
        }
    }
    
}
#Preview {
    SplashView(isFinished: .constant(true))
}
