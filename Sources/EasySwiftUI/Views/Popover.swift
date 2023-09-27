//
//  Popover.swift
//  
//
//  Created by Yevhenii Korsun on 27.09.2023.
//

#if !os(macOS)

import SwiftUI

public struct Popover<Content: View>: View, KeyboardHelper {
    @Environment(\.easyDismiss) private var easyDismiss
    
    @State private var showContent = false
    @State private var showBackground = false
    
    var background: Color = Color.black.opacity(0.4)
    var closeAction: () -> ()
    @ViewBuilder let content: () -> Content
    
    public init(
        background: Color = Color.black.opacity(0.4),
        closeAction: @escaping () -> Void = {},
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.background = background
        self.closeAction = closeAction
        self.content = content
    }
    
    public var body: some View {
        ZStackWithBackground(color: .clear, alignment: .bottom) {
            if showBackground {
                background
                    .ignoresSafeArea()
                    .transition(.opacity)
                    .onTapGesture(perform: close)
            }
            
            if showContent {
                content()
                    .transition(.move(edge: .bottom))
                    .zIndex(2)
                    .environment(\.easyDismiss, EasyDismiss { _ in
                        close()
                    })
                    .onDisappear {
                        if !showContent {
                            withAnimation { showBackground = false }
                            easyDismiss()
                        }
                    }
            }
        }
        .onAppear {
            withAnimation {
                showBackground = true
                showContent = true
            }
        }
    }

    private func close() {
        withAnimation {
            showContent = false
            closeAction()
        }
    }
}

#endif
