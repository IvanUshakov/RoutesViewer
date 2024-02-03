//
//  MKMapView+overlays.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 04.02.2024.
//

import Foundation
import MapKit

extension MKMapView {
    func insertOverlayBelowAll(overlay: MKOverlay, level: MKOverlayLevel) {
        if let firstOverlay = self.overlays(in: level).first {
            self.insertOverlay(overlay, below: firstOverlay)
        } else {
            self.addOverlay(overlay, level: .aboveLabels)
        }
    }
}
