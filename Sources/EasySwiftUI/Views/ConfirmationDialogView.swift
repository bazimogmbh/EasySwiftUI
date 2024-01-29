//
//  ConfirmationDialogView.swift
//
//
//  Created by Yevhenii Korsun on 29.01.2024.
//

import SwiftUI

public protocol ConfirmationPickable: CaseIterable, Identifiable {
    var id: String { get }
    var title: String { get }
    
    static var header: String { get }
}

public extension ConfirmationPickable {
    var id: String {
         title
    }
}

public struct ConfirmationDialogView: View {
    public struct DialogButton: Identifiable {
        let title: String
        let action: (GeometryProxy) -> ()
        
        public init(title: String, action: @escaping (GeometryProxy) -> Void) {
            self.title = title
            self.action = action
        }
        
        public var id: String {
            title
        }
    }
    
    public var proxy: GeometryProxy
    public let header: String
    public let titleVisibility: Visibility
    public var buttons: [DialogButton]
    
    public init(
        proxy: GeometryProxy,
        header: String,
        titleVisibility: Visibility = .automatic,
        buttons: [DialogButton]
    ) {
        self.proxy = proxy
        self.header = header
        self.titleVisibility = titleVisibility
        self.buttons = buttons
    }
    
    public init<P: ConfirmationPickable>(
        proxy: GeometryProxy,
        pickable: P,
        titleVisibility: Visibility = .automatic,
        action: @escaping (P, GeometryProxy) -> Void
    ) {
        self.proxy = proxy
        self.header = pickable.title
        self.titleVisibility = titleVisibility
        self.buttons = type(of: pickable).allCases.map { button in
            DialogButton(title: button.title, action: { action(button, $0) })
        }
    }
    
    public var body: some View {
        EasyDismissContainer { isPresented in
            Color.clear
                .position(x: proxy.frame(in: .global).midX, y: proxy.frame(in: .global).midY)
                .frame(width: proxy.size.width, height: proxy.size.height)
                .confirmationDialog(header, isPresented: isPresented, titleVisibility: titleVisibility) {
                    ForEach(buttons) { button in
                        Button(button.title) {
                            button.action(proxy)
                        }
                    }
                }
        }
    }
}

extension View {
    @MainActor
    func confirmationDialogWithProxy<P: ConfirmationPickable>(
        isPresented: Binding<Bool>,
        action: @MainActor @escaping (GeometryProxy, P) -> ()
    ) -> some View {
        background {
            GeometryReader { proxy in
                Color.transparent
                    .confirmationDialog(P.header, isPresented: isPresented, titleVisibility: .visible) {
                        ForEach(Array(P.allCases)) { option in
                            Button(option.title) {
                                action(proxy, option)
                            }
                        }
                    }
            }
        }
    }
}
