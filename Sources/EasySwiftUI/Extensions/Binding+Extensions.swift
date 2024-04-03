//
//  File.swift
//  
//
//  Created by Yevhenii Korsun on 29.01.2024.
//

import SwiftUI

public extension Binding where Value: Hashable {
    @MainActor
    func map(_ completion: @escaping (Value) -> Value) -> Self {
        let newValue = completion(wrappedValue)
        
        if wrappedValue != newValue {
            Task {
                wrappedValue = completion(wrappedValue)
            }
        }
        
        return self
    }
}
