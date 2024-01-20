//
//  Statistic.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 20.01.2024.
//

import Foundation

struct Statistic {
    var points: [Statistic.Point]
    var distance: Double

    var time: TimeInterval?
    var timeInMove: TimeInterval?
    var timeInPlace: TimeInterval?

    var maxSpeed: Double?
    var meenSpeed: Double?
    var medianSpeed: Double?

    var meenSpeedInMove: Double?
    var medianSpeedInMove: Double?
    var percentile25InMooveSpeed: Double?
    var percentile75InMooveSpeed: Double?

    var minElevation: Double?
    var maxElevation: Double?
}

extension Statistic {
    struct Point {
        /// Original track point
        var trackPoint: TrackPoint
        /// Distance from prev track point
        var distance: Double
        /// Sum distance from start of the track
        var sumDistance: Double
    }
}
