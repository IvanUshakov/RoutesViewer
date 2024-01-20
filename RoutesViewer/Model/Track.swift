//
//  Track.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 13.01.2024.
//

import Foundation
import CoreLocation
import MapKit
import CoreGPX
import SwiftUI

/*
 <gpx_style:line>
 <color>ff6251</color>
 <opacity>0.16</opacity>
 <weight>9</weight>
 </gpx_style:line>
 */
@Observable
class TrackStyle {
    var weight: Double

    static let defaultColors: [UInt64] = [
        0xFF3355, 0xFF33BB, 0xDD33FF, 0x7733FF, 0x3355FF, 0x33BBFF,
        0x33FFDD, 0x33FF77, 0x55FF33, 0xBBFF33, 0xFFDD33, 0xFF9933
    ]

    init() {
        let rgb = Self.defaultColors.randomElement() ?? 0xF7D4D4
        self.weight = 4
        self.cgColor = CGColor(
                red: Double((rgb & 0xff0000) >> 16) / 0xff,
                green: Double((rgb & 0xff00) >> 8) / 0xff,
                blue: Double(rgb & 0xff) / 0xff,
                alpha: 0.8
            )
    }

    init(rgb: UInt64, opacity: Double, weight: Double) {
        self.weight = weight
        self.cgColor = CGColor(
            red: Double((rgb & 0xff0000) >> 16) / 0xff,
            green: Double((rgb & 0xff00) >> 8) / 0xff,
            blue: Double(rgb & 0xff) / 0xff,
            alpha: opacity
        )
    }

    var cgColor: CGColor
}

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

struct TrackPoint {
    var coordinate: CLLocationCoordinate2D
    var elevation: Double?
    var speed: Double?
    var date: Date?
}

extension TrackPoint {
    init?(gpxPoint: GPXTrackPoint) {
        guard let latitude = gpxPoint.latitude, let longitude = gpxPoint.longitude else {
            return nil
        }

        self.init(
            coordinate: .init(latitude: latitude, longitude: longitude),
            elevation: gpxPoint.elevation,
            speed: gpxPoint.extensions?["gom:speed"].text.flatMap { Double($0) },
            date: gpxPoint.time
        )
    }
}
