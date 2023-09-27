//
//  Globals.swift
//  
//
//  Created by Yevhenii Korsun on 27.09.2023.
//


import SwiftUI

#if !os(macOS)

func runOnMainActor(_ body: @MainActor @escaping () -> Void) {
    Task {
        await MainActor.run {
            body()
        }
    }
}

func onMainActorWithAnimation(_ body: @MainActor @escaping () -> Void) {
    Task {
        await MainActor.run {
            withAnimation {
                body()
            }
        }
    }
}

#endif
