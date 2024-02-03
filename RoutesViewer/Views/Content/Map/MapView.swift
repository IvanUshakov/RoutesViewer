//
//  MapView.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 20.01.2024.
//

import Foundation
import Cocoa
import MapKit
import MapCache

@MainActor
class MapView: NSView {
    var mapView: MKMapView = .init()
    var cachedTileOverlay: CachedTileOverlay?
    var trackOverlay: GradientPolyline?
    var trackOverlayRenderer: GradidentPolylineRenderer?
    var tileServerPopUpButton: NSPopUpButton = .init()

    var documentStorage: DocumentStorage

    var tileServer: TileServer = .openTopoMapCZ {
        didSet {
            updateTileServer()
        }
    }

    var selectedTrack: Track?

    init(documentStorage: DocumentStorage) {
        self.documentStorage = documentStorage
        super.init(frame: .zero)
        addMapView()
        addTileServerPopUpButton()

        renderCurrentTrack()
    }

    private func renderCurrentTrack() {
        withObservationTracking {
            guard self.selectedTrack?.id != documentStorage.selectedTrack?.id else {
                let weight = (selectedTrack?.style.weight).flatMap { CGFloat($0) } ?? 8
                self.trackOverlayRenderer?.fillColor = selectedTrack?.style.color
                self.trackOverlayRenderer?.lineWidth = weight
                self.trackOverlayRenderer?.arrowIconDistance = 3 * weight
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

extension MapView {
    @objc func tileServerDidChange(_ sender: NSSegmentedControl) {
        self.tileServer = TileServer.allCases[sender.indexOfSelectedItem]
    }
}

extension MapView: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? CachedTileOverlay {
            return mapView.mapCacheRenderer(forOverlay: overlay)
        }

        if let overlay = overlay as? GradientPolyline {
            let renderer = trackOverlayRenderer ?? .init(gradientPolyline: overlay)
            self.trackOverlayRenderer = renderer
            let fillColor = (selectedTrack?.style.color).flatMap { NSColor(hue: $0.hueComponent, saturation: $0.saturationComponent, brightness: $0.brightnessComponent, alpha: 1) }
            renderer.lineCap = .round
            renderer.lineJoin = .round
            renderer.lineWidth = (selectedTrack?.style.weight).flatMap { CGFloat($0) } ?? 8
            renderer.fillColor = fillColor

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

        updateTileServer()
    }

    func updateTileServer() {
        if let cachedTileOverlay {
            mapView.removeOverlay(cachedTileOverlay)
        }

        if let mapConfiguration = tileServer.mapConfiguration {
            mapView.preferredConfiguration = mapConfiguration
        } else {
            let mapCache = MapCache(withConfig: mapCacheConfig(from: tileServer))
            cachedTileOverlay = mapView.useCache(mapCache)
        }
    }

    func addTileServerPopUpButton() {
        tileServerPopUpButton.frame = NSRect(x: 8, y: 8, width: 145, height: 25)
        for server in TileServer.allCases {
            tileServerPopUpButton.addItem(withTitle: server.name)
        }
        tileServerPopUpButton.selectItem(at: TileServer.allCases.firstIndex(of: tileServer) ?? 0)
        tileServerPopUpButton.wantsLayer = true
        tileServerPopUpButton.layer?.opacity = 0.8
        tileServerPopUpButton.target = self
        tileServerPopUpButton.action = #selector(tileServerDidChange(_:))
        self.addSubview(tileServerPopUpButton)
    }

    func mapCacheConfig(from tileServer: TileServer) -> MapCacheConfig {
        var config = MapCacheConfig(withUrlTemplate: tileServer.templateUrl)
        config.minimumZ = tileServer.minimumZ
        config.maximumZ = tileServer.maximumZ
        config.subdomains = tileServer.subdomains
        config.cacheName = tileServer.name
        return config
    }

}
