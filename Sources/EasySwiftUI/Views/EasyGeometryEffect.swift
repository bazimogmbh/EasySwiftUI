//
//  EasyGeometryEffect.swift
//
//
//  Created by Yevhenii Korsun on 27.02.2024.
//

import SwiftUI

public struct EasyNamespace {
    public let prefix: String
    public let parentPrefix: String
    public let namespace: Namespace.ID?
    
    public init(prefix: String, parentPrefix: String, namespace: Namespace.ID?) {
        self.prefix = prefix
        self.parentPrefix = parentPrefix
        self.namespace = namespace
    }
}

public struct EasyNamespaceEnvironmentKey: EnvironmentKey {
    public static var defaultValue: EasyNamespace = .init(prefix: UUID().uuidString, parentPrefix: UUID().uuidString, namespace: nil)
}

public extension EnvironmentValues {
    var easyNamespace: EasyNamespace {
        get { self[EasyNamespaceEnvironmentKey.self] }
        set { self[EasyNamespaceEnvironmentKey.self] = newValue }
    }
}

fileprivate struct NamespaceModifier<ID: Hashable>: ViewModifier {
    struct CombinedHashableObject: Hashable {
        let value: String
        let hashableObject: ID

        func hash(into hasher: inout Hasher) {
            hasher.combine(value)
            hasher.combine(hashableObject.hashValue)
        }
    }
    
    @Environment(\.easyNamespace) private var easyNamespace
    let id: ID
    var isRoot: Bool
    var properties: MatchedGeometryProperties = .frame
    var anchor: UnitPoint = .center
    var isSource: Bool = true
    
    var newId: CombinedHashableObject {
        if isRoot {
            CombinedHashableObject(value: easyNamespace.prefix, hashableObject: id)
        } else {
            CombinedHashableObject(value: easyNamespace.parentPrefix, hashableObject: id)
        }
    }
    
    func body(content: Content) -> some View {
        if let namespace = easyNamespace.namespace {
            content
                .matchedGeometryEffect(
                    id: newId,
                    in: namespace,
                    properties: properties,
                    anchor: anchor,
                    isSource: isSource
                )
        } else {
            content
        }
    }
}

public extension View {
    func easyGeometryEffect<ID: Hashable>(
        id: ID,
        isRoot: Bool,
        properties: MatchedGeometryProperties = .frame,
        anchor: UnitPoint = .center,
        isSource: Bool = true
    ) -> some View {
        modifier(
            NamespaceModifier(
                id: id,
                isRoot: isRoot,
                properties: properties,
                anchor: anchor,
                isSource: isSource
            )
        )
    }
}
