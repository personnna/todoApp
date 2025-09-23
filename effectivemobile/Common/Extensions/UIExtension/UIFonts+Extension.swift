//
//  UIFonts+Extension.swift
//  effectivemobile
//
//  Created by ellkaden on 23.09.2025.
//

import UIKit

extension UIFont {
    /// Enum representing different font weights available within the custom font family.
    enum FontWeight: String {
        case light = "Light"
        case regular = "Regular"
        case medium = "Medium"
        case semiBold = "SemiBold"
        case bold = "Bold"
    }

    /// An extension to provide access to a custom font family with various font weights.
    private static let appFontName = "SFProDisplay"

    /// Retrieves a custom font for the application with the specified size and weight.
    ///
    /// - Parameters:
    ///   - size: The desired point size of the font.
    ///   - weight: The weight of the font. Defaults to regular.
    /// - Returns: A custom `UIFont` object based on the specified parameters.
    ///
    /// Usage:
    /// ```swift
    /// let myFont = UIFont.appFont(ofSize: 16, weight: .bold)
    /// ```
    ///
    /// Example:
    /// ```swift
    /// let myFont = UIFont.appFont(ofSize: 14)
    /// ```
    ///
    /// Example with UILabel:
    /// ```swift
    /// let label = UILabel()
    /// label.font = .appFont(ofSize: 16)
    /// ```
    ///
    /// - Important: This function assumes that the `appFontName` variable is set to the base name of the application's custom font family.
    /// - Precondition: The specified `appFontName` combined with the provided `weight` parameter should correspond to an available font in the project resources.
    /// - Warning: If the specified font is not found, the function will cause a fatal error.
    ///
    static func appFont(ofSize size: CGFloat, weight: FontWeight = .regular) -> UIFont {
        let fontName = "\(appFontName)-\(weight.rawValue)"
        guard let font = UIFont(name: fontName, size: size) else {
            fatalError("Unable to find a font named \(fontName)!")
        }

        return font
    }
}
