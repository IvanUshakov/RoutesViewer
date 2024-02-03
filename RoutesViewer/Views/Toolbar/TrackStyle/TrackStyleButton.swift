//
//  TrackStyleButton.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 03.02.2024.
//

import SwiftUI

struct TrackStyleButton: View {
    @Bindable var track: Track
    @State var showColorPicker: Bool = false

    var body: some View {
        Button {
            showColorPicker.toggle()
        } label: {
            Circle()
                .fill(Color(nsColor: track.style.color))
        }
        .popover(isPresented: $showColorPicker) {
            TrackStylePicker(color: $track.style.color, weight: $track.style.weight)
        }
    }
}

//#Preview {
//    TrackStyleButton()
//}
