//
//  BlurView.swift
//  EasySwiftUI
//
//  Created by Yevhenii Korsun on 25.09.2023.
//

import SwiftUI

#if os(macOS)

struct BlurView: NSViewRepresentable {
    var style: NSVisualEffectView.Material

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = style
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = style
    }
}

#else

public struct BlurView: UIViewRepresentable {
    public var style: UIBlurEffect.Style
    
    public init(style: UIBlurEffect.Style) {
        self.style = style
    }
    
    public func makeUIView(context: Context) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        
        return view
    }
    
    public func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        
    }
}

#endif
