//
//  EditTrackMetadataView.swift
//  GPXViewer
//
//  Created by Ivan Ushakov on 08.01.2024.
//

import SwiftUI

struct EditTrackMetadataView: View {
    @Bindable var track: Track
    @State var date: Date = Date()

    var body: some View {
        VStack(spacing: .small) {
            HStack {
                Text(track.name)
                    .font(.system(.title2, weight: .semibold))
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                Spacer(minLength: .small)

                ColorPicker(selection: $track.style.cgColor, supportsOpacity: true, label: {})
                    .labelsHidden()
            }

            if let date = track.date {
                EditTrackMetadataField(title: "Created at:", systemImage: "calendar") {
                    DatePicker("", selection: $date)
                        .labelsHidden()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .datePickerStyle(.field)
                        .textFieldStyle(.roundedBorder)
                }
            }

            VStack(spacing: .xsmall) {
                EditTrackMetadataField(title: "Track desc:", systemImage: "pencil.line") {
                    TextEditor(text: $track.desc)
                        .font(.system(size: 14))
                        .frame(height: 64)
                        .border(Color(nsColor: .gridColor))
                        .cornerRadius(4)
                }
            }
        }
        .padding(.small)
    }
}

struct EditTrackMetadataField<Content>: View where Content: View {
    var title: String
    var systemImage: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(spacing: .xsmall) {
            Label(title, systemImage: systemImage)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            content
        }
    }
}

struct EditTrackMetadataStringFieldView: View {
    var title: String
    var systemImage: String
    @Binding var text: String

    var body: some View {
        Label(title, systemImage: systemImage)
            .font(.system(.headline, weight: .semibold))
            .foregroundColor(.secondary)
            .frame(maxWidth: .infinity, alignment: .leading)

        TextField("Track name", text: $text)
            .textFieldStyle(.roundedBorder)
    }
}


//#Preview {
//    EditTrackMetadataView(document: .init())
//}
