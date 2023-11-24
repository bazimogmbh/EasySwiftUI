//
//  SystemAlert.swift
//
//
//  Created by Yevhenii Korsun on 24.11.2023.
//

import SwiftUI

public enum SystemAlertButton: Identifiable {
    case ok(String = NSLocalizedString("Ok", comment:""), action: () -> Void = {}),
         cancel(String = NSLocalizedString("Cancel", comment:""), action: () -> Void = {}),
         destructive(String, action: () -> Void = {})
    
    public var buttonRole: ButtonRole? {
        switch self {
        case .ok: return nil
        case .cancel: return .cancel
        case .destructive: return .destructive
        }
    }
    
    public var id: UUID {
        UUID()
    }
    
    public var action: () -> Void {
        switch self {
        case .cancel(_, let action): return action
        case .destructive(_, let action): return action
        case .ok(_, let action): return action
        }
    }
    
    public var title: String {
        switch self {
        case .cancel(let title, _): return title
        case .ok(let title, _): return title
        case .destructive(let title, _): return title
        }
    }
}

public struct SystemAlert: View {
    public let title: String
    public let message: String
    public let buttons: [SystemAlertButton]

    public var body: some View {
        SystemAlertContainer(title: title, message: message, buttons: buttons) {
        }
    }
}

public struct InputSystemAlert: View {
    @State private var text: String = ""
    
    public let title: String
    public let message: String
    public let okAction: @MainActor (String) -> ()

    public var body: some View {
        SystemAlertContainer(title: title, message: message, buttons: [
            .cancel(),
            .ok {
                okAction(text)
            }
        ]) {
            TextField("", text: $text)
                .textContentType(.shipmentTrackingNumber)
        }
    }
}

public struct SystemAlertContainer<Content: View>: View {
    @Environment(\.easyDismiss) var easyDismiss
    @State private var isShowAlert: Bool = true
    
    public let title: String
    public let message: String
    public let buttons: [SystemAlertButton]
    @ViewBuilder public let content: () -> Content
    
    public var body: some View {
        ZStackWithBackground(.color(.transparent)) {
            
        }
        .alert(title, isPresented: $isShowAlert) {
            ForEach(buttons) { button in
                Button(button.title, role: button.buttonRole, action: button.action)
            }
            
            content()
        } message: {
            Text(message)
        }
        .onChange(of: isShowAlert) { newValue in
            if !newValue { easyDismiss() }
        }
    }
}
