//
//  FilesTree.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 13.01.2024.
//

import SwiftUI

struct FilesTree: View {
    var documentStorage: DocumentStorage

    var body: some View {
        ScrollView {
            VStack(spacing: .zero) {
                ForEach(documentStorage.documentsTree) { treeElement in
                    switch treeElement {
                    case .directory(let directory): 
                        DirectoryView(documentStorage: documentStorage, padding: 0, directory: directory)
                    case .document(let document):
                        DocumentView(documentStorage: documentStorage, padding: 0, document: document)
                    }
                }
            }
            .padding(.small)
        }
        .removeFocusOnTap()
    }
}

#Preview {
    FilesTree(documentStorage: .init())
}
