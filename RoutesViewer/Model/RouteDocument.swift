//
//  RouteDocument.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 13.01.2024.
//

import Foundation
import CoreGPX
import Observation

@Observable
final class RouteDocument {
    let url: URL?
    let gpxRoot: GPXRoot
    var tracks: [Track] = []

    var name: String {
        url?.lastPathComponent ?? "unknown"
    }

    var isoDateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
        return formatter
    }()

    convenience init(url: URL) throws {
        let data = try Data(contentsOf: url)

        guard let root = GPXParser(withData: data).parsedData() else {
            throw CocoaError(.fileReadCorruptFile)
        }

        self.init(url: url, gpxRoot: root)
    }

    init(url: URL? = nil, gpxRoot: GPXRoot = .init()) {
        self.url = url
        self.gpxRoot = gpxRoot

        self.tracks = gpxRoot.tracks.map { Track(track: $0) }
        self.tracks.forEach { $0.document = self }
    }
}

extension RouteDocument: Identifiable {}
