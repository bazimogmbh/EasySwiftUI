//
//  CustomButton.swift
//  
//
//  Created by Yevhenii Korsun on 27.09.2023.
//


import SwiftUI

public enum ButtonTapEffect {
    case `default`, scale
}

@available(macOS 12, *)
public struct CustomButton<Content>: View where Content: View {
    private var tapEffect: ButtonTapEffect = .scale
    private var action: (@MainActor () -> Void)? = nil
    private var actionWithProxy: (@MainActor (GeometryProxy) -> Void)? = nil
    private var label: () -> Content
    
    public init(
        effect: ButtonTapEffect = .scale,
        action: @escaping @MainActor () -> Void,
        @ViewBuilder label: @escaping () -> Content
    ) {
        self.init(effect: effect, action: action, actionWithProxy: nil, label: label)
    }
    
    public init(
        effect: ButtonTapEffect = .scale,
        action: @escaping @MainActor (GeometryProxy) -> Void,
        @ViewBuilder label: @escaping () -> Content
    ) {
        self.init(effect: effect, action: nil, actionWithProxy: action, label: label)
    }
    
    public init(
        effect: ButtonTapEffect = .scale,
        action: (@MainActor () -> Void)?,
        actionWithProxy: (@MainActor (GeometryProxy) -> Void)?,
        @ViewBuilder label: @escaping () -> Content
    ) {
        self.tapEffect = effect
        self.action = action
        self.actionWithProxy = actionWithProxy
        self.label = label
    }
    
    public var body: some View {
        if actionWithProxy != nil {
            button()
                .hidden()
                .overlay {
                    GeometryReader { proxy in
                        button(action: { actionWithProxy?(proxy) })
                    }
                }
        } else {
            button(action: action)
        }
    }
    
    @MainActor
    private func button(action: (@MainActor () -> Void)? = nil) -> some View {
        Button {
            action?()
        } label: {
            label()
                .allowsHitTesting(false)
                .overlay {
                    Color.white.opacity(0.011)
                }
        }
        .addButtonStyle(by: tapEffect)
    }
}

fileprivate extension View {
    @ViewBuilder
    func addButtonStyle(by tapEffect: ButtonTapEffect) -> some View {
        switch tapEffect {
        case .default:
            self
        case .scale:
            self
                .buttonStyle(CustomLabelButtonStyle())
        }
    }
}

@available(macOS 12, *)
fileprivate struct CustomLabelButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
    }
}
