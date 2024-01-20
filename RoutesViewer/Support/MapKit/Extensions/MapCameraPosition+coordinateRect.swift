//
//  MapCameraPosition+coordinateRect.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 13.01.2024.
//

import SwiftUI
import MapKit

extension MapCameraPosition {
    static func coordinateRect(_ coordinateRect: CoordinateRect) -> MapCameraPosition {
        MapCameraPosition.region(
            .init(
                center: coordinateRect.center,
                span: .init(
                    latitudeDelta: coordinateRect.center.latitude - coordinateRect.topLeftCoordinate.latitude,
                    longitudeDelta: coordinateRect.center.longitude - coordinateRect.topLeftCoordinate.longitude
                )
            )
        )
    }
}
