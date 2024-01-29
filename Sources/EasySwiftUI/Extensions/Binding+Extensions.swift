//
//  File.swift
//  
//
//  Created by Yevhenii Korsun on 29.01.2024.
//

import SwiftUI

public extension Binding {
    @MainActor
    func map(_ completion: @escaping (Value) -> Value) -> Self {
        Task {
            wrappedValue = completion(wrappedValue)
        }
        
        return self
    }
}
