//
//  File.swift
//  
//
//  Created by Jenya Korsun on 17.05.2024.
//

import Foundation

public protocol AnalyticsParameterable { }

public protocol AnalyticCaseable {
    var name: String { get }
    var parameters: [String: Any] { get }
}

public extension AnalyticCaseable {
    var name: String {
        let mirror = Mirror(reflecting: self)
        let label = mirror.children.first?.label ?? String(describing: self)
        return convertCamelCaseToSnakeCase(label)
    }
    
    var parameters: [String: Any] {
        var dictionary = [String: Any]()
        let mirror = Mirror(reflecting: self)
        
        mirror.children.forEach { child in
            let valueMirror = Mirror(reflecting: child.value)
            
            valueMirror.children.forEach { valueChild in
                if let customReflectable = valueChild.value as? AnalyticsParameterable {
                    let customMirror = Mirror(reflecting: customReflectable)
                    customMirror.children.forEach { customChild in
                        saveToDictionary(customChild)
                    }
                } else {
                    saveToDictionary(valueChild)
                }
            }
        }
        
        return dictionary
        
        func saveToDictionary(_ child: Mirror.Child) {
            guard let label = child.label else { return }
            
            if let bool = child.value as? Bool {
                dictionary[convertCamelCaseToSnakeCase(label)] = bool.description
            } else {
                dictionary[convertCamelCaseToSnakeCase(label)] = child.value
            }
        }
    }
    
    private func convertCamelCaseToSnakeCase(_ input: String) -> String {
        let regex = try? NSRegularExpression(pattern: "([a-z])([A-Z])", options: [])
        let range = NSRange(location: 0, length: input.utf16.count)
        return regex?.stringByReplacingMatches(in: input, options: [], range: range, withTemplate: "$1_$2").lowercased() ?? input
    }
}
