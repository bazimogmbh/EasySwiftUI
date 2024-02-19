//
//  Globals.swift
//  
//
//  Created by Yevhenii Korsun on 27.09.2023.
//


@_exported import SwiftUI

public typealias OptionalVoid = (() -> ())?
public typealias OptionalVoidWithError = ((Error) -> ())?

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
