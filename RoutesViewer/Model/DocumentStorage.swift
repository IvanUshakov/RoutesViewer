//
//  DocumentStorage.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 13.01.2024.
//

import Foundation
import UniformTypeIdentifiers

@Observable
final class DocumentStorage {
    var documentsTree: [DocumentsTree] = []
    var selectedTrack: Track?

    var selectedDocument: RouteDocument? {
        selectedTrack?.document
    }

    var supportedContentTypes: [UTType] { [.gpx, .directory] }
}

// MARK: Open
extension DocumentStorage {
    func close(document: RouteDocument) {
        documentsTree.removeAll { treeElement in
            if case let .document(document: treeDocument) = treeElement, treeDocument === document {
                return true
            }

            return false
        }

        if selectedDocument?.id == document.id {
            selectFirstTrack()
        }
    }

    func open(urls: [URL]) throws {
        urls.forEach { url in
            guard url.startAccessingSecurityScopedResource() else {
                return // TODO: throw?
            }

            defer {
                url.stopAccessingSecurityScopedResource()
            }

            if url.isDirectory {
                try? openFolder(url: url) // TODO: throw
            } else if url.isFileURL {
                try? openFile(url: url)
            } else {
                return // TODO: throw
            }
        }

        if selectedDocument == nil {
            selectFirstTrack()
        }
    }
}

private extension DocumentStorage {

    func openFolder(url: URL) throws {
        guard url.isDirectory else {
            return // TODO: throw
        }

        try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: [], options: .skipsHiddenFiles)
            .filter { $0.contentType?.conforms(to: .gpx) == true }
            .forEach(self.openFile(url:))
    }

    func openFile(url: URL) throws {
        guard url.contentType?.conforms(to: .gpx) == true else {
            return // TODO: throw
        }

        let document = try RouteDocument(url: url)
        documentsTree.append(.document(document: document))
    }

    func selectFirstTrack() {
        selectedTrack = documentsTree
            .first {
                if case .document(let document) = $0, !document.tracks.isEmpty {
                    return true
                }

                return false
            }
            .flatMap {
                if case .document(let document) = $0 {
                    return document.tracks.first
                }

                return nil
            }
    }

}
