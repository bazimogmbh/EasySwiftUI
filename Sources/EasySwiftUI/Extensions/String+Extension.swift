//
//  File.swift
//  
//
//  Created by Yevhenii Korsun on 24.11.2023.
//

import Foundation

postfix operator ~
//postfix func ~(string: String) -> String {
//    return String(localized: .init(string), bundle: .module)
//}

postfix func ~(string: String) -> String {
    NSLocalizedString(string, bundle: .module, comment: "")
    }

//import SwiftUI
//
//struct ContentView: View {
//    var body: some View {
//        let text = "Please help us to grow 🙏"~
//        Text(text)
//        Text("Please help us to grow 🙏", bundle: .module)
//        
//        Button("alert") {
//            RedirectService.showAlertPlzHelpUsToGrow()
//        }
//    }
//}
//
//#Preview {
//    ContentView()
//        .environment(\.locale, .init(identifier: "ru"))
//}
