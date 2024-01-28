//
//  TrackStylePicker.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 28.01.2024.
//

import SwiftUI

struct TrackStylePicker: View {
    @Binding var color: NSColor
    @State private var alpha: CGFloat = 1

    var body: some View {
        VStack(spacing: .normal) {
            ColorPicker(color: $color)
                .frame(height: 100)

            Divider()
            alphaSliderView
            Divider()
            ColorPalateView(color: $color)
        }
        .padding(.normal)
    }

    var alphaSliderView: some View {
        Slider(value: $alpha, in: 0...100) {
            Text("Alpha: ")
        } minimumValueLabel: {
            Text("0")
        } maximumValueLabel: {
            Text("100")
        }
        .onChange(of: color) {
            self.color = NSColor(
                hue: color.hueComponent,
                saturation: color.saturationComponent,
                brightness: color.brightnessComponent,
                alpha: alpha / 100
            )
        }
        .onChange(of: alpha) {
            self.color = NSColor(
                hue: color.hueComponent,
                saturation: color.saturationComponent,
                brightness: color.brightnessComponent,
                alpha: alpha / 100
            )
        }
        .onAppear {
            alpha = color.alphaComponent * 100
        }
    }
}

#Preview {
    TrackStylePicker(color: .constant(.blue))
}
