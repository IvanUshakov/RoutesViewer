//
//  ColorPalate.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 28.01.2024.
//

import Foundation
import Cocoa

class ColorPalate {
    static let shared: ColorPalate = .init()
    let colors: [NSColor]

    private var currentIndex = 0

    private init() {
        self.colors = [(1, 0.5), (0.9, 0.9), (0.3, 1)].reduce(into: []) { (result, element) in
            result += (0...4).map {
                NSColor(hue: Double($0)/5, saturation: element.0, brightness: element.1, alpha: 1)
            }
        }
    }

    func color() -> NSColor {
        defer {
            currentIndex = (currentIndex + 1) % colors.count
        }
        return colors[currentIndex]
    }
}
