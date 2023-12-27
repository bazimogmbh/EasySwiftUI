//
//  File.swift
//  
//
//  Created by Yevhenii Korsun on 27.12.2023.
//

import Foundation

public extension Task where Success == Never, Failure == Never {
    static func sleep(seconds: Double = 1) async throws {
        let duration = UInt64(seconds * 1_000_000_000)
        try await Task.sleep(nanoseconds: duration)
    }
}
