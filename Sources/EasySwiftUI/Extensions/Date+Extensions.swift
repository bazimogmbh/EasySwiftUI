//
//  Date+Extensions.swift
//  EasySwiftUI
//
//  Created by Yevhenii Korsun on 26.09.2023.
//

#if !os(macOS)

import Foundation

public extension Date {
    func toString(format: String = "yyyy-MM-dd", isLocalized: Bool = false) -> String {
        let formatter = DateFormatter()
        
        if isLocalized {
            formatter.dateStyle = .short
            formatter.setLocalizedDateFormatFromTemplate(format)
            formatter.locale = Locale.current
        } else {
            formatter.dateFormat = format
        }
        
        return formatter.string(from: self)
    }
}

#endif
