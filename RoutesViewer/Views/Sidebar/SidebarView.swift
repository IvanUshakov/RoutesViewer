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
                StatisticView(track: track)
            }
        }
    }
}

#Preview {
    SidebarView(documentStorage: .init())
}
