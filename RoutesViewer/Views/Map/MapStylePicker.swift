//
//  MapStylePicker.swift
//  GPXViewer
//
//  Created by Ivan Ushakov on 08.01.2024.
//

import Foundation
import SwiftUI
import MapKit

enum MapStylePicker: Hashable, CaseIterable, Identifiable {
    case standard
    case imagery
    case hybrid

    var id: Self {
        return self
    }

    var title: String {
        switch self {
        case .standard: "Standard"
        case .imagery: "Satellite"
        case .hybrid: "Hybrid"
        }
    }

    var mapStyle: MapStyle {
        switch self {
        case .standard: .standard
        case .imagery: .imagery
        case .hybrid: .hybrid
        }
    }
}
