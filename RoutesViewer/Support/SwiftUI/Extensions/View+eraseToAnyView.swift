//
//  View+eraseToAnyView.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 13.01.2024.
//

import SwiftUI

extension View {
    public func eraseToAnyView() -> AnyView {
        return .init(self)
    }
}
