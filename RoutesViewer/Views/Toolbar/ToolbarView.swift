//
//  ToolbarView.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 03.02.2024.
//

import SwiftUI

struct ToolbarView: View {
    var documentStorage: DocumentStorage
    @Bindable var settings: Settings

    var body: some View {
        HStack(spacing: .small) {
            if let track = documentStorage.selectedTrack {
                showTrackGradientView
                TrackStyleButton(track: track)
            }

            tileServerPicker
        }
    }

    var showTrackGradientView: some View {
        Button {
            settings.showTrackGradient.toggle()
        } label: {
            Image(systemName: settings.showTrackGradient ? "arrowshape.zigzag.right.fill" : "arrowshape.zigzag.right")
        }
    }

    var tileServerPicker: some View {
        Picker(settings.tileServer.name, selection: $settings.tileServer) {
            ForEach(TileServer.allCases, id: \.self) { style in
                Text(style.name)
            }
        }
        .frame(width: 200)
    }
}

#Preview {
    ToolbarView(documentStorage: .init(), settings: .init())
}
