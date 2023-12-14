//
//  RefreshableScrollView.swift
//
//
//  Created by Yevhenii Korsun on 14.12.2023.
//

import SwiftUI

fileprivate struct ScrollPositionKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

fileprivate struct RefreshContentPositionKey: PreferenceKey {
    static var defaultValue: CGFloat = 0

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

public struct RefreshableScrollView<Content: View, RefreshContent: View>: View {
    @State private var isReady: Bool = false
    @State private var isRefreshing: Bool = false
    @State private var refreshContentHeight: CGFloat = 0

    public var minOffsetToRefresh: CGFloat = 60
    public let action: () async -> ()
    @ViewBuilder public let refreshContent: () -> RefreshContent
    @ViewBuilder public let content: () -> Content
    
    private let coordinateSpace: String = "coordinateSpace"
    
    public var body: some View {
        ScrollView {
            Color.clear
                .frame(height: 1)
                .background(GeometryReader { proxy in
                    Color.clear.preference(key: ScrollPositionKey.self, value: proxy.frame(in: .named(coordinateSpace)).origin.y)
                })
                .onPreferenceChange(ScrollPositionKey.self, perform: { perform($0) })
            
            content()
        }
        .coordinateSpace(name: coordinateSpace)
        .padding(.top, isRefreshing ? refreshContentHeight : 0)
        .overlayIf(isRefreshing, alignment: .top, content: refreshContentView)
        .onAppear {
            isReady = true
        }
    }
    
    @ViewBuilder
    private func refreshContentView() -> some View {
        Group {
            if RefreshContent.self == EmptyView.self {
                ProgressView()
            } else {
                refreshContent()
            }
        }
        .background(GeometryReader { proxy in
            Color.clear
                .onAppear {
                    refreshContentHeight = proxy.size.height
                }
        })
    }
    
    @MainActor
    private func perform(_ offset: CGFloat) {
        print("!@Offset: \(offset)")
        guard isReady, !isRefreshing, offset > minOffsetToRefresh else { return }
        
        Task {
            isRefreshing = true
            await action()
            isRefreshing = false
        }
    }
}

public extension RefreshableScrollView where RefreshContent == EmptyView {
    init(
        action: @escaping () async -> (),
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.init(action: action, refreshContent: { EmptyView() }, content: content)
    }
}
