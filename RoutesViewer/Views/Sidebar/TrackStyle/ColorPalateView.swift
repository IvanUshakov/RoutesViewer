//
//  ColorPalateView.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 28.01.2024.
//

import SwiftUI

struct ColorPalateView: View {
    @Binding var color: NSColor
    var perRow = 5
    private let count =  ColorPalate.shared.colors.count

    var body: some View {
        VStack(spacing: .small) {
            ForEach(colors, id: \.self) { row in
                HStack(spacing: .small) {
                    ForEach(row, id: \.self) { color in
                        Button {
                            self.color = color
                        } label: {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color(nsColor: color))
                                .frame(width: 40, height: 20)
                        }
                        .buttonStyle(.borderless)
                    }

                    Spacer(minLength: 0)
                }
            }
        }
    }

    var colors: [[NSColor]] {
        ColorPalate.shared.colors.chunked(into: perRow)
    }
}

#Preview {
    ColorPalateView(color: .constant(.blue))
}
