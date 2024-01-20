//
//  DirectoryView.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 14.01.2024.
//

import SwiftUI

extension FilesTree {
    struct DirectoryView: View {
        var documentStorage: DocumentStorage
        var padding: CGFloat
        var directory: DocumentsDirectory

        var body: some View {
            Label(directory.name, systemImage: "folder.fill")
                .padding(.leading, PaddingStyle.normal.rawValue * padding)
                .padding(vertical: .xsmall)
                .font(.system(.body, weight: .medium))
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}
