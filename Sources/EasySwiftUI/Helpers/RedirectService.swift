//
//  RedirectService.swift
//  
//
//  Created by Yevhenii Korsun on 26.09.2023.
//

#if !os(macOS)

import SwiftUI
import StoreKit
import SafariServices

public enum RedirectService {
    static private let supportService = SupportEmailService()
    
    public static func redirect(to url: String) {
        if let url = URL(string: url) {
            let safari = SFSafariViewController(url: url)
            
            DispatchQueue.main.async {
                UIApplication.topViewController?.present(safari, animated: true)
            }
        }
    }

    public static func rateAppPresent() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }

    public static func share(_ fileUrl: String, proxy: GeometryProxy?) {
        if let url = URL(string: fileUrl) {
            share([url], proxy: proxy)
        }
    }
    
    public static func sendSupportEmail(toAddress: String) {
        supportService.send(toAddress: toAddress)
    }
    
    public static func share(_ items: [Any], proxy: GeometryProxy?) {
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        if let vc = UIApplication.topViewController {
            activityViewController.popoverPresentationController?.sourceView = vc.view
            if let proxy {
                activityViewController.popoverPresentationController?.sourceRect = proxy.frame(in: .global)
            }
            vc.present(activityViewController, animated: true, completion: nil)
        }
    }
}

fileprivate struct SupportEmailService {
    let subject: String = "Support Email"
    let messageHeader: String = "Please describe your issue below"
    var body: String {"""
        Application Name: \(Bundle.main.displayName)
        iOS: \(UIDevice.current.systemVersion)
        Device Model: \(UIDevice.current.modelName)
        Appp Version: \(Bundle.main.appVersion)
        App Build: \(Bundle.main.appBuild)
        \(messageHeader)
    --------------------------------------
    """
    }
    
    func send(toAddress: String) {
        let urlString = "mailto:\(toAddress)?subject=\(subject.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")&body=\(body.addingPercentEncoding(withAllowedCharacters: .urlPathAllowed) ?? "")"
        guard let url = URL(string: urlString) else { return }
        
        DispatchQueue.main.async {
            UIApplication.shared.open(url)
        }
    }
}

fileprivate extension UIDevice {
    var modelName: String {
#if targetEnvironment(simulator)
        let identifier = ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"]!
#else
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
#endif
        return identifier
    }
}

fileprivate extension Bundle {
    var displayName: String {
        object(forInfoDictionaryKey: "CFBundleName") as? String ?? "Could not determine the application name"
    }
    
    var appBuild: String {
        object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Could not determine the application build number"
    }
    
    var appVersion: String {
        object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Could not determine the application version"
    }
}

#endif
