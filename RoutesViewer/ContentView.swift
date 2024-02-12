//
//  ContentView.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 11.01.2024.
//

import SwiftUI

struct ContentView: View {
    var documentStorage: DocumentStorage
    var settings: Settings

    var body: some View {
        NavigationSplitView {
            FilesTree(documentStorage: documentStorage)
        } content: {
            SidebarView(documentStorage: documentStorage)
        } detail: {
            VStack {
                MapViewRepresentable(documentStorage: documentStorage, settings: settings)
                GraphicsView(documentStorage: documentStorage)
            }
        }
        .navigationTitle(documentStorage.selectedDocument?.name ?? "")
        .navigationSubtitle(documentStorage.selectedTrack?.name ?? "")
        .toolbar {
            ToolbarView(documentStorage: documentStorage, settings: settings)
        }
    }
}

#Preview {
    ContentView(documentStorage: .init(), settings: .init())
}
