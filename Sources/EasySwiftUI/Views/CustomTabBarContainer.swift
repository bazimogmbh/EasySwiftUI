//
//  CustomTabBar.swift
//  EasySwiftUI
//
//  Created by Yevhenii Korsun on 26.09.2023.
//

#if !os(macOS)

import SwiftUI

public protocol TabItemProtocol: Hashable, CaseIterable { }

public struct CustomTabBarContainer<Content: View, BarContent: View, TabBarItem: TabItemProtocol>: View, KeyboardHelper {
    @StateObject private var observerContainer = TabBarScrollObserverContainer()
    
    @Binding var selected: TabBarItem
    @ViewBuilder var content: (TabBarItem) -> Content
    @ViewBuilder var barContent: ([TabBarItem], Bool) -> BarContent
    
    private let tabBarHeight: CGFloat
    private let bottomPadding: CGFloat
    
    public init(
        tabBarHeight: CGFloat = EasySwiftUI.tabBarHeight,
        bottomPadding: CGFloat = EasySwiftUI.tabBarHeight,
        selected: Binding<TabBarItem>,
        content: @escaping (TabBarItem) -> Content,
        barContent: @escaping ([TabBarItem], Bool) -> BarContent
    ) {
        self._selected = selected
        self.content = content
        self.barContent = barContent
        self.tabBarHeight = tabBarHeight
        self.bottomPadding = bottomPadding
    }
    
    private var allTabs: [TabBarItem] {
        TabBarItem.allCases as! [TabBarItem]
    }

    public var body: some View {
        TabView(selection: $selected) {
            ForEach(allTabs, id:\.self) { tabItem in
                ZStackWithBackground {
                    content(tabItem)
                        .tag(tabItem)
                        .environmentObject(observerContainer)
                        .environment(\.tabBarHasObserver, true)
                        .safeAreaInset(edge: .bottom, spacing: .zero) {
                            Color.clear
                                .frame(height: bottomPadding)
                        }
                }
            }
        }
        .overlay {
            ZStack(alignment: .bottom) {
                Color.clear
                
                GeometryReader { proxy in
                    TabBarContent(
                        observer: observerContainer.observer,
                        allTabs: allTabs,
                        proxy: proxy,
                        barContent: barContent
                    )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(height: tabBarHeight)
            }
            .ignoresSafeArea(.keyboard)
        }
        .onAppear {
            UITabBar.appearance().isHidden = true
        }
    }
}

fileprivate struct TabBarContent<BarContent: View, TabBarItem: TabItemProtocol>: View {
    @ObservedObject var observer: TabBarScrollObserver
    let allTabs: [TabBarItem]
    let proxy: GeometryProxy
    @ViewBuilder var barContent: ([TabBarItem], Bool) -> BarContent
    
    var body: some View {
        barContent(allTabs, observer.isScrollingBottom(in: proxy))
    }
}

#endif
