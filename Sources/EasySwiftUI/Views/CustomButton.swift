//
//  CustomButton.swift
//  
//
//  Created by Yevhenii Korsun on 27.09.2023.
//

#if !os(macOS)

import SwiftUI

public struct CustomButton<Content>: View where Content: View {
    var action: @MainActor () -> () = {}
    var label: () -> Content
    
    public init(
        action: @escaping () -> Void,
        @ViewBuilder label: @escaping () -> Content
    ) {
        self.action = action
        self.label = label
    }
    
    public var body: some View {
        Button(action: action) {
            label()
                .allowsHitTesting(false)
                .overlay {
                    Color.transparent
                }
        }
            .buttonStyle(CustomLabelButtonStyle())
    }
}

struct CustomLabelButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
    }
}

#endif
