//
//  GradientPolyline.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 21.01.2024.
//

import Foundation
import MapKit

class GradientPolyline: MKPolyline {
    static let maxHue = 0.25
    static let minHue = 0.0

    var hues: [CGFloat] = []

    convenience init(points: [Point], maxVelocity: Double, minVelocity: Double = 0) {
        let coordinates = points.map(\.coordinates)
        self.init(coordinates: coordinates, count: coordinates.count)

        let hueRange = (Self.maxHue - Self.minHue)
        let velocityRange = (maxVelocity - minVelocity)
        hues = points.map { CGFloat(Self.minHue + (($0.velocity - minVelocity) * hueRange) / velocityRange) }
    }
}

extension GradientPolyline {
    struct Point {
        let coordinates: CLLocationCoordinate2D
        let velocity: Double
    }
}

