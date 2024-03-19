//
//  BackgroundView.swift
//
//
//  Created by Jenya Korsun on 19.03.2024.
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

public struct BackgroundView: View {
    var state: BackgroundState
    
    public init(state: BackgroundState = .color(EasySwiftUI.appBackground)) {
        self.state = state
    }
    
    public var body: some View {
        Group {
            switch state {
            case .material(let material):
                BlurView(style: material)
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
