//
//  TileOverlayRenderer.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 03.02.2024.
//

import Foundation
import MapKit

class TileOverlayRenderer: MKTileOverlayRenderer {

    let tileOverlay: TileOverlay

    init(overlay: TileOverlay) {
        self.tileOverlay = overlay
        super.init(overlay: overlay)
    }

    override func canDraw(_ mapRect: MKMapRect, zoomScale: MKZoomScale) -> Bool {
        super.canDraw(mapRect, zoomScale: zoomScale)
    }

    override func draw(_ mapRect: MKMapRect, zoomScale: MKZoomScale, in context: CGContext) {
        super.draw(mapRect, zoomScale: zoomScale, in: context)
    }
}
