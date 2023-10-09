//
//  ZStackWithBackground.swift
//  EasySwiftUI
//
//  Created by Yevhenii Korsun on 25.09.2023.
//

import SwiftUI

public enum BackgroundState {
#if os(macOS)
    case material(NSVisualEffectView.Material)
#else
    case material(UIBlurEffect.Style)
#endif
    
    case color(Color)
}

public struct ZStackWithBackground<Content: View>: View {
    var state: BackgroundState = .color(EasySwiftUI.appBackground)
    var alignment: Alignment = .center
    
    @ViewBuilder let content: () -> Content
    
    public init(
        _ state: BackgroundState = .color(EasySwiftUI.appBackground),
        alignment: Alignment = .center,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.state = state
        self.alignment = alignment
        self.content = content
    }
    
    public var body: some View {
        ZStack(alignment: alignment) {
            switch state {
            case .material(let material):
                BlurView(style: material)
                     .ignoresSafeArea()
            case .color(let color):
                color
                    .ignoresSafeArea()
            }
            
            content()
        }
    }
}

public extension ZStackWithBackground {
    init(
        color: Color,
        alignment: Alignment = .center,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.state = .color(color)
        self.alignment = alignment
        self.content = content
    }
}
