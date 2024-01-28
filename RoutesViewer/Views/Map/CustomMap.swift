//
//  CustomMap.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 20.01.2024.
//

import Foundation
import Cocoa
import SwiftUI
import MapKit
import MapCache

@MainActor
class CustomCocoaMap: NSView {
    var mapView: MKMapView = .init()
    var cachedTileOverlay: CachedTileOverlay?
    var trackOverlay: GradientPolyline?
    var tileServerPopUpButton: NSPopUpButton = .init()

    var documentStorage: DocumentStorage

    var position = MapCameraPosition.userLocation(fallback: .automatic)
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

            let polyline = GradientPolyline(points: points, maxVelocity: selectedTrack.statistic.maxSpeed ?? 0)
            self.mapView.addOverlay(polyline, level: .aboveLabels)
            self.trackOverlay = polyline
            if let coordinateRect = selectedTrack.coordinateRect {
                self.mapView.setCamera(
                    .init(
                        lookingAtCenter: coordinateRect.center,
                        fromDistance: 30000,
                        pitch: 0,
                        heading: .zero
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

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension CustomCocoaMap {
    @objc func tileServerDidChange(_ sender: NSSegmentedControl) {
        self.tileServer = TileServer.allCases[sender.indexOfSelectedItem]
    }
}

extension CustomCocoaMap: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let overlay = overlay as? CachedTileOverlay {
            return mapView.mapCacheRenderer(forOverlay: overlay)
        }

        if let overlay = overlay as? GradientPolyline {
            let renderer = GradidentPolylineRenderer(gradientPolyline: overlay)
            let fillColor = (selectedTrack?.style.color).flatMap { NSColor(hue: $0.hueComponent, saturation: $0.saturationComponent, brightness: $0.brightnessComponent, alpha: 1) }
            renderer.lineCap = .round
            renderer.lineJoin = .round
            renderer.lineWidth = 10

            renderer.strokeColor = .black
            renderer.borderWidth = 2

            renderer.fillColor = fillColor
            renderer.arrowIcon = NSImage(named: "arrow")
            renderer.arrowIconDistance = 20
            renderer.alpha = selectedTrack?.style.color.alphaComponent ?? 1
            return renderer
        }

        return MKOverlayRenderer()
    }
}

extension CustomCocoaMap {

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

struct CustomMap: NSViewRepresentable {
    typealias NSViewType = CustomCocoaMap

    var documentStorage: DocumentStorage

    func makeNSView(context: Context) -> CustomCocoaMap {
        CustomCocoaMap(documentStorage: documentStorage)
    }

    func updateNSView(_ nsView: CustomCocoaMap, context: Context) {}
}
