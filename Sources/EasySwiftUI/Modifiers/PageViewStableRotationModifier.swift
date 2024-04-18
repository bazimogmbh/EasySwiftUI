//
//  PageViewStableRotationModifier.swift
//  EasySwiftUI
//
//  Created by Yevhenii Korsun on 25.09.2023.
//

#if !os(macOS) && !os(tvOS)

import SwiftUI

fileprivate struct PageViewStableRotationModifier<Selection: Hashable>: ViewModifier {
    @State private var id = UUID()
    @Binding var selection: Selection
    
    func body(content: Content) -> some View {
        content
            .id(id)
            .onRotate { _ in
                let current = selection
                
                DispatchQueue.main.async {
                    id = UUID()
                    selection = current
                }
            }
    }
}

public extension View {
    func pageViewStableRotation<Selection: Hashable>(selection: Binding<Selection>) -> some View {
        modifier(PageViewStableRotationModifier(selection: selection))
    }
}

fileprivate struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void
    
    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

public extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        modifier(DeviceRotationViewModifier(action: action))
    }
}

#endif
