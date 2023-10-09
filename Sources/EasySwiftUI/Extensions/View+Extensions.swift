//
//  View+Extensions.swift
//  EasySwiftUI
//
//  Created by Yevhenii Korsun on 18.09.2023.
//

import SwiftUI

@available(macOS 12, *)
public enum FrameAlignment {
    case top, bottom, leading, trailing
}

public struct RectCorner: OptionSet {
    public let rawValue: Int

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    public static let topLeft = RectCorner(rawValue: 1 << 0)
    public static let topRight = RectCorner(rawValue: 1 << 1)
    public static let bottomRight = RectCorner(rawValue: 1 << 2)
    public static let bottomLeft = RectCorner(rawValue: 1 << 3)

    public static let allCorners: RectCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
}

@available(macOS 12, *)
public extension View {
    func cornerRadius(_ radius: CGFloat, corners: RectCorner) -> some View {
        return self
            .applyRadius(radius, if: corners, contains: .topLeft)
            .applyRadius(radius, if: corners, contains: .topRight)
            .applyRadius(radius, if: corners, contains: .bottomLeft)
            .applyRadius(radius, if: corners, contains: .bottomRight)
    }
    
    private func applyRadius(_ radius: CGFloat, if corners: RectCorner, contains element: RectCorner) -> some View {
        return self
            .padding(padding(radius, for: corners.contains(element) ? element : []))
            .cornerRadius(radius)
            .padding(padding(-radius, for: corners.contains(element) ? element : []))
        
        func padding(_ value: CGFloat, for corners: RectCorner) -> EdgeInsets {
            return EdgeInsets(top: corners.isDisjoint(with: [.topLeft, .topRight]) ? value: 0,
                              leading: corners.isDisjoint(with: [.topLeft, .bottomLeft]) ? value: 0,
                              bottom: corners.isDisjoint(with: [.bottomLeft, .bottomRight]) ? value: 0,
                              trailing: corners.isDisjoint(with: [.topRight, .bottomRight]) ? value: 0)
        }
    }
}


@available(macOS 12, *)
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

@available(macOS 12, *)
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
    
    func upsideDown() -> some View {
        self
            .rotationEffect(Angle(degrees: 180))
            .scaleEffect(x: -1, y: 1, anchor: .center)
    }
    
    func hideKeyboard() {
#if os(macOS)
        NSApp.keyWindow?.firstResponder?.tryToPerform(#selector(NSResponder.resignFirstResponder), with: nil)
#else
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
#endif
    }
    
    func asButton(action: @escaping @MainActor () -> Void) -> some View {
        CustomButton(action: action) {
            self
        }
    }
}

@available(macOS 12, *)
fileprivate struct ScrollButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 1 : 1)
    }
}
