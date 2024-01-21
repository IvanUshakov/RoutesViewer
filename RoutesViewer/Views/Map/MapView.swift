//
//  MapView.swift
//  GPXViewer
//
//  Created by Ivan Ushakov on 08.01.2024.
//

import SwiftUI
import MapKit
import Charts

struct MapView: View {
    var documentStorage: DocumentStorage
    @State private var position = MapCameraPosition.userLocation(fallback: .automatic)
    @State private var mapStyle = MapStylePicker.hybrid

    @State private var selectedPoint: TrackPoint?

    var body: some View {
        VStack {
            CustomMap(documentStorage: documentStorage)
//            Map(position: $position) {
//                ForEach(documentStorage.selectedDocument?.tracks ?? []) { track in
//                    TrackMapContent(track: track)
//                }
//
//                if let selectedPoint {
//                    Annotation(coordinate: selectedPoint.coordinate) {
//                        Circle()
//                            .foregroundStyle(.red)
//                            .frame(width: 10)
//                    } label: {
//                        Circle()
//                            .foregroundStyle(.red)
//                            .frame(width: 10)
//                    }
//                }
//            }
//            .mapStyle(mapStyle.mapStyle)
//            .mapControls {
//                MapZoomStepper()
//                MapCompass()
//                MapScaleView()
//            }
//            .overlay(alignment: .bottomLeading) {
//                mapStylePickerView
//            }
            chartView
        }
        .onAppear {
            position = documentStorage.selectedTrack?.coordinateRect.flatMap { MapCameraPosition.coordinateRect($0) } ?? position
        }
    }

    var mapStylePickerView: some View {
        Picker("", selection: $mapStyle) {
            ForEach(MapStylePicker.allCases) { style in
                Text(style.title)
            }
        }
        .labelsHidden()
        .frame(width: 100)
        .padding(8)
    }

    var chartView: some View {
        HStack {
            if let statistic = documentStorage.selectedTrack?.statistic {
                Chart {
                    ForEach(statistic.points, id: \.sumDistance) { point in
                        LineMark(
                            x: .value("Distance", point.sumDistance),
                            y: .value("Speed", (point.trackPoint.speed ?? 0) * 3.6),
                            series: .value("", "Speed")
                        )
                        .foregroundStyle(.red)
                    }
                }
                .chartXScale(domain: 0...statistic.distance)
                .padding()
                .chartOverlay { proxy in
                    GeometryReader { geometry in
                        Rectangle().fill(.clear).contentShape(Rectangle())
//                            .gesture(
//                                DragGesture()
//                                    .onChanged { value in
//                                        // Convert the gesture location to the coordinate space of the plot area.
//                                        let origin = geometry[proxy.plotAreaFrame].origin
//                                        let location = value.location.x - origin.x
//                                        // Get the x (date) and y (price) value from the location.
//                                        guard let index = proxy.value(atX: location, as: (Int).self) else {
//                                            return
//                                        }
//                                        
//                                        guard index > points.startIndex && index < points.endIndex else {
//                                            return
//                                        }
//
//                                        self.selectedPoint = points[index]
//                                    }
//                            )
//                            .onTapGesture { value in
//                                let origin = geometry[proxy.plotAreaFrame].origin
//                                let location = value.x - origin.x
//                                // Get the x (date) and y (price) value from the location.
//                                guard let index = proxy.value(atX: location, as: (Int).self) else {
//                                    return
//                                }
//
//                                guard index > points.startIndex && index < points.endIndex else {
//                                    return
//                                }
//
//                                self.selectedPoint = points[index]
//                            }
                    }
                }
            }
        }
        .frame(height: 200)
    }
}

struct TrackMapContent: MapContent {
    let track: Track

    var body: some MapContent {
        MapPolyline(coordinates: track.points.map(\.coordinate))
            .stroke(Color(cgColor: track.style.cgColor), lineWidth: track.style.weight)
    }
}

#Preview {
    MapView(documentStorage: .init())
}
