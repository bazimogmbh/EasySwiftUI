//
//  ObservableObject.swift
//  EasySwiftUI
//
//  Created by Yevhenii Korsun on 25.09.2023.
//

import SwiftUI

@available(macOS 12, *)
public extension ObservableObject {
    func binding<Value>(for keyPath: ReferenceWritableKeyPath<Self, Value>) -> Binding<Value> {
        Binding(
            get: { self[keyPath: keyPath] },
            set: { self[keyPath: keyPath] = $0 }
        )
    }
}
