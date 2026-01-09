//
//  ColorExtension.swift
//  JustToysWorldApp
//
//  Created by Satyam on 21/11/25.
//

import Foundation
import SwiftUI

extension Color {
    
    static let themeColor = Color(hex: "#fd6266")
    static let buttonColor = Color(hex: "#6e0205")
    static let accentRed = Color(hex: "#E95459")
    init(hex: String, opacity: Double = 1.0) {
        var cleanHexCode = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        cleanHexCode = cleanHexCode.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        guard cleanHexCode.count == 6 else {
            self.init(.clear)
            return
        }
        Scanner(string: cleanHexCode).scanHexInt64(&rgb)
        let red = Double((rgb & 0xFF0000) >> 16) / 255.0
        let green = Double((rgb & 0x00FF00) >> 8) / 255.0
        let blue = Double(rgb & 0x0000FF) / 255.0
        
        self.init(
            .sRGB,
            red: red,
            green: green,
            blue: blue,
            opacity: opacity
        )
    }
    
    static func fromHex(_ hex: String, opacity: Double = 1.0) -> Color {
        return Color(hex: hex, opacity: opacity)
    }
}
