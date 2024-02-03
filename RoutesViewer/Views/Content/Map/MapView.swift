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
            if let firstOverlay = mapView.overlays.first {
                mapView.insertOverlay(tileOverlay, below: firstOverlay)
            } else {
                mapView.addOverlay(tileOverlay, level: .aboveLabels)
            }
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
                let weight = (selectedTrack?.style.weight).flatMap { CGFloat($0) } ?? 8
                self.trackOverlayRenderer?.fillColor = selectedTrack?.style.color
                self.trackOverlayRenderer?.lineWidth = weight
                self.trackOverlayRenderer?.arrowIconDistance = 3 * weight
                self.trackOverlayRenderer?.drawGradient = settings.showTrackGradient
                self.trackOverlayRenderer?.setNeedsDisplay(.world)
                return
            }

            self.selectedTrack = documentStorage.selectedTrack
            guard let selectedTrack else {
                return
            }

            if let trackOverlay {
                self.mapView.removeOverlay(trackOverlay)
            }

            let points = selectedTrack.points.map {
                GradientPolyline.Point(coordinates: $0.coordinate, velocity: $0.speed ?? 0)
            }

            self.trackOverlayRenderer = nil
            let polyline = GradientPolyline(points: points, maxVelocity: selectedTrack.statistic.maxSpeed ?? 0)
            self.mapView.addOverlay(polyline, level: .aboveLabels)
            self.trackOverlay = polyline
            if let coordinateRect = selectedTrack.coordinateRect {
                self.mapView.setRegion(
                    .init(
                        center: coordinateRect.center,
                        latitudinalMeters: distance(from: coordinateRect.bottomRightCoordinate, to: coordinateRect.topLeftCoordinate),
                        longitudinalMeters: distance(from: coordinateRect.bottomRightCoordinate, to: coordinateRect.topLeftCoordinate)
                    ),
                    animated: false
                )
            }
        } onChange: { [weak self] in
            Task { @MainActor [weak self] in
                self?.renderCurrentTrack()
            }
        }
    }

    static let earthRadius: Double = 6_371_000 // in m
    func distance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, radius: Double = MapView.earthRadius) -> Double {
        func haversin(_ angle: Double) -> Double {
            return (1 - cos(angle)) / 2
        }

        func ahaversin(_ angle: Double) -> Double {
            return 2 * asin(sqrt(angle))
        }

        func degreesToRadians(_ angle: Double) -> Double {
            return (angle / 360) * 2 * .pi
        }

        let lat1 = degreesToRadians(from.latitude)
        let lon1 = degreesToRadians(from.longitude)
        let lat2 = degreesToRadians(to.latitude)
        let lon2 = degreesToRadians(to.longitude)

        return radius * ahaversin(haversin(lat2 - lat1) + cos(lat1) * cos(lat2) * haversin(lon2 - lon1))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension MapView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? TileOverlay {
            if let tileOverlayRenderer {
                return tileOverlayRenderer
            } else {
                let tileOverlayRenderer = TileOverlayRenderer(overlay: overlay)
                self.tileOverlayRenderer = tileOverlayRenderer
                return tileOverlayRenderer
            }
        }

        if let overlay = overlay as? GradientPolyline {
            let renderer = trackOverlayRenderer ?? .init(gradientPolyline: overlay)
            self.trackOverlayRenderer = renderer
            let fillColor = (selectedTrack?.style.color).flatMap { NSColor(hue: $0.hueComponent, saturation: $0.saturationComponent, brightness: $0.brightnessComponent, alpha: 1) }
            renderer.lineWidth = (selectedTrack?.style.weight).flatMap { CGFloat($0) } ?? 8
            renderer.fillColor = fillColor
            renderer.drawGradient = settings.showTrackGradient

            renderer.strokeColor = .black
            renderer.borderWidth = 1
            renderer.drawBorder = true

            renderer.arrowIconDistance = 3 * renderer.lineWidth
            renderer.drawArrows = true

            return renderer
        }

        return MKOverlayRenderer()
    }
}

extension MapView {

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
}
