//
//  SwiftUIView.swift
//  
//
//  Created by Yevhenii Korsun on 01.11.2023.
//

import SwiftUI
import Combine

public extension View {
    
    /// Sets an environment value for keyboardShowing
    /// Access this in any child view with
    /// @Environment(\.keyboardIsShowing) var keyboardIsShowing
    func addKeyboardVisibilityToEnvironment() -> some View {
        modifier(KeyboardVisibility())
    }
}

private struct KeyboardShowingEnvironmentKey: EnvironmentKey {
    static let defaultValue: Bool = false
}

public extension EnvironmentValues {
    var isKeyboardShowing: Bool {
        get { self[KeyboardShowingEnvironmentKey.self] }
        set { self[KeyboardShowingEnvironmentKey.self] = newValue }
    }
}

private struct KeyboardVisibility: ViewModifier {
    
#if os(macOS)
    
    fileprivate func body(content: Content) -> some View {
        content
            .environment(\.keyboardShowing, false)
    }
    
#else
    
    @State var isKeyboardShowing: Bool = false
    
    private var keyboardPublisher: AnyPublisher<Bool, Never> {
        Publishers
            .Merge(
                NotificationCenter
                    .default
                    .publisher(for: UIResponder.keyboardWillShowNotification)
                    .map { _ in true },
                NotificationCenter
                    .default
                    .publisher(for: UIResponder.keyboardWillHideNotification)
                    .map { _ in false })
            .debounce(for: .seconds(0.1), scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    fileprivate func body(content: Content) -> some View {
        content
            .environment(\.isKeyboardShowing, isKeyboardShowing)
            .onReceive(keyboardPublisher) { value in
                isKeyboardShowing = value
            }
    }
    
#endif
}
