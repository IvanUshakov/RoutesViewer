//
//  UTType+gpx.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 13.01.2024.
//

import Foundation
import UniformTypeIdentifiers

extension UTType {
    static var gpx: UTType {
        UTType(importedAs: "com.topografix.gpx")
    }
}
