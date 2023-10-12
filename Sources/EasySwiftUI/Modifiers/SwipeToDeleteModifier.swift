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
    @Binding var isPresented: Bool
    @ViewBuilder var underContent: () -> UnderContent
    
    func body(content: Content) -> some View {
        ZStack {
            underContent()
                .opacity(isOpen ? 1 : 0)
            
            content
                .overlayIf(isOpen) {
                    Color.transparent
                        .onTapGesture {
                            setIsOpen(to: false)
                            isPresented = false
                        }
                }
                .offset(x: offset)
                .highPriorityGesture(swipe)
                .animation(.easeOut, value: offset)
        }
        .onChange(of: isPresented) { _ in
            if isPresented {
                setIsOpen(to: true)
            }
        }
    }
    
    private var swipe: some Gesture {
        DragGesture()
            .onEnded({ (value) in
                setIsOpen(to: -value.translation.width >= 60)
            })
    }
    
    private func setIsOpen(to value: Bool) {
        isOpen = value
        offset = value ? -underContentWidth : 0
    }
}

public extension View {
    func onSwipe<Content: View>(
        width: CGFloat = 130,
        isPresented: Binding<Bool> = .constant(false),
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        modifier(SwipeToDeleteModifier(underContentWidth: width, isPresented: isPresented, underContent: content))
    }
}

#endif
