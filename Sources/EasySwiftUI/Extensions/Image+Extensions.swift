//
//  Image+Extensions.swift
//  EasySwiftUI
//
//  Created by Yevhenii Korsun on 25.09.2023.
//

#if !os(macOS)

import SwiftUI

public extension Image {
    init(universal name: String) {
        if let _ = UIImage(systemName: name) {
            self = Image(systemName: name)
        } else {
            self = Image(name)
        }
    }
}

#endif
