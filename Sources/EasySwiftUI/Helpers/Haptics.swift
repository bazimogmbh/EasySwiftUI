//
//  Haptics.swift
//  
//
//  Created by Yevhenii Korsun on 26.09.2023.
//

#if !os(macOS)

import SwiftUI

// MARK: - Haptic Feedback Vibrations

public final class Haptics {
    public enum HapticType {
        case light
        case medium
        case heavy
        case success
        case error
        case warning
    }
    
    public static func getFeedback(_ type: HapticType) {
        let generator = UINotificationFeedbackGenerator()
        print("#HAPTIC with type:\(type)")
        switch type {
        case .light:
            let impact = UIImpactFeedbackGenerator(style: .light)
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
        }
    }
}

#endif
