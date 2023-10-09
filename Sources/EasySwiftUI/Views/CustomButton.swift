//
//  CustomButton.swift
//  
//
//  Created by Yevhenii Korsun on 27.09.2023.
//


import SwiftUI

@available(macOS 12, *)
public struct CustomButton<Content>: View where Content: View {
    var action: @MainActor () -> () = {}
    var label: () -> Content
    
    public init(
        action: @escaping @MainActor () -> Void,
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

@available(macOS 12, *)
fileprivate struct CustomLabelButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
    }
}
