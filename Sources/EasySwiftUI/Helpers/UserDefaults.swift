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
    
    static func saveInDefaults(_ value: Any?, for key: UserDefaultsKeyType, in group: String?)
    static func getFromDefaults<T>(_ key: UserDefaultsKeyType, in group: String?) -> T?
    
    static func saveAsData<T: Codable>(_ value: T, for key: UserDefaultsKeyType, in group: String?)
    static func loadAsData<T: Codable>(for key: UserDefaultsKeyType, in group: String?) -> T?
    
    static func userDefaults(of group: String?) -> UserDefaults?
    static func removeObject(by key: UserDefaultsKeyType, in group: String?)
}

public extension DefaultsStoragable {
    static func userDefaults(of group: String?) -> UserDefaults? {
        guard let group else { return .standard }
        
        return UserDefaults(suiteName: group)
    }
    
    static func saveInDefaults(_ value: Any?, for key: UserDefaultsKeyType, in group: String? = nil) {
        guard let defaults = userDefaults(of: group) else { return }
        
        if let enumValue = value as? any RawRepresentable {
            defaults.set(enumValue.rawValue, forKey: key.rawValue)
        } else {
            defaults.set(value, forKey: key.rawValue)
        }
    }
    
    static func getFromDefaults<T>(_ key: UserDefaultsKeyType, in group: String? = nil) -> T? {
        guard let defaults = userDefaults(of: group) else { return nil }
        
        return defaults.value(forKey: key.rawValue) as? T
    }
    
    static func getFromDefaults<T: RawRepresentable>(_ key: UserDefaultsKeyType, in group: String? = nil) -> T? {
        guard let defaults = userDefaults(of: group),
              let value = defaults.object(forKey: key.rawValue) as? T.RawValue else {
            return nil
        }
        
        return T(rawValue: value)
    }
    
    static func saveAsData<T: Codable>(_ value: T, for key: UserDefaultsKeyType, in group: String? = nil) {
        guard let defaults = userDefaults(of: group) else { return }
        
        let data = try? JSONEncoder().encode(value)
        defaults.set(data, forKey: key.rawValue)
    }
    
    static func loadAsData<T: Codable>(for key: UserDefaultsKeyType, in group: String? = nil) -> T? {
        guard let defaults = userDefaults(of: group),
              let data = defaults.object(forKey: key.rawValue) as? Data else {
            return nil
        }
        
        let value = try? JSONDecoder().decode(T.self, from: data)
        return value
    }
    
    static func removeObject(by key: UserDefaultsKeyType, in group: String? = nil) {
        guard let defaults = userDefaults(of: group) else { return }
        defaults.removeObject(forKey: key.rawValue)
    }
    
    static func isTrue(for key: UserDefaultsKeyType, in group: String? = nil) -> Bool {
        if let value: Bool = getFromDefaults(key, in: group) {
            return value
        }
        
        return false
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
