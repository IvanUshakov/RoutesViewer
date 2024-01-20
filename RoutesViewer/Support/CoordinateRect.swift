//
//  CoordinateRect.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 13.01.2024.
//

import Foundation
import CoreLocation

struct CoordinateRect {
    var topLeftCoordinate: CLLocationCoordinate2D
    var bottomRightCoordinate: CLLocationCoordinate2D

    var center: CLLocationCoordinate2D {
        return .init(
            latitude: topLeftCoordinate.latitude + (bottomRightCoordinate.latitude - topLeftCoordinate.latitude) / 2,
            longitude: topLeftCoordinate.longitude + (bottomRightCoordinate.longitude - topLeftCoordinate.longitude) / 2
        )
    }

    init(topLeftCoordinate: CLLocationCoordinate2D, bottomRightCoordinate: CLLocationCoordinate2D) {
        self.topLeftCoordinate = topLeftCoordinate
        self.bottomRightCoordinate = bottomRightCoordinate
    }

    mutating func extend(location: CLLocationCoordinate2D) {
        if location.latitude < topLeftCoordinate.latitude {
            topLeftCoordinate.latitude = location.latitude
        } else if location.latitude > bottomRightCoordinate.latitude {
            bottomRightCoordinate.latitude = location.latitude
        }

        if location.longitude < topLeftCoordinate.longitude {
            topLeftCoordinate.longitude = location.longitude
        } else if location.longitude > bottomRightCoordinate.longitude {
            bottomRightCoordinate.longitude = location.longitude
        }
    }
}
