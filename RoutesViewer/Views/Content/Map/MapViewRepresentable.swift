//
//  MapViewRepresentable.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 30.01.2024.
//

import SwiftUI

struct MapViewRepresentable: NSViewRepresentable {
    typealias NSViewType = MapView

    var documentStorage: DocumentStorage

    func makeNSView(context: Context) -> MapView {
        MapView(documentStorage: documentStorage)
    }

    func updateNSView(_ nsView: MapView, context: Context) {}
}
