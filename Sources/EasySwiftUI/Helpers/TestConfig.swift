//
//  TestConfig.swift
//  
//
//  Created by Yevhenii Korsun on 26.09.2023.
//

#if !os(macOS)

import Foundation

// MARK: - How to use

//extension TestCase {
//    static let isSubscribed = TestCase(value: nil)
//    static let isFirstRun = TestCase(value: nil)
//}


public struct TestCase: Hashable {
    let id = UUID()
    let value: Bool?
}

public extension Bool {
    func forTestUse(_ config: TestCase) -> Bool {
        testValue(config, defaultValue: self)
    }
}

public func testValue(_ config: TestCase) -> Bool? {
    if Build.isDebug {
        return config.value
    } else {
        return nil
    }
}

public func testValue(_ config: TestCase, defaultValue: Bool = false) -> Bool {
    if Build.isDebug {
        if let value = config.value {
            return value
        } else {
            return defaultValue
        }
    } else {
        return defaultValue
    }
}

#endif
