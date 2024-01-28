//
//  Track.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 13.01.2024.
//

import Foundation
import MapKit
import CoreGPX

@Observable
final class Track: Identifiable {
    var id = UUID()

    weak var document: RouteDocument?

    var style: TrackStyle
    var name: String
    var desc: String
    var date: Date?

    var points: [TrackPoint]
    var coordinateRect: CoordinateRect?
    var statistic: Statistic

    init(track: GPXTrack) {
        let points = Self.points(from: track.segments)
        let coordinateRect = Self.coordinateRect(from: points.map(\.coordinate))

        self.name = track.name ?? ""
        self.desc = track.desc ?? ""
        self.style = .init()

        self.points = points
        self.coordinateRect = coordinateRect
        self.statistic = StatisticCalculator().calculate(for: points)
    }

    static func points(from segments: [GPXTrackSegment]) -> [TrackPoint] {
        segments
            .reduce(into: [GPXTrackPoint]()) {
                $0.append(contentsOf: $1.points)
            }
            .compactMap {
                .init(gpxPoint: $0)
            }
    }

    static func coordinateRect(from points: [CLLocationCoordinate2D]) -> CoordinateRect? {
        if points.count == 0 {
            return nil
        } else if points.count == 1 {
            return .init(topLeftCoordinate: points[0], bottomRightCoordinate: points[0])
        } else {
            return points.reduce(into: .init(topLeftCoordinate: points[0], bottomRightCoordinate: points[1])) {
                $0.extend(location: $1)
            }
        }
    }
}
