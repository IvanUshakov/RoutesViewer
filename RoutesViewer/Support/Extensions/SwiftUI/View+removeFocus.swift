//
//  View+removeFocus.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 14.01.2024.
//

import SwiftUI

public struct RemoveFocusOnTapModifier: ViewModifier {
    public func body(content: Content) -> some View {
        content
            .onTapGesture {
                content.removeFocus()
            }
    }
}

extension View {
    func removeFocus() {
        DispatchQueue.main.async {
            NSApp.keyWindow?.makeFirstResponder(nil)
        }
    }

    public func removeFocusOnTap() -> some View {
        modifier(RemoveFocusOnTapModifier())
    }
}
