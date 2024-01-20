//
//  PaddingStyle.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 13.01.2024.
//

import SwiftUI

// MARK: - PaddingStyle
enum PaddingStyle: CGFloat {
    /// 0pt
    case zero = 0
    /// 2pt
    case xxsmall = 2
    /// 4pt
    case xsmall = 4
    /// 8pt
    case small = 8
    /// 16pt
    case normal = 16
    /// 24pt
    case large = 24
    /// 32pt
    case xlarge = 32
    /// 64pt
    case xxlarge = 64
}

// MARK: - View
extension View {
    func padding(_ style: PaddingStyle) -> some View {
        self.padding(.all, style)
    }

    func padding(_ edges: Edge.Set = .all, _ style: PaddingStyle) -> some View {
        self.padding(edges, style.rawValue)
    }

    func padding(top: PaddingStyle) -> some View {
        self.padding(.top, top)
    }

    func padding(bottom: PaddingStyle) -> some View {
        self.padding(.bottom, bottom)
    }

    func padding(leading: PaddingStyle) -> some View {
        self.padding(.leading, leading)
    }

    func padding(trailing: PaddingStyle) -> some View {
        self.padding(.trailing, trailing)
    }

    func padding(vertical: PaddingStyle) -> some View {
        self.padding(.vertical, vertical)
    }

    func padding(horizontal: PaddingStyle) -> some View {
        self.padding(.horizontal, horizontal)
    }

    func padding(vertical: PaddingStyle, horizontal: PaddingStyle) -> some View {
        self.padding(.init(top: vertical.rawValue, leading: horizontal.rawValue, bottom: vertical.rawValue, trailing: horizontal.rawValue))
    }
}

// MARK: - Spacer
extension Spacer {
    init(minLength: PaddingStyle) {
        self.init(minLength: minLength.rawValue)
    }
}

// MARK: - VStak {
extension VStack {
    init(alignment: HorizontalAlignment = .center, spacing: PaddingStyle, @ViewBuilder content: () -> Content) {
        self.init(alignment: alignment, spacing: spacing.rawValue, content: content)
    }
}

// MARK: - HStak {
extension HStack {
    init(alignment: VerticalAlignment = .center, spacing: PaddingStyle, @ViewBuilder content: () -> Content) {
        self.init(alignment: alignment, spacing: spacing.rawValue, content: content)
    }
}
