//
//  ClearList.swift
//  EasySwiftUI
//
//  Created by Jenya Korsun on 12.12.2025.
//

import SwiftUI

#if !os(tvOS)
public struct ClearList<Content: View, S: ListStyle>: View {
    public var style: S
    public var insets: EdgeInsets = .init()
    
    @ViewBuilder public var content: () -> Content
    
    public var body: some View {
        List {
            content()
                .listRowSeparator(.hidden)
                .listRowBackground(Color.clear)
                .listRowInsets(insets)
        }
        .listStyle(style)
        .apply {
            if #available(iOS 16.0, *) {
                $0.scrollContentBackground(.hidden)
            } else {
                $0
            }
        }
    }
}

public extension ClearList where S == InsetListStyle {
    init(
        insets: EdgeInsets = .init(top: 0, leading: 0, bottom: 0, trailing: 0),
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(style: .inset, insets: insets, content: content)
    }
}

#endif
