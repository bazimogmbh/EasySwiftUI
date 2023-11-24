//
//  File.swift
//  
//
//  Created by Yevhenii Korsun on 24.11.2023.
//

import Foundation

postfix operator ~
postfix func ~(string: String) -> String {
    return NSLocalizedString(string, comment: "")
}
