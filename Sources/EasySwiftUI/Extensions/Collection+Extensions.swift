//
//  File.swift
//  
//
//  Created by Yevhenii Korsun on 26.09.2023.
//

import Foundation

public extension Collection {
    /// Returns the element at the specified index if it is within bounds, otherwise nil.
    subscript (safe index: Int) -> Element? {
        guard (self.count) > index, index >= 0 else { return nil }
        let answerIndex = self.index(self.startIndex, offsetBy: index)
        return self[answerIndex]
    }
}
