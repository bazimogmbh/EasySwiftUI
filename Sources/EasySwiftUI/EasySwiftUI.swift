//
//  EasySwiftUI.swift
//  
//
//  Created by Yevhenii Korsun on 26.09.2023.
//

import SwiftUI

#if !os(macOS)

public enum EasySwiftUI {
    public static var appBackground: Color = .red
    public static var appForeground: Color = .red
    static var navBarColor: Color = .red
    
    static var navigationBarHeight: CGFloat = 50
    static var navigationBarEdges: SwiftUI.EdgeInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
    static var tabBarHeight: CGFloat = 76
    
    public static func configureDefault(
        appBackground: Color,
        appForeground: Color,
        navBarColor: Color,
        navigationBarHeight: CGFloat,
        navigationBarEdges: SwiftUI.EdgeInsets,
        tabBarHeight: CGFloat
    ) {
        self.appBackground = appBackground
        self.appForeground = appForeground
        self.navBarColor = navBarColor
        self.navigationBarHeight = navigationBarHeight
        self.navigationBarEdges = navigationBarEdges
        self.tabBarHeight = tabBarHeight
    }
}

#endif
