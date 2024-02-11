//
//  GradientPolyline.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 21.01.2024.
//

import Foundation
import MapKit

class GradientPolyline: NSObject, MKOverlay {
    let coordinate: CLLocationCoordinate2D
    let boundingMapRect: MKMapRect

    static let maxHue = 0.25
    static let minHue = 0.0

    var points: [InternalPoint] = []

    init(points: [Point], maxVelocity: Double, minVelocity: Double = 0) {
        let hueRange = (Self.maxHue - Self.minHue)
        let velocityRange = (maxVelocity - minVelocity)
        self.points = points.map {
            .init(
                coordinates: .init($0.coordinates),
                hue: CGFloat(Self.minHue + (($0.velocity - minVelocity) * hueRange) / velocityRange)
            )
        }
        
        self.boundingMapRect = .world // TODO: fix
        self.coordinate = .init(latitude: 0, longitude: 0) // TODO: fix

        super.init()
    }
}

extension GradientPolyline {
    struct Point {
        let coordinates: CLLocationCoordinate2D
        let velocity: Double
    }

    struct InternalPoint {
        let coordinates: MKMapPoint
        let hue: CGFloat
    }
}

