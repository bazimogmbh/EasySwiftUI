//
//  EasySheetContainer.swift
//
//
//  Created by Yevhenii Korsun on 29.01.2024.
//

import SwiftUI

public struct EasySheetContainer<Content: View>: View {
    let content: () -> Content
    
    init(content: @escaping () -> Content) {
        self.content = content
    }
    
    public var body: some View {
        EasyDismissContainer {
            Color.clear
                .sheet(isPresented: $0) {
                    content()
                        .ignoresSafeArea()
                }
        }
    }
}
