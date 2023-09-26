//
//  KeyboardHelper.swift
//  EasySwiftUI
//
//  Created by Yevhenii Korsun on 25.09.2023.
//

#if !os(macOS)

import SwiftUI
import Combine

protocol KeyboardHelper {
    var isShowKeyboardPublisher: AnyPublisher<Bool, Never> { get }
    func closeKeyboard()
}

extension KeyboardHelper {
    var isShowKeyboardPublisher: AnyPublisher<Bool, Never> {
        Publishers.Merge(
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillShowNotification)
                .map { _ in true },
            
            NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in false }
        )
        .eraseToAnyPublisher()
    }
    
    func closeKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

#endif
