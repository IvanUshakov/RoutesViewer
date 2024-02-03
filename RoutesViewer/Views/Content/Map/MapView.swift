//
//  MapView.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 20.01.2024.
//

import Foundation
import Cocoa
import MapKit

@MainActor
class MapView: NSView {
    var mapView: MKMapView = .init()
    
    var tileOverlay: TileOverlay?
    var tileOverlayRenderer: TileOverlayRenderer?

    var trackOverlay: GradientPolyline?
    var trackOverlayRenderer: GradidentPolylineRenderer?

    var documentStorage: DocumentStorage
    var settings: Settings
    var selectedTrack: Track?

    init(documentStorage: DocumentStorage, settings: Settings) {
        self.documentStorage = documentStorage
        self.settings = settings
        super.init(frame: .zero)
        addMapView()
        renderTileServer()
        renderCurrentTrack()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func renderTileServer() {
        withObservationTracking {
            if let tileOverlay {
                mapView.removeOverlay(tileOverlay)
                tileOverlayRenderer = nil
            }

            if let mapConfiguration = settings.tileServer.mapConfiguration {
                mapView.preferredConfiguration = mapConfiguration
                return
            }

            let tileOverlay = TileOverlay(tileServer: settings.tileServer)
            mapView.insertOverlayBelowAll(overlay: tileOverlay, level: .aboveLabels)
            self.tileOverlay = tileOverlay
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                self?.renderTileServer()
            }
        }
    }

    private func renderCurrentTrack() {
        withObservationTracking {
            guard self.selectedTrack?.id != documentStorage.selectedTrack?.id else {
                updateTrackStyle(selectedTrack?.style, renderer: trackOverlayRenderer)
                self.trackOverlayRenderer?.setNeedsDisplay(.world)
                return
            }

            if let trackOverlay {
                self.mapView.removeOverlay(trackOverlay)
                self.trackOverlayRenderer = nil
            }

            self.selectedTrack = documentStorage.selectedTrack
            guard let selectedTrack else { return }

            let polyline = gradientPolyline(from: selectedTrack)
            self.mapView.addOverlay(polyline, level: .aboveLabels)
            self.trackOverlay = polyline

            if let coordinateRect = selectedTrack.coordinateRect {
                self.mapView.setRegion(.init(from: coordinateRect), animated: false)
            }
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                self?.renderCurrentTrack()
            }
        }
    }

    func addMapView() {
        self.mapView.translatesAutoresizingMaskIntoConstraints = false
        self.mapView.delegate = self
        self.addSubview(mapView)
        self.addConstraints([
            self.topAnchor.constraint(equalTo: mapView.topAnchor),
            self.bottomAnchor.constraint(equalTo: mapView.bottomAnchor),
            self.leadingAnchor.constraint(equalTo: mapView.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: mapView.trailingAnchor)
        ])

        self.mapView.showsScale = true
        self.mapView.showsCompass = true
        self.mapView.showsZoomControls = true
        self.mapView.showsPitchControl = true
    }

    func gradientPolyline(from track: Track) -> GradientPolyline {
        let points = track.points.map {
            GradientPolyline.Point(coordinates: $0.coordinate, velocity: $0.speed ?? 0)
        }

        return GradientPolyline(points: points, maxVelocity: track.statistic.maxSpeed ?? 0)
    }

    func updateTrackStyle(_ trackStyle: TrackStyle?, renderer: GradidentPolylineRenderer?) {
        guard let trackStyle else { return }
        guard let renderer else { return }

        let fillColor = NSColor(
            hue: trackStyle.color.hueComponent,
            saturation: trackStyle.color.saturationComponent,
            brightness: trackStyle.color.brightnessComponent,
            alpha: 1
        )

        renderer.lineWidth = trackStyle.weight
        renderer.fillColor = fillColor
        renderer.drawGradient = settings.showTrackGradient

        renderer.strokeColor = .black
        renderer.borderWidth = 1
        renderer.drawBorder = true

        renderer.arrowIconDistance = 3 * renderer.lineWidth
        renderer.drawArrows = true
    }

}

extension MapView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? TileOverlay {
            if let tileOverlayRenderer { return tileOverlayRenderer }
            let tileOverlayRenderer = TileOverlayRenderer(overlay: overlay)
            self.tileOverlayRenderer = tileOverlayRenderer
            return tileOverlayRenderer
        }

        if let overlay = overlay as? GradientPolyline {
            if let trackOverlayRenderer { return trackOverlayRenderer }
            let renderer = GradidentPolylineRenderer(gradientPolyline: overlay)
            self.trackOverlayRenderer = renderer
            updateTrackStyle(selectedTrack?.style, renderer: renderer)
            return renderer
        }

        return MKOverlayRenderer()
    }
}
