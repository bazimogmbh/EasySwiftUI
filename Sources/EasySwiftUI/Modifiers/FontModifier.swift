//
//  FontModifier.swift
//  EasySwiftUI
//
//  Created by Yevhenii Korsun on 25.09.2023.
//

import SwiftUI

public enum FontType {
    case ultraLight100
    case thin200
    case light300
    case regular400
    case medium500
    case semibold600
    case bold700
    case heavy800
    case black900

    public var weight: Font.Weight {
        switch self {
        case .ultraLight100: return .ultraLight
        case .thin200: return .thin
        case .light300: return .light
        case .regular400: return .regular
        case .medium500: return .medium
        case .semibold600: return .semibold
        case .bold700: return .bold
        case .heavy800: return .heavy
        case .black900: return .black
        }
    }
}

fileprivate struct FontModifier: ViewModifier {
    let font: Font
    let color: Color?
    let scaleFactor: CGFloat

    func body(content: Content) -> some View {
        if let color = color {
            content
                .font(font)
                .foregroundColor(color)
                .minimumScaleFactor(scaleFactor)
        } else {
            content
                .font(font)
                .minimumScaleFactor(scaleFactor)
        }
    }
}

public extension View {
    func customFont(_ font: Font, color: Color? = EasySwiftUI.appForeground, scaleFactor: CGFloat = EasySwiftUI.textScaleFactor) -> some View {
        self
            .modifier(FontModifier(font: font, color: color, scaleFactor: scaleFactor))
    }
    
    func customFont(_ font: FontType, size: Double, color: Color? = EasySwiftUI.appForeground, scaleFactor: CGFloat = EasySwiftUI.textScaleFactor) -> some View {
        self
            .customFont(.system(size: size, weight: font.weight), color: color, scaleFactor: scaleFactor)
    }
}

// MARK: - How to use with CustomFont

//enum CustomFont: String {
//    case someFont = "SomeFontRegular"
//}
//
//extension View {
//    func customFont(_ font: CustomFont, size: Double, color: Color? = .appForeground, scaleFactor: CGFloat = 0.7) -> some View {
//        self
//            .customFont(.custom(font.rawValue, size: size), color: color, scaleFactor: scaleFactor)
//    }
//}

// MARK: - New logic

public struct AppFont: Hashable {
    public let name: String
    
    public init(_ name: String) {
        self.name = name
    }
}

public extension View {
    @ViewBuilder
    func customFont(_ font: AppFont, size: Double, color: Color? = EasySwiftUI.appForeground) -> some View {
        if let color = color {
            self
                .font(.custom(font.name, size: size))
                .foregroundColor(color)
        } else {
            self
                .font(.custom(font.name, size: size))
        }
    }
}

public extension Text {
    func customFont(_ font: AppFont, size: Double, color: Color? = EasySwiftUI.appForeground) -> Text {
        if let color = color {
            self
                .font(.custom(font.name, size: size))
                .foregroundColor(color)
        } else {
            self
                .font(.custom(font.name, size: size))
        }
    }
}

// MARK: - How to use

//extension AppFont {
//    static let mainFont = AppFont(name: "Font name")
//    static let boldFont = AppFont(name: "Font name")
//}
