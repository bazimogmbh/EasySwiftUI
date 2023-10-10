//
//  SwipeToDeleteModifier.swift
//  EasySwiftUI
//
//  Created by Yevhenii Korsun on 26.09.2023.
//

#if !os(macOS)

import SwiftUI

fileprivate struct SwipeToDeleteModifier<UnderContent: View>: ViewModifier {
    @GestureState var isDragging = false
    
    @State private var isOpen = false
    @State private var offset: CGFloat = 0

    var underContentWidth: CGFloat = 130
    @ViewBuilder var underContent: () -> UnderContent
    
    func body(content: Content) -> some View {
        ZStack {
            underContent()
                .opacity(isOpen ? 1 : 0)
            
            content
                .overlayIf(isOpen) {
                    Color.transparent
                        .onTapGesture {
                            isOpen = false
                            offset = 0
                        }
                }
                .offset(x: offset)
                .highPriorityGesture(swipe)
                .animation(.easeOut, value: offset)
        }
    }
    
    private var swipe: some Gesture {
        DragGesture()
            .onEnded({ (value) in
                isOpen = -value.translation.width >= 60
                offset = isOpen ? -underContentWidth : 0
            })
    }
}

public extension View {
    func onSwipe<Content: View>(
        width: CGFloat = 130,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(SwipeToDeleteModifier(underContentWidth: width, underContent: content))
    }
}

#endif
