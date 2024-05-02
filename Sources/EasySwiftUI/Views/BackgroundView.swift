//
//  BackgroundView.swift
//
//
//  Created by Jenya Korsun on 19.03.2024.
//

import SwiftUI

public enum BackgroundState {
#if os(macOS)
    case effect(NSVisualEffectView.Material)
#else
    case effect(UIBlurEffect.Style)
#endif
    
    case material(Material)
    case color(Color)
}

public struct BackgroundView: View {
    var state: BackgroundState
    
    public init(state: BackgroundState = .color(EasySwiftUI.appBackground)) {
        self.state = state
    }
    
    public var body: some View {
        Group {
            switch state {
            case .effect(let style):
                BlurView(style: style)
            case .material(let material):
                Color.clear
                    .background(material)
            case .color(let color):
                color
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    BackgroundView()
}
