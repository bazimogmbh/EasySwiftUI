//
//  OverflowViewModifier.swift
//  EasySwiftUI
//
//  Created by Yevhenii Korsun on 26.09.2023.
//

import SwiftUI

fileprivate struct OverflowViewModifier: ViewModifier {
    @State private var contentOverflow: Bool = false
    var showIndicator: Bool
    
    func body(content: Content) -> some View {
#if os(macOS)
        content
#else
        GeometryReader { geometry in
            content
                .background(
                    GeometryReader { contentGeometry in
                        Color.clear
                            .onAppear {
                                contentOverflow = contentGeometry.size.height > geometry.size.height
                            }
                            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                                DispatchQueue.main.async {
                                    contentOverflow = contentGeometry.size.height > geometry.size.height
                                }
                            }
                    }
                )
                .wrappedInScrollView(when: contentOverflow, showIndicator: showIndicator)
        }
#endif
    }
}

fileprivate extension View {
    @ViewBuilder
    func wrappedInScrollView(when condition: Bool, showIndicator: Bool) -> some View {
        if condition {
            ScrollView(.vertical, showsIndicators: showIndicator) {
                self
            }
        } else {
            self
        }
    }
}

public extension View {
    func scrollViewIfOverflow(showIndicator: Bool = true) -> some View {
        modifier(OverflowViewModifier(showIndicator: showIndicator))
    }
}
