//
//  DismissModifier.swift
//  EasySwiftUI
//
//  Created by Yevhenii Korsun on 25.09.2023.
//

import SwiftUI

public protocol Dismissable: ObservableObject {
    @MainActor var closeView: Bool { get set }
    @MainActor func dismiss()
}

public extension Dismissable {
    @MainActor func dismiss() {
        self.closeView = true
    }
}

fileprivate struct DismissModifier<T: Dismissable>: ViewModifier {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.easyDismiss) private var easyDismiss
    
    @ObservedObject var vm: T
    var type: DismissType
    
    func body(content: Content) -> some View {
        content
            .onChange(of: vm.closeView) { closeView in
                if closeView {
                    vm.closeView = false
                    
                    switch type {
                    case .easyDismiss:
                        easyDismiss()
                    case .dismiss:
                        dismiss()
                    }
                }
            }
    }
}

public enum DismissType {
    case easyDismiss, dismiss
}

public extension View {
    func bindDismiss<T: Dismissable>(with vm: T, type: DismissType = .easyDismiss) -> some View {
        modifier(DismissModifier(vm: vm, type: type))
    }
}
