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
    var groupId: String?
    
    var transition: AnyTransition? = .opacity
    var animation: Animation = .linear
    
    var completion: OptionalVoid = nil
}

public protocol NavigationalItem: Identifiable {
    var defaultTransition: AnyTransition? { get }
    var defaultAnimation: Animation { get }
    var groupId: String? { get }
}

public extension NavigationalItem {
    var defaultAnimation: Animation {
        .linear
    }
    
    var id: String {
        let mirror = Mirror(reflecting: self)
        return mirror.children.first?.label ?? String(describing: self)
    }
}

@MainActor
public protocol Coordinated: ObservableObject {
    associatedtype FullState: NavigationalItem
    
    
    var viewIdIfStackIsEmpty: String { get }
    var navigationStack: [CoordinatedItem<FullState>?] { get set }
    
    func showFull(_ state: FullState, completion: OptionalVoid)
    func showFull(_ state: FullState, transition: AnyTransition?, animation: Animation?, timeout: TimeInterval, completion: OptionalVoid)
    func closeTopScreen()
    
    func closeAll(by id: FullState.ID)
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
        transition: AnyTransition?,
        animation: Animation? = nil,
        timeout: TimeInterval = 0,
        completion: OptionalVoid = nil
    ) {
        if let date = navigationStack.last??.date, Date().timeIntervalSince(date) < timeout {
            return
        }
        
        print("!@Coordinator last.state.id \(self.navigationStack.last??.state.id)")
        print("!@Coordinator state.id \(state.id)")
        print("!@Coordinator isEqual screen \(self.navigationStack.last??.state.id == state.id)")
        if let last = self.navigationStack.last,
           last?.state.id == state.id {
            return
        }
        
        if self.navigationStack.compactMap({ $0 }).isEmpty {
            self.navigationStack = []
        }
        
        self.navigationStack = self.navigationStack.map { element in
            if let groupId = element?.groupId, groupId == state.groupId  {
               return nil
            }
            
            return element
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
            groupId: state.groupId,
            transition: transition,
            animation: animation ?? state.defaultAnimation,
            completion: completion
        )
        
        self.navigationStack.append(item)
    }
    
    func closeTopScreen() {
        if let lastIndex = self.navigationStack.lastIndex(where: { $0 != nil }) {
            self.navigationStack[lastIndex] = nil
        }
    }
    
    func closeAll(by id: FullState.ID) {
        self.navigationStack = self.navigationStack.filter({ $0?.state.id != id })
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
    
    @State private var isFirstRun = true
    @State private var isShow = false
    
    var asController: Bool = false
    let transition: AnyTransition?
    let animation: Animation
    let itemToReturn: T

    let completion: OptionalVoid
    
    @ViewBuilder var content: (T) -> Content
    let closeAction: () -> ()
    
    var body: some View {
        if asController {
            Color.clear
                .onAppear {
                    if isFirstRun {
                        hideKeyboard()
                        isShow = true
                        isFirstRun = false
                    }
                }
                .fullScreenCover(isPresented: $isShow, content: {
                    content(itemToReturn)
                        .environment(\.easyDismiss, EasyDismiss {
                            isShow = false
                            completion?()
                        })
                        .onDisappear {
                            if !isShow {
                                closeAction()
                            }
                        }
                })
        } else {
            if let transition {
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
            } else {
                content(itemToReturn)
                    .environment(\.easyDismiss, EasyDismiss {
                        completion?()
                        closeAction()
                    })
                    .onAppear {
                        hideKeyboard()
                    }
            }
        }
    }
}

public extension View {
    func easyFullScreenCover<Content>(
        isPresented: Binding<Bool>,
        transition: AnyTransition? = .opacity,
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
        transition: AnyTransition? = .opacity,
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
    
//    @ViewBuilder
//    func easyFullScreenCover<Content, T>(
//        stack: Binding<[CoordinatedItem<T>?]>,
//        @ViewBuilder content: @escaping (T) -> Content
//    ) -> some View where Content: View {
//        self
//            .overlay (
//                ZStack { // Need to transition work correct
//                    ForEach(stack.wrappedValue.indices, id: \.self) { index in
//                        if let unwrappedItem = stack[index].wrappedValue {
//                            DismissableView(
//                                transition: unwrappedItem.transition,
//                                animation: unwrappedItem.animation,
//                                itemToReturn: unwrappedItem.state,
//                                completion: unwrappedItem.completion,
//                                content: content,
//                                closeAction: {
//                                    stack[safe: index]?.wrappedValue = nil
//                                })
//                        }
//                    }
//                }
//            )
//    }
}

fileprivate func hideKeyboard() {
#if !os(macOS) && !os(tvOS)
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
    @Namespace private var namespace
    @ObservedObject var coordinator: Coordinator
    var asController = false
    @ViewBuilder let easyContent: (Coordinator.FullState) -> EasyContent
    
    func body(content: Content) -> some View {
        content
            .overlay (
                ZStack { // Need to transition work correct
                    ForEach(coordinator.navigationStack.indices, id: \.self) { index in
                        if let unwrappedItem = coordinator.navigationStack[index] {
                            let startIndex = coordinator.navigationStack.startIndex
                            let zIndex = Double(coordinator.navigationStack.distance(from: startIndex, to: index))
                            
                            DismissableView(
                                asController: asController,
                                transition: unwrappedItem.transition,
                                animation: unwrappedItem.animation,
                                itemToReturn: unwrappedItem.state,
                                completion: unwrappedItem.completion,
                                content: easyContent,
                                closeAction: {
                                    coordinator.navigationStack[index] = nil
                                    
                                    if coordinator.navigationStack.endIndex - 1 == index {
                                        coordinator.navigationStack.removeLast()
                                    }
                                }
                            )
                            .equatable()
                            .zIndex(zIndex)
                            .environment(\.easyNamespace, .init(prefix: unwrappedItem.id,
                                                                parentPrefix: unwrappedItem.parentId,
                                                                topScreenPrefix: topScreenPrefix(of: coordinator),
                                                                namespace: namespace))
                        }
                    }
                }
            )
            .environment(\.easyNamespace, .init(
                prefix: coordinator.viewIdIfStackIsEmpty,
                parentPrefix: UUID().uuidString,
                topScreenPrefix: topScreenPrefix(of: coordinator),
                namespace: namespace
            )
            )
    }
    
    private func topScreenPrefix(of coordinator: Coordinator) -> String {
        if coordinator.navigationStack.compactMap({$0}).isEmpty {
            return coordinator.viewIdIfStackIsEmpty
        } else if let index = coordinator.navigationStack.lastIndex(where: { $0 != nil }) {
            return String(index)
        } else {
            return UUID().uuidString
        }
    }
}

public extension View {
    @ViewBuilder
    func easyFullScreenCover<EasyContent: View, Coordinator: Coordinated>(
        coordinator: Coordinator,
        asController: Bool = false,
        @ViewBuilder content: @escaping (Coordinator.FullState) -> EasyContent
    ) -> some View {
        modifier(EasyFullScreenCoverModifier(coordinator: coordinator, asController: asController, easyContent: content))
    }
}
