//
//  TrackPoint.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 28.01.2024.
//

import Foundation
import CoreLocation
import CoreGPX

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
