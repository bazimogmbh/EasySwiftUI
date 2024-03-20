//
//  EquatableView.swift
//
//
//  Created by Jenya Korsun on 20.03.2024.
//

import SwiftUI

public struct EquatableView<Content: View>: View, Equatable {
    public static func == (lhs: EquatableView<Content>, rhs: EquatableView<Content>) -> Bool {
        true
    }
    
    @ViewBuilder var content: () -> Content
    
    public init(content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        content()
    }
}

#Preview {
    EquatableView {
        Color.red
    }
}
