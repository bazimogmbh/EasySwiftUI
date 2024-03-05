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
    public let topScreenPrefix: String
    public let namespace: Namespace.ID?
    
    public init(prefix: String, parentPrefix: String, topScreenPrefix: String, namespace: Namespace.ID?) {
        self.prefix = prefix
        self.parentPrefix = parentPrefix
        self.topScreenPrefix = topScreenPrefix
        self.namespace = namespace
    }
    
    public var isTopScreen: Bool {
        prefix == topScreenPrefix
    }
}

public struct EasyNamespaceEnvironmentKey: EnvironmentKey {
    public static var defaultValue: EasyNamespace = .init(prefix: UUID().uuidString, parentPrefix: UUID().uuidString, topScreenPrefix: UUID().uuidString, namespace: nil)
}

public extension EnvironmentValues {
    var easyNamespace: EasyNamespace {
        get { self[EasyNamespaceEnvironmentKey.self] }
        set { self[EasyNamespaceEnvironmentKey.self] = newValue }
    }
}

@MainActor
final class NamespaceStorrage: ObservableObject {
    static let shared = NamespaceStorrage()

    @Published var childIds = Set<Int>()
    
    private init() {
        
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
    @ObservedObject private var namespaceStorrage = NamespaceStorrage.shared
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
    
    var dummyId: CombinedHashableObject {
        CombinedHashableObject(value: "dummy" + easyNamespace.prefix, hashableObject: id)
    }

    func body(content: Content) -> some View {
        if let namespace = easyNamespace.namespace {
            if isRoot {
                content
                    .matchedGeometryEffect(
                        id: easyNamespace.isTopScreen ? newId : dummyId, //newId,//
                        in: namespace,
                        properties: properties,
                        anchor: anchor,
                        isSource: isSource
                    )
                    .animation(nil, value: easyNamespace.isTopScreen)
                    .opacity(namespaceStorrage.childIds.contains(newId.hashValue) ? 0 : 1)
            } else {
                content
                    .matchedGeometryEffect(
                        id: newId,
                        in: namespace,
                        properties: properties,
                        anchor: anchor,
                        isSource: isSource
                    )
                    .task {
                       try? await Task.sleep(nanoseconds: 100_000)
                        namespaceStorrage.childIds.insert(newId.hashValue)
                    }
                    .onDisappear {
                        namespaceStorrage.childIds.remove(newId.hashValue)
                    }
            }
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
