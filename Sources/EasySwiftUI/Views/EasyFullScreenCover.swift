//
//  EasyFullScreenCover.swift
//  EasySwiftUI
//
//  Created by Yevhenii Korsun on 25.09.2023.
//

import SwiftUI
import Combine

public struct CoordinatedItem<T> {
    let date = Date()
    let state: T
    
    var id: String
    var parentId: String
    
    var transition: AnyTransition = .opacity
    var animation: Animation = .linear
    
    var completion: OptionalVoid = nil
}

public protocol NavigationalItem: Identifiable {
    var defaultTransition: AnyTransition { get }
    var groupId: String? { get }
}

public extension NavigationalItem {
    var defaultAnimation: Animation {
        .linear
    }
    
    var id: String {
        let mirror = Mirror(reflecting: self)
        return mirror.children.first?.label ?? ""
    }
}

@MainActor
public protocol Coordinated: ObservableObject {
    associatedtype FullState: NavigationalItem
    
    
    var viewIdIfStackIsEmpty: String { get }
    var navigationStack: [CoordinatedItem<FullState>?] { get set }
    
    func showFull(_ state: FullState, completion: OptionalVoid)
    func showFull(_ state: FullState, transition: AnyTransition, animation: Animation, timeout: TimeInterval, completion: OptionalVoid)
    func closeTopScreen()
    
    func close(by id: FullState.ID)
}

public extension Coordinated {
    func showFull(_ state: FullState, completion: OptionalVoid = nil) {
        showFull(
            state,
            transition: state.defaultTransition,
            animation: state.defaultAnimation,
            completion: completion
        )
    }
    
    func showFull(
        _ state: FullState,
        transition: AnyTransition,
        animation: Animation = .linear,
        timeout: TimeInterval = 0,
        completion: OptionalVoid = nil
    ) {
        if let date = navigationStack.last??.date, Date().timeIntervalSince(date) < timeout {
            return
        }
        
        if let last = self.navigationStack.last, last?.state.id == state.id { return }
        
        if self.navigationStack.compactMap({ $0 }).isEmpty {
            self.navigationStack = []
        }
        
        let id = String(self.navigationStack.endIndex)
        
        let parentId = {
            if let id = self.navigationStack.lastIndex(where: { $0 != nil }) {
                return String(id)
            }
            
            return self.viewIdIfStackIsEmpty
        }()
        
        let item = CoordinatedItem(
            state: state,
            id: id,
            parentId: parentId,
            transition: transition,
            animation: animation,
            completion: completion
        )
        self.navigationStack.append(item)
    }
    
    func closeTopScreen() {
        if let lastIndex = self.navigationStack.lastIndex(where: { $0 != nil }) {
            self.navigationStack[lastIndex] = nil
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
    private var dismissAction: () -> Void
    public func callAsFunction() {
        dismissAction()
    }
    
    public init(action: @escaping () -> Void = { }) {
        self.dismissAction = action
    }
    
    public var action: @MainActor () -> Void {
        {
            dismissAction()
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

fileprivate struct DismissableView<Content: View, T>: View, Equatable {
    static func == (lhs: DismissableView<Content, T>, rhs: DismissableView<Content, T>) -> Bool {
        true
    }
    
    @State private var isShow = false
    
    let transition: AnyTransition
    let animation: Animation
    let itemToReturn: T

    let completion: OptionalVoid
    
    @ViewBuilder var content: (T) -> Content
    let closeAction: () -> ()
    
    var body: some View {
        ZStack {
            if isShow {
                content(itemToReturn)
                    .transition(transition)
                    .environment(\.easyDismiss, EasyDismiss {
                        isShow = false
                        completion?()
                    })
                    .onDisappear {
                        if !isShow {
                            closeAction()
                        }
                    }
            }
        }
        .animation(animation, value: isShow)
        .onAppear {
            hideKeyboard()
            isShow = true
        }
    }
}

public extension View {
    func easyFullScreenCover<Content>(
        isPresented: Binding<Bool>,
        transition: AnyTransition = .opacity,
        animation: Animation = .default,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View where Content : View {
        self
            .overlayIf(isPresented.wrappedValue) {
                DismissableView(
                    transition: transition,
                    animation: animation,
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
    
    func easyFullScreenCover<Content, T>(
        item: Binding<T?>,
        transition: AnyTransition = .opacity,
        animation: Animation = .default,
        @ViewBuilder content: @escaping (T) -> Content
    ) -> some View where Content : View {
        self
            .overlayIf(item.wrappedValue) { unwrapped in
                DismissableView(
                    transition: transition,
                    animation: animation,
                    itemToReturn: unwrapped,
                    completion: nil,
                    content: content,
                    closeAction: {
                        item.wrappedValue = nil
                    })
            }
    }
    
    @ViewBuilder
    func easyFullScreenCover<Content, T>(
        stack: Binding<[CoordinatedItem<T>?]>,
        @ViewBuilder content: @escaping (T) -> Content
    ) -> some View where Content: View {
        self
            .overlay (
                ZStack { // Need to transition work correct
                    ForEach(stack.wrappedValue.indices, id: \.self) { index in
                        if let unwrappedItem = stack[index].wrappedValue {
                            DismissableView(
                                transition: unwrappedItem.transition,
                                animation: unwrappedItem.animation,
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

fileprivate struct EasyFullScreenCoverModifier<EasyContent: View, Coordinator: Coordinated>: ViewModifier {
    @Environment(\.easyNamespace) private var easyNamespace
    @ObservedObject var coordinator: Coordinator
    @ViewBuilder let easyContent: (Coordinator.FullState) -> EasyContent
    
    func body(content: Content) -> some View {
        content
            .overlay (
                ZStack { // Need to transition work correct
                    ForEach(coordinator.navigationStack.indices, id: \.self) { index in
                        if let unwrappedItem = coordinator.navigationStack[index] {
                            DismissableView(
                                transition: unwrappedItem.transition,
                                animation: unwrappedItem.animation,
                                itemToReturn: unwrappedItem.state,
                                completion: unwrappedItem.completion,
                                content: easyContent,
                                closeAction: {
                                    coordinator.navigationStack[index] = nil
                                }
                            )
                            .equatable()
                            .environment(\.easyNamespace, .init(prefix: unwrappedItem.id,
                                                                parentPrefix: unwrappedItem.parentId,
                                                                namespace: easyNamespace.namespace))
                        }
                    }
                }
            )
            .environment(\.easyNamespace, .init(prefix: coordinator.viewIdIfStackIsEmpty, parentPrefix: UUID().uuidString, namespace: easyNamespace.namespace))
    }
}

public extension View {
    @ViewBuilder
    func easyFullScreenCover<EasyContent: View, Coordinator: Coordinated>(
        coordinator: Coordinator,
        @ViewBuilder content: @escaping (Coordinator.FullState) -> EasyContent
    ) -> some View {
        modifier(EasyFullScreenCoverModifier(coordinator: coordinator, easyContent: content))
    }
}
