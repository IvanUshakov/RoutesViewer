//
//  DocumentsTree.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 13.01.2024.
//

import Foundation

enum DocumentsTree {
    case directory(directory: DocumentsDirectory)
    case document(document: RouteDocument)
}

extension DocumentsTree: Identifiable {
    var id: ObjectIdentifier {
        switch self {
        case .directory(let directory): directory.id
        case .document(let document): document.id
        }
    }
}
