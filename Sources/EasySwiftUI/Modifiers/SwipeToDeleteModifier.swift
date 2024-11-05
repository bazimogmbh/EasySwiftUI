//
//  SwipeToDeleteModifier.swift
//  EasySwiftUI
//
//  Created by Yevhenii Korsun on 26.09.2023.
//

#if !os(macOS) && !os(tvOS)

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
                .apply {
                    if #available(iOS 18, *) {
                        $0
                            .simultaneousGesture(swipe, including: .gesture)
                    } else {
                        $0
                            .highPriorityGesture(swipe)
                    }
                }
                .animation(.easeOut, value: offset)
        }
        .onChange(of: isPresented) { _ in
            if isPresented {
                setIsOpen(to: true)
            }
        }
    }
    
    private var swipe: some Gesture {
        DragGesture(minimumDistance: 15)
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
