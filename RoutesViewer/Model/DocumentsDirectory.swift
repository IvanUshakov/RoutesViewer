//
//  DocumentsDirectory.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 13.01.2024.
//

import Foundation

@Observable
final class DocumentsDirectory: Identifiable {
    let url: URL?
    let documents: [RouteDocument]

    var name: String {
        url?.lastPathComponent ?? "unknown"
    }

    init(url: URL?, documents: [RouteDocument]) {
        self.url = url
        self.documents = documents
    }
}
