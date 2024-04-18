//
//  KeyboardHelper.swift
//  EasySwiftUI
//
//  Created by Yevhenii Korsun on 25.09.2023.
//

import SwiftUI
import Combine

public protocol KeyboardHelper {
    var isShowKeyboardPublisher: AnyPublisher<Bool, Never> { get }
    func closeKeyboard()
}

public extension KeyboardHelper {
    var isShowKeyboardPublisher: AnyPublisher<Bool, Never> {
#if os(macOS) || os(tvOS)
        Just(false)
            .eraseToAnyPublisher()
#else
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .map { _ in true },
            
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in false }
        )
        .eraseToAnyPublisher()
#endif
    }
    
    func closeKeyboard() {
#if !os(macOS) && !os(tvOS)
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
#endif
    }
}
