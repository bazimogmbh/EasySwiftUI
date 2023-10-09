//
//  Popover.swift
//  
//
//  Created by Yevhenii Korsun on 27.09.2023.
//

import SwiftUI

public struct Popover<Content: View>: View, KeyboardHelper {
    @Environment(\.easyDismiss) private var easyDismiss
    @State private var isPresented: Bool = false
    @State private var offsetY: CGFloat = 0
    
    var dragHeight: CGFloat = 30
    
    var closeAction: () -> Void
    @ViewBuilder let content: () -> Content

    public init(
        dragHeight: CGFloat = 30,
        closeAction: @escaping () -> Void = {},
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.dragHeight = dragHeight
        self.closeAction = closeAction
        self.content = content
    }
    
    public var body: some View {
        GeometryReader { geo in
            Color.black
                .opacity(isPresented ? 0.7 : 0)
                .ignoresSafeArea()
                .animation(.easeInOut, value: isPresented)
                .onTapGesture {
                    isPresented = false
                }
                .overlay(alignment: .bottom) {
                    content()
                        .scaleEffect(scale, anchor: .bottom)
                        .offset(y: max(0, offsetY))
                        .overlay(alignment: .top) {
                            Color.transparent
                                .frame(height: dragHeight)
                                .gesture(drag)
                        }
                        .alignmentGuide(.bottom) {
                            isPresented ? $0[.bottom] : $0[.top] - geo.safeAreaInsets.bottom
                        }
                        .animation(.smooth(duration: 0.35), value: isPresented)
                        .environment(\.easyDismiss, EasyDismiss {_ in
                            isPresented = false
                        })
                }
        }
        .transition(.identity)
        .onChange(of: isPresented) { newValue in
            if !newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    closeAction()
                    easyDismiss()
                }
            }
        }
        .onAppear {
            isPresented = true
        }
    }
    
    var drag: some Gesture {
        DragGesture()
            .onChanged { val in
                let height = val.translation.height < 0 ? val.translation.height * 0.2 : val.translation.height
                offsetY = max(-50, height)
            }
            .onEnded { val in
                if val.translation.height > 100 {
                    offsetY = 0
                    isPresented = false
                } else {
                    withAnimation {
                        offsetY = 0
                    }
                }
            }
    }
    
    var scale: CGSize {
        CGSize(width: 1, height: offsetY < 0 ? 1 + abs(offsetY / 1000) : 1)
    }
}
