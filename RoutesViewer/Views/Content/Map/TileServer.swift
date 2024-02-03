//
//  TileServer.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 20.01.2024.
//

import Foundation
import MapKit

enum TileServer: CaseIterable {
    case appleStandard
    case appleImagery
    case appleHybrid
    case openStreetMap
    case openTopoMap
    case openTopoMapCZ

    var mapConfiguration: MKMapConfiguration? {
        switch self {
        case .appleStandard: MKStandardMapConfiguration(elevationStyle: .flat, emphasisStyle: .default)
        case .appleImagery: MKImageryMapConfiguration(elevationStyle: .flat)
        case .appleHybrid: MKHybridMapConfiguration(elevationStyle: .flat)
        default: nil
        }
    }

    var name: String {
        switch self {
        case .appleStandard: "Apple Mapkit Standard"
        case .appleImagery: "Apple Mapkit Imagery"
        case .appleHybrid: "Apple Mapkit Hybrid"
        case .openStreetMap: "Open Street Map"
        case .openTopoMap: "OpenTopoMap"
        case .openTopoMapCZ: "OpenTopoMap CZ"
        }
    }

    var templateUrl: String {
        switch self {
        case .appleStandard, .appleHybrid, .appleImagery: ""
        case .openStreetMap: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
        case .openTopoMap: "https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png"
        case .openTopoMapCZ: "https://tile-a.opentopomap.cz/{z}/{x}/{y}.png"
        }
    }

    var subdomains: [String] {
        switch self {
        case .appleStandard, .appleHybrid, .appleImagery: []
        case .openStreetMap: ["a", "b", "c"]
        case .openTopoMap: ["a", "b", "c"]
        case .openTopoMapCZ: ["a", "b", "c", "d"]
        }
    }

    var maximumZ: Int {
        switch self {
        case .appleStandard, .appleHybrid, .appleImagery: -1
        case .openStreetMap: 19
        case .openTopoMap: 17
        case .openTopoMapCZ: 18
        }
    }

    var minimumZ: Int {
        switch self {
        case .appleStandard, .appleHybrid, .appleImagery: 0
        case .openStreetMap: 0
        case .openTopoMap: 0
        case .openTopoMapCZ: 1
        }
    }
}
