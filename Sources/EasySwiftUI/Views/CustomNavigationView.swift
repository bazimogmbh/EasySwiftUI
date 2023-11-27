//
//  CustomNavigationView.swift
//  EasySwiftUI
//
//  Created by Yevhenii Korsun on 25.09.2023.
//

import SwiftUI

public struct CustomNavigationView<BarContent: View, Content: View>: View {
    let navBar: BackgroundState
    let background: BackgroundState
    let alignment: Alignment
    var barHeight: CGFloat
    let barContent: BarContent
    let content: Content
    
    public init(
        _ navBar: BackgroundState = .color(EasySwiftUI.navBarColor),
        background: BackgroundState = .color(EasySwiftUI.appBackground),
        alignment: Alignment = .center,
        barHeight: CGFloat = EasySwiftUI.navigationBarHeight,
        @ViewBuilder barContent: () -> BarContent,
        @ViewBuilder content: () -> Content
    ) {
        self.navBar = navBar
        self.background = background
        self.alignment = alignment
        self.barHeight = barHeight
        self.barContent = barContent()
        self.content = content()
    }
    
    public var body: some View {
        ZStackWithBackground(background, alignment: .top) {
            ZStack(alignment: .center) {
                Color.clear
                
                content
            }
            .padding(.top, barHeight)
            .overlay(alignment: .top) {
                barContent
                    .frame(height: barHeight)
                    .frame(maxWidth: .infinity)
                    .background {
                        switch navBar {
                        case .material(let material):
                            BlurView(style: material)
                        case .color(let color):
                            color
                        }
                    }
                    .zIndex(2)
            }
        }
    }
}

public extension CustomNavigationView where BarContent == EmptyView {
    init(
        _ navBar: BackgroundState = .color(EasySwiftUI.navBarColor),
        background: BackgroundState = .color(EasySwiftUI.navBarColor),
        alignment: Alignment = .center,
        barHeight: CGFloat = EasySwiftUI.navigationBarHeight,
        @ViewBuilder content: () -> Content
    ) {
        self.init(navBar, background: background, alignment: alignment, barHeight: barHeight, barContent: { EmptyView() }, content: content)
    }
}

public extension View {
    @ViewBuilder
    func addNavItem<Item: View>(
        if isShowing: Bool = true,
        alignment: Alignment,
        width: CGFloat? = nil,
        offset: CGPoint = CGPoint(x: 0, y: 0),
        @ViewBuilder item: @escaping () -> Item
    ) -> some View {
        self
            .overlay(alignment: .top) {
                GeometryReader { proxy in
                    ZStack(alignment: alignment) {
                        Color.clear
                        
                        item()
                            .offset(x: offset.x, y: offset.y)
                            .padding(EasySwiftUI.navigationBarEdges)
                            .if(width) { width, view in
                                view
                                    .frame(maxWidth: width * proxy.size.width, alignment: Alignment(horizontal: alignment.horizontal, vertical: .center))
                            }
                    }
                }
                .frame(height: EasySwiftUI.navigationBarHeight)
                .opacity(isShowing ? 1 : 0)
            }
    }
}
