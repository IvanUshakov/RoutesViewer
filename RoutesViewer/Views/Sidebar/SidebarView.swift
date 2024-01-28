//
//  SidebarView.swift
//  GPXViewer
//
//  Created by Ivan Ushakov on 08.01.2024.
//

import SwiftUI

struct SidebarView: View {
    var documentStorage: DocumentStorage

    var body: some View {
        if let track = documentStorage.selectedTrack {
            ScrollView {
                contentView(track: track)
            }
        }
    }

    func contentView(track: Track) -> some View {
        VStack(spacing: .large) {
            EditTrackMetadataView(track: track)
            StatisticView(track: track)
        }
    }
}

#Preview {
    SidebarView(documentStorage: .init())
}
