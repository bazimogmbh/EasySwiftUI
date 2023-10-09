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
    @State private var tabBarHeight: CGFloat = EasySwiftUI.tabBarHeight
    
    @Binding var selected: TabBarItem
    @ViewBuilder var content: (TabBarItem) -> Content
    @ViewBuilder var barContent: ([TabBarItem]) -> BarContent
    
    public init(
        tabBarHeight: CGFloat =  EasySwiftUI.tabBarHeight,
        selected: Binding<TabBarItem>,
        content: @escaping (TabBarItem) -> Content,
        barContent: @escaping ([TabBarItem]) -> BarContent
    ) {
        self._selected = selected
        self.content = content
        self.barContent = barContent
        self.tabBarHeight = tabBarHeight
    }
    
    private var allTabs: [TabBarItem] {
        TabBarItem.allCases as! [TabBarItem]
    }

    public var body: some View {
        TabView(selection: $selected) {
            ForEach(allTabs, id:\.self) { tabItem in
                ZStackWithBackground(alignment: .bottom) {
                    ZStackWithBackground(.color(.clear)) {
                        content(tabItem)
                    }
                    .tag(tabItem)
                    .padding(.bottom, tabBarHeight)

                    barContent(allTabs)
                        .frame(height: tabBarHeight)
                        .alignment(.bottom)
                        .ignoresSafeArea(.keyboard)
                }
            }
        }
        .onReceive(isShowKeyboardPublisher) { isShow in
            tabBarHeight = isShow ? 0 : EasySwiftUI.tabBarHeight
        }
        .onAppear {
            UITabBar.appearance().isHidden = true
        }
    }
}

#endif
