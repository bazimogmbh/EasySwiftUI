//
//  UIDevice.swift
//  EasySwiftUI
//
//  Created by Yevhenii Korsun on 25.09.2023.
//

#if !os(macOS) && !os(tvOS)

import SwiftUI

public extension UIDevice {
    static let isIpad = UIDevice.current.userInterfaceIdiom == .pad
    
    static var isSmallDevice: Bool {
        UIDevice().userInterfaceIdiom == .phone &&  UIScreen.main.nativeBounds.height <= 1334
    }
}

public func ifIpad<T>(_ ipadSize: T, else size: T) -> T {
    return UIDevice.isIpad ? ipadSize : size
}

public func ifSmallDevice<T>(_ smallSize: T, else size: T) -> T {
    return UIDevice.isSmallDevice ? smallSize : size
}

#endif
