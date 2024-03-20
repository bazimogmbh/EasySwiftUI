//
//  CustomNavigationView.swift
//  EasySwiftUI
//
//  Created by Yevhenii Korsun on 25.09.2023.
//

import SwiftUI

public struct CustomNavigationView<BarContent: View, Content: View>: View {
    @StateObject private var observerContainer = NavBarScrollObserverContainer()
    
    let background: BackgroundState
    let alignment: Alignment
    var barHeight: CGFloat
    @ViewBuilder let barContent: (Bool, CGFloat) -> BarContent
    @ViewBuilder let content: () -> Content
    
    public init(
        background: BackgroundState = .color(EasySwiftUI.appBackground),
        alignment: Alignment = .center,
        barHeight: CGFloat = EasySwiftUI.navigationBarHeight,
        @ViewBuilder barContent: @escaping (Bool, CGFloat) -> BarContent,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.background = background
        self.alignment = alignment
        self.barHeight = barHeight
        self.barContent = barContent
        self.content = content
    }
    
    public var body: some View {
        ZStackWithBackground(background) {
            content()
                .coordinateSpace(name: observerContainer.observer.coordinateSpace)
                .environmentObject(observerContainer)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
                .safeAreaInset(edge: .top) {
                    NavBarContent(observer: observerContainer.observer, barContent: barContent)
                        .frame(height: barHeight)
                        .frame(maxWidth: .infinity)
                }
        }
    }
}

fileprivate struct NavBarContent<Content: View>: View {
    @ObservedObject var observer: NavigationBarScrollObserver
    @ViewBuilder var barContent: (Bool, CGFloat) -> Content
    
    var body: some View {
        barContent(observer.isScrollingTop, observer.minYOffset)
    }
}

public extension CustomNavigationView where BarContent == BackgroundView {
    init(
        _ navBar: BackgroundState = .color(EasySwiftUI.navBarColor),
        background: BackgroundState = .color(EasySwiftUI.appBackground),
        alignment: Alignment = .center,
        barHeight: CGFloat = EasySwiftUI.navigationBarHeight,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(background: background, alignment: alignment, barHeight: barHeight, barContent: { _,_ in BackgroundView(state: navBar) }, content: content)
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


//struct CustomNavigationView<BarContent: View, Content: View>: View {
//    let navBarColor: Color
//    let background: Color
//    let alignment: Alignment
//    var barHeight: CGFloat
//    let barContent: BarContent
//    let content: Content
//    
//    init(
//        _ navBarColor: Color = .appBackground,
//        background: Color = .appBackground,
//        alignment: Alignment = .center,
//        barHeight: CGFloat = Sizes.navigationBarHeight,
//        @ViewBuilder barContent: () -> BarContent,
//        @ViewBuilder content: () -> Content
//    ) {
//        self.navBarColor = navBarColor
//        self.background = background
//        self.alignment = alignment
//        self.barHeight = barHeight
//        self.barContent = barContent()
//        self.content = content()
//    }
//    
//    var body: some View {
//        ZStackWithBackground(background) {
//            content
//                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
//                .safeAreaInset(edge: .top) {
//                    barContent
//                        .frame(height: barHeight)
//                        .frame(maxWidth: .infinity)
//                        .background {
//                            navBarColor
//                                .ignoresSafeArea()
//                        }
//                        .zIndex(2)
//                }
//        }
//    }
//}
//
//extension CustomNavigationView where BarContent == EmptyView {
//    init(
//        _ navBarColor: Color = .appBackground,
//        background: Color = .appBackground,
//        alignment: Alignment = .center,
//        barHeight: CGFloat = Sizes.navigationBarHeight,
//        @ViewBuilder content: () -> Content
//    ) {
//        self.init(navBarColor, background: background, alignment: alignment, barHeight: barHeight, barContent: { EmptyView() }, content: content)
//    }
//}
//
//extension View {
//    @ViewBuilder
//    func addNavItem<Item: View>(
//        if isShowing: Bool = true,
//        alignment: Alignment,
//        width: CGFloat? = nil,
//        offset: CGPoint = CGPoint(x: 0, y: 0),
//        @ViewBuilder item: @escaping () -> Item
//    ) -> some View {
//        self
//            .overlay(alignment: .top) {
//                GeometryReader { proxy in
//                    ZStack(alignment: alignment) {
//                        Color.clear
//                        
//                        item()
//                            .offset(x: offset.x, y: offset.y)
//                            .padding(Sizes.navigationBarEdges)
//                            .if(width) { width, view in
//                                view
//                                    .frame(maxWidth: width * proxy.size.width, alignment: Alignment(horizontal: alignment.horizontal, vertical: .center))
//                            }
//                    }
//                }
//                .frame(height: Sizes.navigationBarHeight)
//                .opacity(isShowing ? 1 : 0)
//            }
//    }
//}
//
//enum NavTitleAppearence {
//    case large, small
//    
//    var alignment: Alignment {
//        switch self {
//        case .large: .leading
//        case .small: .center
//        }
//    }
//    
//    var textSize: CGFloat {
//        switch self {
//        case .large: 34
//        case .small: 26
//        }
//    }
//}
//
//extension View {
//    func addNavTitle(_ title: String,
//                     appearence: NavTitleAppearence = .large,
//                     width: CGFloat? = 0.44
//    ) -> some View {
//        self
//            .addNavItem(alignment: appearence.alignment, width: width) {
//                Text(title)
//                    .customFont(.Gilroy500, size: appearence.textSize)
//                    .lineLimit(1)
//            }
//    }
//}
