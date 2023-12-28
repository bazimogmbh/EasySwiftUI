//
//  File.swift
//  
//
//  Created by Yevhenii Korsun on 24.11.2023.
//

import Foundation

postfix operator ~
postfix func ~(string: String) -> String {
//    return String(localized: string, bundle: .module)
    return NSLocalizedString(string, bundle: .module, comment: "")
//    return NSLocalizedString(string, comment: "")
}
