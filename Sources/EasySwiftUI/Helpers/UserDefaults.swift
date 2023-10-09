//
//  UserDefaults.swift
//  
//
//  Created by Yevhenii Korsun on 26.09.2023.
//

import Foundation
import Combine

// MARK: - How to use

//extension UserDefaultsKey {
//    static let isSubscribed = UserDefaultsKey(rawValue: "isSubscribed")
//}

public protocol DefaultsStoragable {
    associatedtype UserDefaultsKeyType: RawRepresentable where UserDefaultsKeyType.RawValue == String
    
    static func saveInDefaults(_ value: Any?, for key: UserDefaultsKeyType)
    static func getFromDefaults<T>(_ key: UserDefaultsKeyType) -> T?
}

public extension DefaultsStoragable {
    static func saveInDefaults(_ value: Any?, for key: UserDefaultsKeyType) {
        if let enumValue = value as? any RawRepresentable {
            UserDefaults.standard.set(enumValue.rawValue, forKey: key.rawValue)
        } else {
            UserDefaults.standard.set(value, forKey: key.rawValue)
        }
    }
    
    static func getFromDefaults<T>(_ key: UserDefaultsKeyType) -> T? {
        return UserDefaults.standard.value(forKey: key.rawValue) as? T
    }
    
    static func getFromDefaults<T: RawRepresentable>(_ key: UserDefaultsKeyType) -> T? {
        guard let value = UserDefaults.standard.object(forKey: key.rawValue) as? T.RawValue else {
            return nil
        }

        return T(rawValue: value)
    }
    
    static func saveAsData<T: Codable>(_ value: T, for key: UserDefaultsKeyType) {
        let data = try? JSONEncoder().encode(value)
        UserDefaults.standard.set(data, forKey: key.rawValue)
    }
    
    static func loadAsData<T: Codable>(for key: UserDefaultsKeyType) -> T? {
        guard let data = UserDefaults.standard.object(forKey: key.rawValue) as? Data else {
            return nil
        }
        
        let value = try? JSONDecoder().decode(T.self, from: data)
        return value
    }
}

@propertyWrapper
public struct DefaultsStorage<T> {
    private let key: UserDefaultsKey
    
    public var wrappedValue: T? {
        didSet {
            UserDefaults.saveInDefaults(wrappedValue, for: key)
        }
    }
    
    public init(wrappedValue: T, key: UserDefaultsKey) {
        if let value: T = UserDefaults.getFromDefaults(key) {
            self.wrappedValue = value
        } else {
            self.wrappedValue = wrappedValue
        }

        self.key = key
    }

    public init(wrappedValue: T, key: UserDefaultsKey) where T: RawRepresentable {
        if let value: T = UserDefaults.getFromDefaults(key) {
            self.wrappedValue = value
        } else {
            self.wrappedValue = wrappedValue
        }
        
        self.key = key
    }
}

// MARK: - UserDefaults for Published

fileprivate var cancellables = [String: AnyCancellable] ()

public extension Published where Value: Codable {
    init(wrappedValue defaultValue: Value, key: UserDefaultsKey, testValue: Value? = nil) {
        let value: Value = testValue ?? UserDefaults.loadAsData(for: key) ?? defaultValue
        
        self.init(initialValue: value)
        
        cancellables[key.rawValue] = projectedValue.dropFirst().sink { val in
            print("SAVING: \(val)")
            UserDefaults.saveAsData(val, for: key)
        }
    }
}

// MARK: - UserDefaultsKeys

public struct UserDefaultsKey: RawRepresentable {
    public init(rawValue: String) {
        self.rawValue = rawValue
    }
    
    public var rawValue: String
}

extension UserDefaults: DefaultsStoragable {
    public typealias UserDefaultsKeyType = UserDefaultsKey
}
