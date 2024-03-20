//
//  ObservableScrollView.swift
//
//
//  Created by Jenya Korsun on 19.03.2024.
//

import SwiftUI

fileprivate struct NavScrollPreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

fileprivate struct TabScrollPreferenceKey: PreferenceKey {
    static var defaultValue: CGRect = .zero
    static func reduce(value: inout CGRect, nextValue: () -> CGRect) {
        value = nextValue()
    }
}

@MainActor
final class NavigationBarScrollObserver: ObservableObject {
    let coordinateSpace = UUID().uuidString
    
    var isScrollingTop = false
    @Published private(set) var rect: CGRect = .zero
    
    var minYOffset: CGFloat {
        let value = rect.minY
        var offsetY: CGFloat = 0
        
        if !isScrollingTop {
            offsetY = value
        } else {
            offsetY = 0
        }
        
        isScrollingTop = value < 0
        return offsetY
    }
    
    func set(_ rect: CGRect) {
        self.rect = rect
    }
}

@MainActor
final class TabBarScrollObserver: ObservableObject {
    @Published private(set) var rect: CGRect = .zero
    
    func isScrollingBottom(in proxy: GeometryProxy) -> Bool {
        rect.maxY > proxy.frame(in: .global).minY
    }
    
    func set(_ rect: CGRect) {
        self.rect = rect
    }
}

public struct ObservableScrollView<Content: View>: View {
    public enum ScrollObserver {
        case navBar, tabBar
    }
    
    @EnvironmentObject private var navObserver: NavigationBarScrollObserver
    @EnvironmentObject private var tabObserver: TabBarScrollObserver
    @State private var isShow = false
    
    var showsIndicators = true
    var observers: Set<ScrollObserver>
    
    @ViewBuilder let content: () -> Content
    
    public init(
        showsIndicators: Bool = true,
        observers: Set<ScrollObserver> = [.navBar],
        content: @escaping () -> Content
    ) {
        self.showsIndicators = showsIndicators
        self.observers = observers
        self.content = content
    }
    
    public var body: some View {
        ScrollView(.vertical, showsIndicators: showsIndicators) {
            content()
                .background(alignment: .top) {
                    if isShow && observers.contains(.navBar) {
                        GeometryReader { proxy in
                            Color.clear
                                .preference(key: NavScrollPreferenceKey.self, value: proxy.frame(in: .named(navObserver.coordinateSpace)))
                                .onPreferenceChange(NavScrollPreferenceKey.self) { rect in
                                    navObserver.set(rect)
                                }
                        }
                        .frame(height: 0)
                    }
                }
                .background(alignment: .bottom) {
                    if isShow && observers.contains(.tabBar) {
                        GeometryReader { proxy in
                            Color.clear
                                .preference(key: TabScrollPreferenceKey.self, value: proxy.frame(in: .global))
                                .onPreferenceChange(TabScrollPreferenceKey.self) { rect in
                                    tabObserver.set(rect)
                                }
                        }
                        .frame(height: 0)
                    }
                }
        }
        .onAppear {
            isShow = true
        }
        .onDisappear {
            isShow = false
        }
    }
}

#Preview {
    ObservableScrollView {
        Color.red
    }
}
