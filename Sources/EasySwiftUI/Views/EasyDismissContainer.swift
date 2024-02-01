//
//  EasyDismissContainer.swift
//
//
//  Created by Yevhenii Korsun on 29.01.2024.
//

import SwiftUI

public struct EasyDismissContainer<Content: View>: View {
    @Environment(\.easyDismiss) var easyDismiss
    @State private var isShow: Bool = false
    private let content: (Binding<Bool>) -> Content
    
    public init(content: @escaping (Binding<Bool>) -> Content) {
        self.content = content
    }
    
    public var body: some View {
        content($isShow)
            .onAppear {
                isShow = true
            }
            .onChange(of: isShow) {
                if !$0 {
                    easyDismiss()
                }
            }
    }
}
