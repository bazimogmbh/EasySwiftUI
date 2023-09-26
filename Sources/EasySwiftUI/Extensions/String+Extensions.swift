//
//  String+Extensions.swift
//  EasySwiftUI
//
//  Created by Yevhenii Korsun on 25.09.2023.
//

#if !os(macOS)

import SwiftUI

postfix operator ~
public postfix func ~(string: String) -> String {
    return NSLocalizedString(string, comment: "")
}

public extension String {
    func localize(with arguments: [CVarArg]) -> String {
        return String(format: self~, locale: nil, arguments: arguments)
    }
}

#endif
