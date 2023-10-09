//
//  Image+Extensions.swift
//  EasySwiftUI
//
//  Created by Yevhenii Korsun on 25.09.2023.
//

import SwiftUI

#if os(macOS)
import Cocoa

typealias UIImage = NSImage

@available(macOS 12, *)
extension NSImage {
    var cgImage: CGImage? {
        var proposedRect = CGRect(origin: .zero, size: size)

        return cgImage(forProposedRect: &proposedRect,
                       context: nil,
                       hints: nil)
    }

    convenience init?(systemName name: String) {
        self.init(systemSymbolName: name, accessibilityDescription: nil)
    }
}

#endif

@available(macOS 12, *)
public extension Image {
    init(universal name: String) {
        if let _ = UIImage(systemName: name) {
            self = Image(systemName: name)
        } else {
            self = Image(name)
        }
    }
}
