//
//  CustomTabBar.swift
//  JustToysWorldApp
//
//  Created by Satyam on 28/11/25.
//

import SwiftUI

enum Tab: CaseIterable {
    case home, search, cart, user

    var title: String {
        switch self {
        case .home: return "Home"
        case .search: return "Search"
        case .cart: return "Cart"
        case .user: return "User"
        }
    }

    //MARK: -  Your existing image assets
    var image: String {
        switch self {
        case .home: return "tab_icon_home"
        case .search: return "tab_icon_search"
        case .cart: return "tab_icon_cart"
        case .user: return "tab_icon_profile"
        }
    }

    //MARK: -  Temporary SF Symbol (used ONLY during animation)
    var systemIcon: String {
        switch self {
        case .home: return "house.fill"
        case .search: return "magnifyingglass"
        case .cart: return "cart.fill"
        case .user: return "person.fill"
        }
    }
}




struct CustomTabBar: View {

    @Binding var selectedTab: Tab

    // MARK: - Animation States
    @State private var wave: CGFloat = 0
    @State private var barHeight: CGFloat = 50
    @State private var rippleOffset: CGFloat = 0
    @State private var animatingTab: Tab? = nil
    @EnvironmentObject var cartManager: CartManager
    private let tabs = Tab.allCases

    var body: some View {
        GeometryReader { geo in
            let totalWidth = geo.size.width
            let tabWidth = totalWidth / CGFloat(tabs.count)
            let safeWidth = max(tabWidth - 16, 1)

            ZStack(alignment: .leading) {

                // MARK: -  Liquid Background
                LiquidCapsule(wave: wave)
                    .fill(Color.blue.opacity(0.12))
                    .frame(width: safeWidth, height: barHeight)
                    .offset(x: indicatorOffset(tabWidth))
                    .animation(.easeInOut(duration: 0.35), value: selectedTab)

                // Tabs
                HStack(spacing: 0) {
                    ForEach(tabs, id: \.self) { tab in
                        tabItem(tab, width: tabWidth)
                    }
                }
            }
            .padding(2)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 32))
            .shadow(color: .black.opacity(0.40), radius: 4, y: -1) //-1
            .offset(y: rippleOffset)
        }
        .frame(height: 50)
        .padding(.horizontal, 20)
    }

    // MARK: - TAB ITEM
    private func tabItem(_ tab: Tab, width: CGFloat) -> some View {
        let isSelected = selectedTab == tab
        let isAnimating = animatingTab == tab

        return Button {
            startFullAnimation(for: tab)
        } label: {
            VStack(spacing: 2) {
                ZStack(alignment: .topTrailing) {
                    // 🔁 Image swap logic
                    if isAnimating {
                        Image(systemName: tab.systemIcon)
                            //.font(.system(size: 17, weight: .semibold))
                            .font(.montserrate(.semiBold, size: 20))
                    } else {
                        Image(tab.image)
                            .renderingMode(.template)
                    }
                    if tab == .cart && cartManager.count > 0 {
                                            badgeView(cartManager.count)
                                        }
                }

                Text(tab.title)
                    //.font(.system(size: 10))
                    .font(.montserrate(.regular, size: 10))
            }
            .foregroundColor(isSelected ? .black : .gray)
            .scaleEffect(isAnimating ? 1.12 : 1.0)
            .frame(width: width)
            .contentShape(Rectangle())
            .animation(.easeOut(duration: 0.18), value: isAnimating)
        }
        .buttonStyle(.plain)
    }

    // MARK: - FULL WATER + ICON ANIMATION
    private func startFullAnimation(for tab: Tab) {

        // Switch icon to SF Symbol
        animatingTab = tab

        // Water splash
        withAnimation(.easeOut(duration: 0.12)) {
            barHeight = 72
            rippleOffset = -2
            wave += 1
        }

        // Move selection
        withAnimation(.easeInOut(duration: 0.35)) {
            selectedTab = tab
        }

        // Settle back
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.12) {
            withAnimation(.easeInOut(duration: 0.25)) {
                barHeight = 50
                rippleOffset = 0
            }
        }

        //Restore original icon
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.28) {
            if animatingTab == tab {
                animatingTab = nil
            }
        }
    }
    private func badgeView(_ count: Int) -> some View {
            Text("\(count)")
                .font(.montserrate(.bold, size: 9))
                .foregroundColor(.white)
                .padding(4)
                .background(Circle().fill(Color.red))
                .offset(x: 8, y: -6)
        }

    // MARK: - Indicator Offset
    private func indicatorOffset(_ width: CGFloat) -> CGFloat {
        let index = tabs.firstIndex(of: selectedTab) ?? 0
        return CGFloat(index) * width + 8
    }
}





struct LiquidCapsule: Shape {
    var wave: CGFloat

    var animatableData: CGFloat {
        get { wave }
        set { wave = newValue }
    }

    func path(in rect: CGRect) -> Path {
        let radius = rect.height / 2
        let stretch = 8 * sin(wave * .pi)

        var path = Path()
        path.addRoundedRect(
            in: rect.insetBy(dx: -stretch, dy: 0),
            cornerSize: CGSize(width: radius, height: radius)
        )
        return path
    }
}
