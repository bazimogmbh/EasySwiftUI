//
//  View+Extensions.swift
//  EasySwiftUI
//
//  Created by Yevhenii Korsun on 18.09.2023.
//

#if !os(macOS)

import SwiftUI

public enum FrameAlignment {
    case top, bottom, leading, trailing
}

public extension View {
    @ViewBuilder
    func alignment(_ alignment: FrameAlignment) -> some View {
        switch alignment {
        case .top:
            self
                .frame(maxHeight: .infinity, alignment: .top)
        case .bottom:
            self
                .frame(maxHeight: .infinity, alignment: .bottom)
        case .leading:
            self
                .frame(maxWidth: .infinity, alignment: .leading)
        case .trailing:
            self
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}

public extension View {
    @MainActor
    func onTap(action: @escaping @MainActor () -> Void) -> some View {
        self
            .overlay {
                Color.transparent
            }
            .onTapGesture {
                action()
            }
    }
    
    func overlayIf<Content: View>(_ condition: Bool, alignment: Alignment = .center, @ViewBuilder content: @escaping () -> Content) -> some View {
        self
            .overlay(
                ZStack(alignment: alignment) {
                    Color.clear
                    
                    if(condition) {
                        content()
                    }
                }
            )
    }
    
    func overlayIf<Content: View, T>(_ condition: Optional<T>, alignment: Alignment = .center, @ViewBuilder content: @escaping (T) -> Content) -> some View {
        self
            .overlayIf(condition != nil, alignment: alignment) {
                content(condition!)
            }
    }
    
    func bluredIf(_ condition: Bool, radius: CGFloat = 4, tapAction: @escaping () -> Void) -> some View {
        self
            .blur(radius: condition ? radius : 0)
            .overlayIf(condition) {
                Color.transparent
                    .onTapGesture(perform: tapAction)
            }
    }
    
    @ViewBuilder
    func customDisabled(_ isDisabled: Bool) -> some View {
        self
            .disabled(isDisabled)
            .mask {
                Color.black.opacity(isDisabled ? 0.4 : 1)
            }
    }
    
    @ViewBuilder func `if`<Content: View>(_ condition: @autoclosure () -> Bool, transform: (Self) -> Content) -> some View {
        if condition() {
            transform(self)
        } else {
            self
        }
    }
    
    @ViewBuilder func `if`<Content: View, T>(_ condition: @autoclosure () -> Optional<T>, transform: (T, Self) -> Content) -> some View {
        if condition() != nil {
            transform(condition()!, self)
        } else {
            self
        }
    }

    func makeScrollCellEasyTapable() -> some View {
        self
            .buttonStyle(ScrollButtonStyle())
    }
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        return self
            .applyRadius(radius, if: corners, contains: .topLeft)
            .applyRadius(radius, if: corners, contains: .topRight)
            .applyRadius(radius, if: corners, contains: .bottomLeft)
            .applyRadius(radius, if: corners, contains: .bottomRight)
    }
    
    private func applyRadius(_ radius: CGFloat, if corners: UIRectCorner, contains element: UIRectCorner) -> some View {
        return self
            .padding(padding(radius, for: corners.contains(element) ? element : []))
            .cornerRadius(radius)
            .padding(padding(-radius, for: corners.contains(element) ? element : []))
        
        func padding(_ value: CGFloat, for corners: UIRectCorner) -> EdgeInsets {
            return EdgeInsets(top: corners.isDisjoint(with: [.topLeft, .topRight]) ? value: 0,
                              leading: corners.isDisjoint(with: [.topLeft, .bottomLeft]) ? value: 0,
                              bottom: corners.isDisjoint(with: [.bottomLeft, .bottomRight]) ? value: 0,
                              trailing: corners.isDisjoint(with: [.topRight, .bottomRight]) ? value: 0)
        }
    }
    
    func upsideDown() -> some View {
        self
            .rotationEffect(Angle(degrees: 180))
            .scaleEffect(x: -1, y: 1, anchor: .center)
    }
    
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func asButton(action: @escaping @MainActor () -> Void) -> some View {
        CustomButton(action: action) {
            self
        }
    }
}

fileprivate struct ScrollButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 1 : 1)
    }
}

#endif
