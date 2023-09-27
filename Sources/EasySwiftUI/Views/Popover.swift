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
    @State private var offset: CGFloat = 0.0
    
    var dragHeight: CGFloat
    var background: Color
    var closeAction: () -> ()
    @ViewBuilder let content: () -> Content
    
    public init(
        dragHeight: CGFloat = 30,
        background: Color = Color.black.opacity(0.4),
        closeAction: @escaping () -> Void = {},
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.dragHeight = dragHeight
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
                    .offset(y: offset)
                    .overlay(alignment: .top, content: dragArea)
            }
        }
        .onAppear {
            withAnimation {
                showBackground = true
                showContent = true
            }
        }
    }
    
    private func dragArea() -> some View {
        Color.transparent
            .frame(height: dragHeight)
            .gesture(DragGesture()
                .onChanged { value in
                    if value.translation.height > 0 {
                        self.offset = value.translation.height
                    }
                }
                .onEnded { value in
                    if value.translation.height > 100 {
                        close()
                    } else {
                        self.offset = 0
                    }
                }
            )
    }

    private func close() {
        withAnimation {
            showContent = false
            closeAction()
        }
    }
}


#endif
