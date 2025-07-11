//
//  Haptics.swift
//  
//
//  Created by Yevhenii Korsun on 26.09.2023.
//

#if !os(macOS) && !os(tvOS)

import SwiftUI

// MARK: - Haptic Feedback Vibrations

public final class Haptics {
    public enum HapticType {
        case light
        case soft
        case medium
        case heavy
        case success
        case error
        case warning
        case selectionChanged
    }
    
    private static var isEnable = true
    
    public static func activate(_ isEnable: Bool = true) {
        self.isEnable = isEnable
    }
    
    public static func getFeedback(_ type: HapticType) {
        guard isEnable else { return }
        
        let generator = UINotificationFeedbackGenerator()
        print("#HAPTIC with type:\(type)")
        switch type {
        case .light:
            let impact = UIImpactFeedbackGenerator(style: .light)
            impact.impactOccurred()
        case .soft:
            let impact = UIImpactFeedbackGenerator(style: .soft)
            impact.impactOccurred()
        case .medium:
            let impact = UIImpactFeedbackGenerator(style: .medium)
            impact.impactOccurred()
        case .heavy:
            let impact = UIImpactFeedbackGenerator(style: .heavy)
            impact.impactOccurred()
        case .success:
            generator.notificationOccurred(.success)
        case .error:
            generator.notificationOccurred(.error)
        case .warning:
            generator.notificationOccurred(.warning)
        case .selectionChanged:
            let selection = UISelectionFeedbackGenerator()
            selection.selectionChanged()
        }
    }
}

#endif
