//
//  StyleGuide.swift
//  JustToysWorldApp
//
//  Created by Satyam on 24/11/25.
//

import SwiftUI

// MARK: - Montserrat Font Styles
enum MontserratStyle: String {
    case regular = "Regular"
    case medium = "Medium"
    case semiBold = "SemiBold"
    case bold = "Bold"
    case light = "Light"
    case extraLight = "ExtraLight"
    case extraBold = "ExtraBold"
    case black = "Black"
    case thin = "Thin"
    
    var fontName: String {
        return "Montserrat-\(self.rawValue)"
    }
}

// MARK: - Font Extension for SwiftUI Usage
extension Font {
    static func montserrate(_ style: MontserratStyle, size: CGFloat) -> Font {
        return .custom(style.fontName, size: size)
    }
    
    static var montserrateButtonMediumTitle: Font {
        .montserrate(.regular, size: 17.0)
    }
    
    static var montserrateButtonBoldTitle: Font {
        .montserrate(.bold, size: 18.0)
    }
    
    static var montserrateSmallButtonSemiBoldTitle: Font {
        .montserrate(.semiBold, size: 14.0)
    }
    
    static var montserrateTabButtonTitle: Font {
        .montserrate(.regular, size: 16.0)
    }
}
