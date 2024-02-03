//
//  TileServer.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 20.01.2024.
//

import Foundation
import MapKit

struct TileServer: Hashable {
    let id: UUID
    let name: String
    let templateUrl: String
    let subdomains: [String]
    let maximumZ: Int
    let minimumZ: Int

    // Standart map styles
    let mapConfiguration: MKMapConfiguration?

    static var allCases = [
        Self.appleStandard,
        Self.appleImagery,
        Self.appleHybrid,
        Self.openStreetMap,
        Self.openTopoMap,
        Self.openTopoMapCZ
    ]

    static let appleStandard: Self = .init(
        id: .init(),
        name: "Apple Mapkit Standard",
        templateUrl: "",
        subdomains: [],
        maximumZ: 0,
        minimumZ: 0,
        mapConfiguration: MKStandardMapConfiguration(elevationStyle: .flat, emphasisStyle: .default)
    )

    static let appleImagery: Self = .init(
        id: .init(),
        name: "Apple Mapkit Imagery",
        templateUrl: "",
        subdomains: [],
        maximumZ: 0,
        minimumZ: 0,
        mapConfiguration: MKImageryMapConfiguration(elevationStyle: .flat)
    )

    static let appleHybrid: Self = .init(
        id: .init(),
        name: "Apple Mapkit Hybrid",
        templateUrl: "",
        subdomains: [],
        maximumZ: 0,
        minimumZ: 0,
        mapConfiguration: MKHybridMapConfiguration(elevationStyle: .flat)
    )

    static let openStreetMap: Self = .init(
        id: .init(),
        name: "Open Street Map",
        templateUrl: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
        subdomains: ["a", "b", "c"],
        maximumZ: 19,
        minimumZ: 0,
        mapConfiguration: nil
    )

    static let openTopoMap: Self = .init(
        id: .init(),
        name: "OpenTopoMap",
        templateUrl: "https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png",
        subdomains: ["a", "b", "c"],
        maximumZ: 17,
        minimumZ: 0,
        mapConfiguration: nil
    )

    static let openTopoMapCZ: Self = .init(
        id: .init(),
        name: "OpenTopoMap CZ",
        templateUrl: "https://tile-a.opentopomap.cz/{z}/{x}/{y}.png",
        subdomains: ["a", "b", "c", "d"],
        maximumZ: 18,
        minimumZ: 1,
        mapConfiguration: nil
    )
}
