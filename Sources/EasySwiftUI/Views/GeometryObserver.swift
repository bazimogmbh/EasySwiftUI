//
//  GeometryObserver.swift
//  EasySwiftUI
//
//  Created by Yevhenii Korsun on 25.09.2023.
//

import SwiftUI

@available(macOS 12, *)
public struct GeometryObserver<Content: View>: View {
    @State private var contentProxy: GeometryProxy? = nil
    
    @ViewBuilder let content: (GeometryProxy?) -> Content
    
    public init(@ViewBuilder content: @escaping (GeometryProxy?) -> Content) {
        self.content = content
    }
    
    public var body: some View {
        content(contentProxy)
            .background {
                GeometryReader { proxy in
                    Color.clear
                        .onAppear {
                            contentProxy = proxy
                        }
                }
            }
    }
}
