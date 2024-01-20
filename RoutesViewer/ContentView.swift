//
//  ContentView.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 11.01.2024.
//

import SwiftUI

struct ContentView: View {
    var documentStorage: DocumentStorage

    var body: some View {
        NavigationSplitView {
            FilesTree(documentStorage: documentStorage)
                .navigationTitle(documentStorage.selectedTrack?.name ?? documentStorage.selectedDocument?.name ?? "")
        } content: {
            SidebarView(documentStorage: documentStorage)
        } detail: {
            MapView(documentStorage: documentStorage)
        }
    }
}

#Preview {
    ContentView(documentStorage: .init())
}
