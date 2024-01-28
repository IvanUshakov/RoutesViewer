//
//  ColorPicker.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 28.01.2024.
//

import SwiftUI

struct ColorPicker: View {
    @Binding var color: NSColor
    @State private var prevHue: CGFloat?

    var body: some View {
        GeometryReader { proxy in
            Rectangle()
                .fill(hueGradient)
                .frame(width: proxy.size.width, height: proxy.size.height)
                .overlay {
                    Rectangle()
                        .fill(bwGradient)
                }
                .overlay {
                    Circle()
                        .stroke(.gray, lineWidth: 1)
                        .frame(width: 10)
                        .position(xyFromColor(size: proxy.size))
                }
                .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in
                        updateColor(
                            x: value.location.x / proxy.size.width,
                            y: value.location.y / proxy.size.height
                        )
                    }
                )
        }
    }

    var hueGradient: LinearGradient {
        let colors = (0...24).map {
            Color(hue: (Double($0) / 24), saturation: 1, brightness: 1)
        }

        return LinearGradient(colors: colors, startPoint: .top, endPoint: .bottom)
    }

    var bwGradient: LinearGradient {
        LinearGradient(colors: [Color.white, Color.clear, Color.black], startPoint: .leading, endPoint: .trailing)
    }

    func updateColor(x: CGFloat, y: CGFloat) {
        let x = max(min(x, 1), 0)
        let y = max(min(y, 1), 0)

        if x < 0.5 {
            self.color = NSColor(hue: y, saturation: 2 * x, brightness: 1, alpha: 1)
        } else {
            self.color = NSColor(hue: y, saturation: 1, brightness: (2 * (1 - x)), alpha: 1)
        }
        self.prevHue = y
    }

    func xyFromColor(size: CGSize) -> CGPoint {
        let saturation = color.saturationComponent
        let brightness = color.brightnessComponent
        var hue = color.hueComponent

        if let prevHue, hue == 0 || hue == 1 || saturation == 0 || brightness == 0 {
            hue = prevHue
        }

        return .init(
            x: size.width * (saturation < brightness ? saturation / 2 : (1 - brightness / 2)),
            y: size.height * hue
        )
    }
}

#Preview {
    ColorPicker(color: .constant(.red))
}
