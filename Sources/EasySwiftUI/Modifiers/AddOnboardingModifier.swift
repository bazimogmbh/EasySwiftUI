//
//  AddOnboardingModifier.swift
//  
//
//  Created by Yevhenii Korsun on 26.12.2023.
//

#if !os(macOS)

import SwiftUI

public protocol OnboardingStepProtocol: RawRepresentable<Int>, CaseIterable, Equatable {
    var isClosePage: Bool { get }
    var isAskReviewPage: Bool { get }
}

@MainActor
public protocol OnboardingHandlable: ObservableObject {
    var isFirstRun: Bool { get set }
    var isRunContentOnStart: Bool { get }
    func onCloseOnboarding()
}

public extension OnboardingHandlable {
    var isRunContentOnStart: Bool {
        true
    }
}

@MainActor
open class OnboardingBaseViewModel<T: OnboardingStepProtocol>: ObservableObject, Dismissable {
    @Published public var closeView: Bool = false
    @Published public var onboardingStep: T {
        didSet {
            handle(onboardingStep)
        }
    }
    
    private var isShowedAlertPlzHelpUsToGrow = false
    
    open var steps: [T] {
        T.allCases as! [T]
    }
    
    open var stepsForDisplay: [T] {
        steps.filter({ !$0.isClosePage })
    }
    
    public init(firstStep: T) {
        self.onboardingStep = firstStep
    }
    
    open func handleNext() {
        if let newStep = T(rawValue: self.onboardingStep.rawValue + 1) {
            self.onboardingStep = newStep
        }
    }
    
    open func handle(_ step: T) {
#if !os(macOS) && !os(tvOS)
        if step.isAskReviewPage, !self.isShowedAlertPlzHelpUsToGrow {
            RedirectService.showAlertPlzHelpUsToGrow()
            self.isShowedAlertPlzHelpUsToGrow = true
        }
#endif
        
        if step.isClosePage {
            self.dismiss()
        }
    }
}

fileprivate struct AddOnboardingModifier<VM: OnboardingHandlable, OnboardingView: View>: ViewModifier {
    @State private var isNeedToRunAction = true
    
    @StateObject var vm: VM
    let transition: AnyTransition
    @ViewBuilder let onboardingContent: () -> OnboardingView
    
    init(vm: VM, transition: AnyTransition = .asymmetric(insertion: .identity, removal: .opacity), onboardingContent: @escaping () -> OnboardingView) {
        self._vm = StateObject(wrappedValue: vm)
        self.transition = transition
        self.onboardingContent = onboardingContent
    }

    func body(content: Content) -> some View {
        ZStackWithBackground {
            if vm.isRunContentOnStart || !vm.isFirstRun {
                content
            }
        }
        .easyFullScreenCover(isPresented: $vm.isFirstRun, transition: transition) {
            onboardingContent()
        }
        .onChange(of: vm.isFirstRun) { isFirstRun in
            dismissAction()
        }
        .onAppear(perform: dismissAction)
    }
    
    @MainActor 
    private func dismissAction() {
        if !vm.isFirstRun, isNeedToRunAction {
            vm.onCloseOnboarding()
            isNeedToRunAction = false
        }
    }
}

public extension View {
    func easyOnboardingCover<VM: OnboardingHandlable, OnboardingView: View>(
        vm: VM,
        transition: AnyTransition = .asymmetric(insertion: .identity, removal: .opacity),
        @ViewBuilder onboardingContent: @escaping () -> OnboardingView
    ) -> some View {
        modifier(AddOnboardingModifier(vm: vm, transition: transition, onboardingContent: onboardingContent))
    }
}

#endif
