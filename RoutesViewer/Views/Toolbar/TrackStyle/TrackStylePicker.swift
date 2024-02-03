//
//  TrackStylePicker.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 28.01.2024.
//

import SwiftUI

struct TrackStylePicker: View {
    @Binding var color: NSColor
    @Binding var weight: Double

    var body: some View {
        VStack(spacing: .normal) {
            ColorPicker(color: $color)
                .frame(height: 100)

            Divider()
            ColorPalateView(color: $color)
            Divider()
            alphaSliderView
        }
        .padding(.normal)
    }

    var alphaSliderView: some View {
        VStack(spacing: .xsmall) {
            HStack(spacing: .zero) {
                Text("Weight: ")
                Text(weight, format: .number)
                    .frame(width: 16, alignment: .leading)
            }
            .frame(maxWidth: .infinity)
            .font(.subheadline)

            Slider(value: weightBinding, in: 4...20) {
                Text("")
            } minimumValueLabel: {
                Text("4")
            } maximumValueLabel: {
                Text("20")
            }
            .labelsHidden()
        }
    }

    var weightBinding: Binding<Double> {
        .init {
            Double(Int(weight))
        } set: { newValue in
            weight = newValue.rounded()
        }
    }
}

#Preview {
    TrackStylePicker(color: .constant(.blue), weight: .constant(10))
}
