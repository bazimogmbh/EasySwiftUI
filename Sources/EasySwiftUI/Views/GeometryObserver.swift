//
//  GeometryObserver.swift
//  EasySwiftUI
//
//  Created by Yevhenii Korsun on 25.09.2023.
//

#if !os(macOS)

import SwiftUI

public struct GeometryObserver<Content: View>: View {
    @ViewBuilder let content: (GeometryProxy?) -> Content
    
    public var body: some View {
        content(nil)
            .opacity(0)
            .overlay {
                GeometryReader { proxy in
                    content(proxy)
                }
            }
    }
}

#endif
