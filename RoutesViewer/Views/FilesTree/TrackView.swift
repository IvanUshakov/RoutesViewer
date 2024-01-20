//
//  TrackView.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 14.01.2024.
//

import SwiftUI

extension FilesTree {
    struct TrackView: View {
        var documentStorage: DocumentStorage
        var padding: CGFloat
        @Bindable var track: Track

        @State private var editTrackName: Bool = false
        @FocusState private var focusState

        var body: some View {
            trackLabelView
                .padding(vertical: .xsmall)
                .padding(.leading, PaddingStyle.normal.rawValue * padding)
                .contentShape(Rectangle())
                .foregroundColor(documentStorage.selectedTrack === track ? Color.white : nil)
                .background {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.accentColor)
                        .opacity(documentStorage.selectedTrack === track ? 0.8 : 0)
                }
                .gesture(tapGesture)
                .onChange(of: focusState) {
                    editTrackName = focusState
                }
        }

        var trackLabelView: some View {
            Label {
                if editTrackName {
                    editNameTexfield
                } else {
                    Text(track.name)
                }
            } icon: {
                Image(systemName: "figure.walk")
            }
            .font(.system(.body, weight: .regular))
            .lineLimit(1)
            .frame(maxWidth: .infinity, alignment: .leading)
        }

        var editNameTexfield: some View {
            TextField("Name", text: $track.name)
                .focused($focusState)
                .onSubmit {
                    focusState = false
                }
                .onExitCommand {
                    focusState = false
                }
                .textFieldStyle(.plain)
        }

        var tapGesture: some Gesture {
            if documentStorage.selectedTrack === track {
                TapGesture(count: 2).onEnded {
                    editTrackName = true
                    focusState = true
                }
            } else {
                TapGesture(count: 1).onEnded {
                    removeFocus()
                    documentStorage.selectedTrack = track
                }
            }
        }
    }

}

