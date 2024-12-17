//
//  EasySwiftUI.swift
//  
//
//  Created by Yevhenii Korsun on 26.09.2023.
//

import SwiftUI

public enum EasySwiftUI {
    public static var appBackground: Color = .red
    public static var appForeground: Color = .red
    public static var navBarColor: Color = .red
    
    public static var navigationBarHeight: CGFloat = 50
    public static var navigationBarEdges: SwiftUI.EdgeInsets = .init(top: 0, leading: 20, bottom: 0, trailing: 20)
    public static var tabBarHeight: CGFloat = 76
    public static var textScaleFactor: CGFloat = 0.7
    
    public static var isShowCircleOverZstack: Bool = true
    
    public static func configureDefault(
        appBackground: Color,
        appForeground: Color,
        navBarColor: Color,
        navigationBarHeight: CGFloat,
        navigationBarEdges: SwiftUI.EdgeInsets,
        tabBarHeight: CGFloat,
        isShowCircleOverZstack: Bool = true,
        textScaleFactor: CGFloat = 0.7
    ) {
        self.appBackground = appBackground
        self.appForeground = appForeground
        self.navBarColor = navBarColor
        self.navigationBarHeight = navigationBarHeight
        self.navigationBarEdges = navigationBarEdges
        self.tabBarHeight = tabBarHeight
        self.textScaleFactor = textScaleFactor
        self.isShowCircleOverZstack = isShowCircleOverZstack
    }
}
