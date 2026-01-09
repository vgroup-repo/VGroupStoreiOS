//
//  LoaderManager.swift
//  JustToysWorldApp
//
//  Created by Satyam on 06/01/26.
//

import SwiftUI
import Combine
//final class LoaderManager: ObservableObject {
//    @Published var isLoading: Bool = false
//
//    func show() {
//        withAnimation(.easeInOut(duration: 0.2)) {
//            isLoading = true
//        }
//    }
//
//    func hide() {
//        withAnimation(.easeInOut(duration: 0.2)) {
//            isLoading = false
//        }
//    }
//}
//struct BubbleLoader: View {
//    @State private var rotate = false
//
//    var body: some View {
//        ZStack {
//            ForEach(0..<6) { index in
//                Circle()
//                    .fill(Color.white)
//                    .frame(width: 12, height: 12)
//                    .offset(y: -25)
//                    .rotationEffect(.degrees(Double(index) * 60))
//            }
//        }
//        .rotationEffect(.degrees(rotate ? 360 : 0))
//        .animation(
//            Animation.linear(duration: 1.2)
//                .repeatForever(autoreverses: false),
//            value: rotate
//        )
//        .onAppear {
//            rotate = true
//        }
//    }
//}
//struct CustomLoaderView: View {
//    var body: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 20)
//                .fill(Color.black.opacity(0.85))
//                .frame(width: 120, height: 120)
//                .shadow(color: .black.opacity(0.4), radius: 10)
//
//            VStack(spacing: 16) {
//                BubbleLoader()
//
//                Text("Loading...")
//                    .font(.system(size: 14, weight: .medium))
//                    .foregroundColor(.white.opacity(0.8))
//            }
//        }
//        .transition(.scale.combined(with: .opacity))
//    }
//}
//struct LoaderOverlay: View {
//    @EnvironmentObject var loader: LoaderManager
//
//    var body: some View {
//        if loader.isLoading {
//            ZStack {
//                Color.black.opacity(0.25)
//                    .ignoresSafeArea()
//
//                CustomLoaderView()
//            }
//            .zIndex(999)
//        }
//    }
//}



final class LoaderManager: ObservableObject {
    @Published var isLoading: Bool = false

    func show() {
        DispatchQueue.main.async {
            self.isLoading = true
        }
    }

    func hide() {
        DispatchQueue.main.async {
            self.isLoading = false
        }
    }
}


struct BubbleLoader: View {
    @State private var rotation: Double = 0

    var body: some View {
        ZStack {
            ForEach(0..<8) { index in
                Circle()
                    .fill(Color.white)
                    .frame(width: 10, height: 10)
                    .offset(y: -25)
                    .rotationEffect(.degrees(Double(index) * 45))
                    .opacity(Double(index) / 8)
            }
        }
        .rotationEffect(.degrees(rotation))
        .onAppear {
            withAnimation(
                .linear(duration: 1)
                .repeatForever(autoreverses: false)
            ) {
                rotation = 360
            }
        }
    }
}
struct CustomLoaderView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.35)
                .ignoresSafeArea()

            VStack {
                BubbleLoader()
            }
            .frame(width: 120, height: 120)
            .background(Color.black.opacity(0.85))
            .cornerRadius(20)
            .shadow(color: .black.opacity(0.4), radius: 10)
        }
        .transition(.opacity.combined(with: .scale))
    }
}
struct LoaderOverlay: ViewModifier {
    @ObservedObject var loader: LoaderManager

    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(loader.isLoading)

            if loader.isLoading {
                CustomLoaderView()
            }
        }
        .animation(.easeInOut(duration: 0.25), value: loader.isLoading)
    }
}
extension View {
    func showLoader(_ loader: LoaderManager) -> some View {
        self.modifier(LoaderOverlay(loader: loader))
    }
}
