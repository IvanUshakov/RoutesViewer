//
//  AnyButtonStyle.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 13.01.2024.
//

import SwiftUI

public struct AnyButtonStyle: ButtonStyle {
    public let buttonStyle: any ButtonStyle

    public func makeBody(configuration: Configuration) -> some View {
        buttonStyle.makeBody(configuration: configuration).eraseToAnyView()
    }
}

extension ButtonStyle {
    public func eraseToAnyButtonStyle() -> AnyButtonStyle {
        return AnyButtonStyle(buttonStyle: self)
    }
}
