//
//  TileServer.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 20.01.2024.
//

import Foundation
import MapKit

struct TileServer: Hashable, Identifiable, Codable {
    var id: Int
    var name: String
    var templateUrl: String
    var subdomains: [String]
    var maximumZ: Int
    var minimumZ: Int

    // Standart map styles
    var mapConfiguration: MKMapConfiguration? {
        if id == Self.appleStandard.id {
            return MKStandardMapConfiguration(elevationStyle: .flat, emphasisStyle: .default)
        } else if id == Self.appleImagery.id {
            return MKImageryMapConfiguration(elevationStyle: .flat)
        } else if id == Self.appleHybrid.id {
            return MKHybridMapConfiguration(elevationStyle: .flat)
        } else {
            return nil
        }
    }
}

extension TileServer {
    static var allCases = [
        Self.appleStandard,
        Self.appleImagery,
        Self.appleHybrid,
        Self.openStreetMap,
        Self.openTopoMap,
        Self.openTopoMapCZ
    ]

    static let appleStandard: Self = .init(
        id: 0,
        name: "Apple Mapkit Standard",
        templateUrl: "",
        subdomains: [],
        maximumZ: 0,
        minimumZ: 0
    )

    static let appleImagery: Self = .init(
        id: 1,
        name: "Apple Mapkit Imagery",
        templateUrl: "",
        subdomains: [],
        maximumZ: 0,
        minimumZ: 0
    )

    static let appleHybrid: Self = .init(
        id: 2,
        name: "Apple Mapkit Hybrid",
        templateUrl: "",
        subdomains: [],
        maximumZ: 0,
        minimumZ: 0
    )

    static let openStreetMap: Self = .init(
        id: 3,
        name: "Open Street Map",
        templateUrl: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
        subdomains: ["a", "b", "c"],
        maximumZ: 19,
        minimumZ: 0
    )

    static let openTopoMap: Self = .init(
        id: 4,
        name: "OpenTopoMap",
        templateUrl: "https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png",
        subdomains: ["a", "b", "c"],
        maximumZ: 17,
        minimumZ: 0
    )

    static let openTopoMapCZ: Self = .init(
        id: 5,
        name: "OpenTopoMap CZ",
        templateUrl: "https://tile-a.opentopomap.cz/{z}/{x}/{y}.png",
        subdomains: ["a", "b", "c", "d"],
        maximumZ: 18,
        minimumZ: 1
    )
}
