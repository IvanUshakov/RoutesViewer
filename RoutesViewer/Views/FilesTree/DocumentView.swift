//
//  DocumentView.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 14.01.2024.
//

import SwiftUI

extension FilesTree {
    struct DocumentView: View {
        var documentStorage: DocumentStorage
        var padding: CGFloat
        var document: RouteDocument

        @State var showTracks: Bool = true

        var body: some View {
            Group {
                Label { documentLabelView } icon: { showHideTracksButtonView }
                tracksView
            }
        }

        var documentLabelView: some View {
            Label(document.name, systemImage: "doc.fill")
                .padding(.leading, PaddingStyle.normal.rawValue * padding)
                .padding(vertical: .xsmall)
                .font(.system(.body, weight: .medium))
                .lineLimit(1)
                .foregroundColor(documentStorage.selectedDocument === document ? .accentColor : nil)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contextMenu {
                    Button("Close") {
                        documentStorage.close(document: document)
                    }
                }
        }

        var showHideTracksButtonView: some View {
            Button {
                withAnimation(.easeInOut(duration: 0.1)) {
                    showTracks.toggle()
                }
            } label: {
                Image(systemName: "chevron.right")
                    .rotationEffect(showTracks ? .degrees(90) : .zero)
            }
            .buttonStyle(.borderless)
        }

        @ViewBuilder
        var tracksView: some View {
            if showTracks {
                ForEach(document.tracks) {
                    TrackView(documentStorage: documentStorage, padding: padding + 1, track: $0)
                }
                .transition(.move(edge: .top).combined(with: .opacity))
            }
        }
    }
}
