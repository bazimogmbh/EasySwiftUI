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
final class TabBarScrollObserverContainer: ObservableObject {
    var observer: TabBarScrollObserver = TabBarScrollObserver()
}

@MainActor
final class NavBarScrollObserverContainer: ObservableObject {
    var observer: NavigationBarScrollObserver = NavigationBarScrollObserver()
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

struct NavBarHasObserverKey: EnvironmentKey {
    public static var defaultValue: Bool = false
}

extension EnvironmentValues {
    var navBarHasObserver: Bool {
        get { self[NavBarHasObserverKey.self] }
        set { self[NavBarHasObserverKey.self] = newValue }
    }
}

struct TabBarHasObserverKey: EnvironmentKey {
    public static var defaultValue: Bool = false
}

extension EnvironmentValues {
    var tabBarHasObserver: Bool {
        get { self[TabBarHasObserverKey.self] }
        set { self[TabBarHasObserverKey.self] = newValue }
    }
}

public struct ObservableScrollView<Content: View>: View {
    public enum ScrollObserver {
        case navBar, tabBar
    }
    
    @Environment(\.navBarHasObserver) private var navBarHasObserver
    @Environment(\.tabBarHasObserver) private var tabBarHasObserver
    
    @EnvironmentObject private var navObserver: NavBarScrollObserverContainer
    @EnvironmentObject private var tabObserver: TabBarScrollObserverContainer
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
                    if isShow && observers.contains(.navBar) && navBarHasObserver {
                        GeometryReader { proxy in
                            Color.clear
                                .preference(key: NavScrollPreferenceKey.self, value: proxy.frame(in: .named(navObserver.observer.coordinateSpace)))
                                .onPreferenceChange(NavScrollPreferenceKey.self) { rect in
                                    navObserver.observer.set(rect)
                                }
                        }
                        .frame(height: 0)
                    }
                }
                .background(alignment: .bottom) {
                    if isShow && observers.contains(.tabBar) && tabBarHasObserver {
                        GeometryReader { proxy in
                            Color.clear
                                .preference(key: TabScrollPreferenceKey.self, value: proxy.frame(in: .global))
                                .onPreferenceChange(TabScrollPreferenceKey.self) { rect in
                                    tabObserver.observer.set(rect)
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

#if !os(tvOS)

public struct ObservableList<Content: View>: View {
    public enum ScrollObserver {
        case navBar, tabBar
    }
    
    @Environment(\.navBarHasObserver) private var navBarHasObserver
    @Environment(\.tabBarHasObserver) private var tabBarHasObserver
    
    @EnvironmentObject private var navObserver: NavBarScrollObserverContainer
    @EnvironmentObject private var tabObserver: TabBarScrollObserverContainer
    @State private var isShow = false
    
    var observers: Set<ScrollObserver>
    
    @ViewBuilder let content: () -> Content
    
    public init(
        observers: Set<ScrollObserver> = [.navBar],
        content: @escaping () -> Content
    ) {
        self.observers = observers
        self.content = content
    }
    
    public var body: some View {
        ClearList {
            content()
                .background(alignment: .top) {
                    if isShow && observers.contains(.navBar) && navBarHasObserver {
                        GeometryReader { proxy in
                            Color.clear
                                .preference(key: NavScrollPreferenceKey.self, value: proxy.frame(in: .named(navObserver.observer.coordinateSpace)))
                                .onPreferenceChange(NavScrollPreferenceKey.self) { rect in
                                    navObserver.observer.set(rect)
                                }
                        }
                        .frame(height: 0)
                    }
                }
                .background(alignment: .bottom) {
                    if isShow && observers.contains(.tabBar) && tabBarHasObserver {
                        GeometryReader { proxy in
                            Color.clear
                                .preference(key: TabScrollPreferenceKey.self, value: proxy.frame(in: .global))
                                .onPreferenceChange(TabScrollPreferenceKey.self) { rect in
                                    tabObserver.observer.set(rect)
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
#endif

#Preview {
    ObservableScrollView {
        Color.red
    }
}
