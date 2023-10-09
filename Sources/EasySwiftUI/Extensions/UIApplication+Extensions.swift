//
//  UIApplication+Extensions.swift
//  EasySwiftUI
//
//  Created by Yevhenii Korsun on 25.09.2023.
//

import SwiftUI

#if os(macOS)

typealias UIApplication = NSApplication

public extension UIApplication {
    static var topViewController: NSViewController? {
        return NSApplication.shared.keyWindow?.contentViewController
    }
}

#else

public extension UIApplication {
    static var currentKeyWindow: UIWindow? {
        UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .map { $0 as? UIWindowScene }
            .compactMap { $0 }
            .first?.windows
            .filter { $0.isKeyWindow }
            .first
    }
    
    static var rootViewController: UIViewController? {
        currentKeyWindow?.rootViewController
    }
    
    static var topViewController: UIViewController? {
        currentKeyWindow?.rootViewController?.topMostViewController
    }
}

@available(macOS 12, *)
fileprivate extension UIViewController {
    var topMostViewController: UIViewController {
        if let presented = self.presentedViewController {
            return presented.topMostViewController
        }
        
        if let navigation = self as? UINavigationController {
            return navigation.visibleViewController?.topMostViewController ?? navigation
        }
        
        if let tab = self as? UITabBarController {
            return tab.selectedViewController?.topMostViewController ?? tab
        }
        
        return self
    }
}

#endif
