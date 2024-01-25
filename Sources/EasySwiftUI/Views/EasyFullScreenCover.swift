//
//  EasyFullScreenCover.swift
//  EasySwiftUI
//
//  Created by Yevhenii Korsun on 25.09.2023.
//

import SwiftUI
import Combine

public struct CoordinatedItem<T> {
    public let state: T
    public var transition: AnyTransition? = .opacity
    public var completion: OptionalVoid = nil
}

public protocol NavigationalItem: Identifiable {
    var defaultTransition: AnyTransition? { get }
    var groupId: String? { get }
}

@MainActor
public protocol Coordinated: ObservableObject {
    associatedtype FullState: NavigationalItem
    
    @MainActor var navigationStack: [CoordinatedItem<FullState>?] { get set }
    @MainActor func showFull(_ state: FullState, isWithAnimation: Bool, completion: OptionalVoid)
    @MainActor func showFull(_ state: FullState, transition: AnyTransition?, isWithAnimation: Bool, completion: OptionalVoid)
    
    @MainActor func closeTopScreen()
    @MainActor func close(by id: FullState.ID)
}

public extension Coordinated {
    @MainActor func showFull(_ state: FullState, isWithAnimation: Bool = true, completion: OptionalVoid = nil) {
        showFull(state, transition: state.defaultTransition, isWithAnimation: isWithAnimation, completion: completion)
    }
    
    @MainActor func showFull(_ state: FullState, transition: AnyTransition?, isWithAnimation: Bool = true, completion: OptionalVoid = nil) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            
            if let last = self.navigationStack.last, last?.state.id == state.id { return }
            
            hideKeyboard()
            
            if self.navigationStack.compactMap({ $0 }).isEmpty {
                self.navigationStack = []
            }
            
            if let groupId = state.groupId {
                self.navigationStack = self.navigationStack.map { item in
                    item?.state.groupId == groupId ? nil : item
                }
            }
            
            let item = CoordinatedItem(state: state, transition: transition, completion: completion)
            self.navigationStack.append(item)
        }
    }
    
    @MainActor func closeTopScreen() {
        Task { @MainActor [weak self] in
            guard let self else { return }
            
            if let lastIndex = self.navigationStack.lastIndex(where: { $0 != nil }) {
                self.navigationStack[lastIndex] = nil
            }
        }
    }
    
    @MainActor func close(by id: FullState.ID) {
        Task { @MainActor [weak self] in
            guard let self else { return }
            
            self.navigationStack = self.navigationStack.filter({ $0?.state.id != id })
        }
    }
}

public struct EasyDismiss {
    private var dismissAction: (Bool) -> Void
    public func callAsFunction(isWithAnimation: Bool = true) {
        dismissAction(isWithAnimation)
    }
    
    public init(action: @escaping (Bool) -> Void = { _ in }) {
        self.dismissAction = action
    }
    
    public var action: @MainActor () -> Void {
        {
            dismissAction(true)
        }
    }
}

public struct EasyDismissKey: EnvironmentKey {
    public static var defaultValue: EasyDismiss = EasyDismiss()
}

public extension EnvironmentValues {
    var easyDismiss: EasyDismiss {
        get { self[EasyDismissKey.self] }
        set { self[EasyDismissKey.self] = newValue }
    }
}

fileprivate struct DismissableView<Content: View, T>: View {
    @State private var isShow = false
    let transition: AnyTransition?
    let itemToReturn: T
    let completion: OptionalVoid
    @ViewBuilder var content: (T) -> Content
    let closeAction: () -> ()
    
    var body: some View {
        ZStack {
            if let transition = transition {
                if isShow {
                    content(itemToReturn)
                        .transition(transition)
                        .animation(.linear, value: isShow)
                        .environment(\.easyDismiss, EasyDismiss {isWithAnimation in
                            if isWithAnimation {
                                withAnimation {
                                    isShow = false
                                }
                            } else {
                                isShow = false
                            }
                            
                            completion?()
                        })
                        .onDisappear {
                            if !isShow {
                                closeAction()
                            }
                        }
                }
            } else {
                content(itemToReturn)
                    .environment(\.easyDismiss, EasyDismiss { _ in
                        completion?()
                        closeAction()
                    })
            }
        }
        .onAppear {
            hideKeyboard()
            
            withAnimation {
                isShow = true
            }
        }
    }
}

public extension View {
    func easyFullScreenCover<Content>(isPresented: Binding<Bool>, transition: AnyTransition? = .opacity, @ViewBuilder content: @escaping () -> Content) -> some View where Content : View {
        self
            .overlayIf(isPresented.wrappedValue) {
                DismissableView(
                    transition: transition,
                    itemToReturn: isPresented.wrappedValue,
                    completion: nil,
                    content: { _ in
                        content()
                    },
                    closeAction: {
                        isPresented.wrappedValue = false
                    })
            }
    }
    
    func easyFullScreenCover<Content, T>(item: Binding<T?>, transition: AnyTransition? = .opacity, @ViewBuilder content: @escaping (T) -> Content) -> some View where Content : View {
        self
            .overlayIf(item.wrappedValue) { unwrapped in
                DismissableView(
                    transition: transition,
                    itemToReturn: unwrapped,
                    completion: nil,
                    content: content,
                    closeAction: {
                        item.wrappedValue = nil
                    })
            }
    }
    
    @ViewBuilder
    func easyFullScreenCover<Content, T>(stack: Binding<[CoordinatedItem<T>?]>, @ViewBuilder content: @escaping (T) -> Content) -> some View where Content: View {
        self
            .overlay (
                ZStack { // Need to transition work correct
                    ForEach(stack.wrappedValue.indices, id: \.self) { index in
                        if let unwrappedItem = stack[index].wrappedValue {
                            DismissableView(
                                transition: unwrappedItem.transition,
                                itemToReturn: unwrappedItem.state,
                                completion: unwrappedItem.completion,
                                content: content,
                                closeAction: {
                                    stack[safe: index]?.wrappedValue = nil
                                })
                        }
                    }
                }
            )
    }
}

fileprivate func hideKeyboard() {
#if !os(macOS)
    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
#endif
}

fileprivate extension DispatchQueue {
    static func mainWithAnimation(_ isWithAnimation: Bool = true, completion: @escaping () -> Void) {
        DispatchQueue.main.async {
            if isWithAnimation {
                withAnimation {
                    completion()
                }
            } else {
                completion()
            }
        }
    }
}
//
//fileprivate extension Collection {
//    /// Returns the element at the specified index if it is within bounds, otherwise nil.
//    subscript (safe index: Int) -> Element? {
//        guard (self.count) > index, index >= 0 else { return nil }
//        let answerIndex = self.index(self.startIndex, offsetBy: index)
//        return self[answerIndex]
//    }
//}
