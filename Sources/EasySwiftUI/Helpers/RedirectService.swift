//
//  RedirectService.swift
//  
//
//  Created by Yevhenii Korsun on 26.09.2023.
//

#if !os(macOS) && !os(tvOS)

import SwiftUI
import StoreKit

#if canImport(SafariServices)
import SafariServices
#endif

public struct RedirectItem: Hashable {
    public let url: String
    
    public init(_ url: String) {
        self.url = url
    }
}

public extension RedirectItem {
    func url(_ url: String) -> RedirectItem {
        RedirectItem(url)
    }
}

public enum RedirectService {
    public static func redirect(to item: RedirectItem, scheme: ColorScheme? = nil) {
        redirect(to: item.url, scheme: scheme)
    }
    
    static func redirect(to url: String, scheme: ColorScheme? = nil) {
#if canImport(SafariServices)
        if let url = URL(string: url) {
            let safari = SFSafariViewController(url: url)
            
            if let scheme {
                safari.overrideUserInterfaceStyle = scheme.style
            }
            
            DispatchQueue.main.async {
                UIApplication.topViewController?.present(safari, animated: true)
            }
        }
#endif
    }
    
    public static func rateAppPresent() {
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            SKStoreReviewController.requestReview(in: scene)
        }
    }
    
    public static func share(_ fileUrl: String, proxy: GeometryProxy?, scheme: ColorScheme? = nil) {
        if let url = URL(string: fileUrl) {
            share([url], proxy: proxy, scheme: scheme)
        }
    }
    
    public static func sendSupportEmail(toAddress: String, additionalInfo: String? = nil) {
        let supportService = SupportEmailService(additionalInfo: additionalInfo)
        supportService.send(toAddress: toAddress)
    }
    
    public static func share(_ items: [Any], proxy: GeometryProxy?, scheme: ColorScheme? = nil) {
        share(items, rect: proxy?.frame(in: .global), scheme: scheme)
    }
    
    public static func share(_ items: [Any], rect: CGRect?, scheme: ColorScheme? = nil) {
        let activityViewController = UIActivityViewController(activityItems: items, applicationActivities: nil)
        
        if let vc = UIApplication.topViewController {
            activityViewController.popoverPresentationController?.sourceView = vc.view
            
            if let scheme {
                activityViewController.overrideUserInterfaceStyle = scheme.style
            }
            
            if let rect {
                activityViewController.popoverPresentationController?.sourceRect = rect
            }
            
            vc.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    public static func showRateApp() {
        Task { @MainActor in
            if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                SKStoreReviewController.requestReview(in: scene)
            }
        }
    }
    
    public static func redirectToReview(by appStoreId: String) {
        if let writeReviewURL = URL(string: "https://itunes.apple.com/app/id\(appStoreId)?action=write-review") {
            UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
        }
    }
}

public extension RedirectService {
    static func showAlertPlzHelpUsToGrow() {
        presentAlert(title: "Please help us to grow 🙏"~,
                     message: "Can you show us some love?"~,
                     primaryAction: UIAlertAction(title: "Sure!"~, style: .default, handler: { _ in showRateApp() }),
                     secondaryAction: UIAlertAction(title: "Next Time"~, style: .cancel, handler: nil)
        )
    }
    
    static func showAlertDoYouLikeOurApp(by appStoreId: String) {
        presentAlert(title: "Do you like our app?",
                     message: "",
                     primaryAction: UIAlertAction(title: "Yes 😁"~, style: .default, handler: { _ in redirectToReview(by: appStoreId) }),
                     secondaryAction: UIAlertAction(title: "No 🙁"~, style: .cancel, handler: nil)
        )
    }
    
    static func showAlertDoYouLikeOurAppPeriodically(by appStoreId: String, countToShow: Int = 10) {
        let doYouLikeCounterKey = "doYouLikeCounter"
        let lastVersionPromptedForReviewKey = "lastVersionPromptedForReview"
        
        var count = UserDefaults.standard.integer(forKey: doYouLikeCounterKey)
        count += 1
        UserDefaults.standard.set(count, forKey: doYouLikeCounterKey)
        
        let lastVersionPromptedForReview = UserDefaults.standard.string(forKey: lastVersionPromptedForReviewKey)
        let infoDictionaryKey = kCFBundleVersionKey as String
        
        if let currentVersion = Bundle.main.object(forInfoDictionaryKey: infoDictionaryKey) as? String {
            if count >= countToShow && currentVersion != lastVersionPromptedForReview {
                Task { @MainActor in
                    UserDefaults.standard.set(0, forKey: doYouLikeCounterKey)
                    UserDefaults.standard.set(currentVersion, forKey: lastVersionPromptedForReviewKey)
                    showAlertDoYouLikeOurApp(by: appStoreId)
                }
            } else {
                Task {
                    try? await Task.sleep(nanoseconds: UInt64(3e9))
                    showRateApp()
                }
            }
        }
    }
    
    private static func presentAlert(title: String, message: String, primaryAction: UIAlertAction = .OK, secondaryAction: UIAlertAction? = nil, tertiaryAction: UIAlertAction? = nil) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(primaryAction)
            alert.preferredAction = primaryAction
            if let secondary = secondaryAction { alert.addAction(secondary) }
            if let tertiary = tertiaryAction { alert.addAction(tertiary) }
            UIApplication.topViewController?.present(alert, animated: true, completion: nil)
        }
    }
}

public extension UIAlertAction {
    static var OK: UIAlertAction {
        UIAlertAction(title: "Ok", style: .cancel, handler: nil)
    }
}

fileprivate extension ColorScheme {
    var style: UIUserInterfaceStyle {
        switch self {
        case .dark: return .dark
        case .light: return .light
        default: return .unspecified
        }
    }
}

fileprivate struct SupportEmailService {
    let subject: String = "Support Email"~
    let messageHeader: String = "Please describe your issue below"~
    let additionalInfo: String?
    
    var body: String {
        var baseInfo = """
        Application Name: \(Bundle.main.displayName)
        iOS: \(UIDevice.current.systemVersion)
        Device Model: \(UIDevice.current.modelName)
        App Version: \(Bundle.main.appVersion)
        App Build: \(Bundle.main.appBuild)
    """
        
        if let additionalInfo, !additionalInfo.isEmpty {
            baseInfo += "\n\(additionalInfo)"
        }
        
        return """
        \(baseInfo)
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

