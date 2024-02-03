//
//  TrackStyle.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 28.01.2024.
//

import Foundation
import Cocoa

/*
 <gpx_style:line>
 <color>ff6251</color>
 <opacity>0.16</opacity>
 <weight>9</weight>
 </gpx_style:line>
 */
@Observable
class TrackStyle {
    var weight: Double
    var color: NSColor

    init() {
        self.weight = 8
        self.color = ColorPalate.shared.color()
    }
}
