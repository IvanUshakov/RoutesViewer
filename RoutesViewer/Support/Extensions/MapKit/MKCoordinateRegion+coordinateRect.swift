//
//  MKCoordinateRegion+coordinateRect.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 13.01.2024.
//

import SwiftUI
import MapKit

extension MKCoordinateRegion {
    init(from coordinateRect: CoordinateRect) {
        self.init(
            center: coordinateRect.center,
            latitudinalMeters: coordinateRect.bottomRightCoordinate.distance(to: coordinateRect.topLeftCoordinate),
            longitudinalMeters: coordinateRect.bottomRightCoordinate.distance(to: coordinateRect.topLeftCoordinate)
        )
    }
}
