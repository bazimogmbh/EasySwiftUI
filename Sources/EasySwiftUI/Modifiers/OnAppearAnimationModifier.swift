//
//  OnAppearAnimationModifier.swift
//  EasySwiftUI
//
//  Created by Yevhenii Korsun on 25.09.2023.
//

import SwiftUI

fileprivate struct OnAppearAnimationModifier: ViewModifier {
    @State private var showAnimation: Bool = false
    
    func body(content: Content) -> some View {
        content
            .opacity(0)
            .overlay (
                Group {
                    if showAnimation {
                        content
                    }
                }
            )
            .onAppear {
                showAnimation = true
            }
    }
}

public extension View {
    func addOnAppearAnimation() -> some View {
        modifier(OnAppearAnimationModifier())
    }
}
