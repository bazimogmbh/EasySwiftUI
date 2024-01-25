//
//  Shape+Extensions.swift
//
//
//  Created by Yevhenii Korsun on 25.01.2024.
//

import SwiftUI

public extension Shape {
    func fill<Content: ShapeStyle, StrokeContent: ShapeStyle>(
        _ content: Content,
        withStroke stroke: StrokeContent,
        lineWidth: CGFloat = 1
    ) -> some View {
        self
            .fill(content)
            .overlay {
                self
                .stroke(stroke, lineWidth: lineWidth)
            }
    }
}
