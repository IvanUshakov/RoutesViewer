//
//  CLLocationCoordinate2D+distance.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 04.02.2024.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D {

    static let earthRadius: Double = 6_371_000 // in m
    func distance(to: CLLocationCoordinate2D) -> Double {
        func haversin(_ angle: Double) -> Double {
            return (1 - cos(angle)) / 2
        }

        func ahaversin(_ angle: Double) -> Double {
            return 2 * asin(sqrt(angle))
        }

        func degreesToRadians(_ angle: Double) -> Double {
            return (angle / 360) * 2 * .pi
        }

        let lat1 = degreesToRadians(self.latitude)
        let lon1 = degreesToRadians(self.longitude)
        let lat2 = degreesToRadians(to.latitude)
        let lon2 = degreesToRadians(to.longitude)

        return Self.earthRadius * ahaversin(haversin(lat2 - lat1) + cos(lat1) * cos(lat2) * haversin(lon2 - lon1))
    }
}
