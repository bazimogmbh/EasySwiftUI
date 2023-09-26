//
//  Globals.swift
//  
//
//  Created by Yevhenii Korsun on 26.09.2023.
//

import SwiftUI

#if !os(macOS)

public typealias OptionalVoid = (() -> ())?
public typealias OptionalVoidWithError = ((Error) -> ())?

public func print(_ object: Any) {
    if Build.isDebug {
        let output = "\(EasySwiftUI.printPrefix)\(object)"
        Swift.print(output)
    }
}

public func runOnMainActor(_ body: @MainActor @escaping () -> Void) {
    Task {
        await MainActor.run {
            body()
        }
    }
}

public func onMainActorWithAnimation(_ body: @MainActor @escaping () -> Void) {
    Task {
        await MainActor.run {
            withAnimation {
                body()
            }
        }
    }
}

public struct Build {
    public static var isDebug: Bool {
        #if DEBUG
            return true
        #else
            return false
        #endif
    }
    
    public static var isProduction: Bool {
        !isDebug
    }
    
    public static func runIn(debug: () -> Void, production: () -> Void) {
        if isDebug {
            debug()
        } else {
            production()
        }
    }
}

#endif
