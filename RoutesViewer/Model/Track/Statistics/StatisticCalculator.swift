//
//  StatisticCalculator.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 19.01.2024.
//

import Foundation
import CoreLocation

class StatisticCalculator {
    func calculate(for track: [TrackPoint]) -> Statistic {
        let statisticPoints = self.statisticPoints(for: track)
        let statisticPointsSortedBySpeed = statisticPoints.sorted { $0.trackPoint.speed ?? 0 < $1.trackPoint.speed ?? 0 }
        let statisticPointsInMove = statisticPoints.filter { self.isInMove(speed: $0.trackPoint.speed) }
        let statisticPointsInMoveSortedBySpeed = statisticPointsInMove.sorted { $0.trackPoint.speed ?? 0 < $1.trackPoint.speed ?? 0 }

        let distance = distance(from: statisticPoints)
        let time = trackTime(from: statisticPoints)
        let timeInMove = self.timeInMove(from: statisticPoints)

        return .init(
            points: statisticPoints,
            distance: distance,
            time: trackTime(from: statisticPoints),
            timeInMove: timeInMove,
            timeInPlace: timeInPlace(time: time, timeInMove: timeInMove),
            maxSpeed: maxSpeed(from: statisticPointsInMoveSortedBySpeed),
            meenSpeed: meenSpeed(from: statisticPoints),
            medianSpeed: medianSpeed(from: statisticPointsSortedBySpeed, distance: distance),
            meenSpeedInMove: meenSpeedInMove(from: statisticPointsInMove),
            medianSpeedInMove: medianSpeedInMove(from: statisticPointsInMoveSortedBySpeed, distance: distance),
            percentile25InMooveSpeed: percentile25InMooveSpeed(from: statisticPointsInMoveSortedBySpeed, distance: distance),
            percentile75InMooveSpeed: percentile75InMooveSpeed(from: statisticPointsInMoveSortedBySpeed, distance: distance),
            minElevation: minElevation(from: statisticPoints),
            maxElevation: maxElevation(from: statisticPoints)
        )
    }
}

private extension StatisticCalculator {
    func trackTime(from points: [Statistic.Point]) -> TimeInterval? {
        guard let startTime = points.firstNonNil({ $0.trackPoint.date }) else { return nil }
        guard let endTime = points.lastNonNil({ $0.trackPoint.date }) else { return nil }
        return endTime.timeIntervalSince(startTime)
    }

    func timeInMove(from points: [Statistic.Point]) -> TimeInterval? {
        let result: (sum: TimeInterval, prev: Date?) = points.reduce(into: (0, nil)) { partialResult, point in
            defer {
                partialResult.prev = point.trackPoint.date
            }

            guard let prev = partialResult.prev, let current = point.trackPoint.date, self.isInMove(speed: point.trackPoint.speed) else { return }
            partialResult.sum += current.timeIntervalSince(prev)
        }

        return result.sum
    }

    func timeInPlace(time: TimeInterval?, timeInMove: TimeInterval?) -> TimeInterval? {
        guard let time, let timeInMove else { return nil }
        return time - timeInMove
    }

    func distance(from points: [Statistic.Point]) -> Double {
        points.last?.sumDistance ?? 0
    }

    func maxSpeed(from points: [Statistic.Point]) -> Double? {
        points.lastNonNil { $0.trackPoint.speed }
    }

    func meenSpeed(from points: [Statistic.Point]) -> Double? {
        meen(elements: points, keyPath: \.trackPoint.speed)
    }

    func medianSpeed(from points: [Statistic.Point], distance: Double) -> Double? {
        percentile(elements: points, sum: distance, percentile: 0.5, keyPath: \.trackPoint.speed)
    }

    func meenSpeedInMove(from points: [Statistic.Point]) -> Double? {
        meen(elements: points, keyPath: \.trackPoint.speed)
    }

    func medianSpeedInMove(from points: [Statistic.Point], distance: Double) -> Double? {
        percentile(elements: points, sum: distance, percentile: 0.5, keyPath: \.trackPoint.speed)
    }

    func percentile25InMooveSpeed(from points: [Statistic.Point], distance: Double) -> Double? {
        percentile(elements: points, sum: distance, percentile: 0.25, keyPath: \.trackPoint.speed)
    }

    func percentile75InMooveSpeed(from points: [Statistic.Point], distance: Double) -> Double? {
        percentile(elements: points, sum: distance, percentile: 0.75, keyPath: \.trackPoint.speed)
    }

    func maxElevation(from points: [Statistic.Point]) -> Double? {
        max(elements: points, keyPath: \.trackPoint.elevation)
    }

    func minElevation(from points: [Statistic.Point]) -> Double? {
        min(elements: points, keyPath: \.trackPoint.elevation)
    }
}

private extension StatisticCalculator {
    func statisticPoints(for track: [TrackPoint]) -> [Statistic.Point] {
        var prevPoint: TrackPoint?
        var sumDistance: Double = 0
        var statisticPoints: [Statistic.Point] = []
        for point in track {
            defer {
                prevPoint = point
            }

            guard let prev = prevPoint else {
                statisticPoints.append(.init(trackPoint: point, distance: 0, sumDistance: 0))
                continue
            }

            let distance = prev.coordinate.distance(to: point.coordinate)
            sumDistance += distance
            statisticPoints.append(.init(trackPoint: point, distance: distance, sumDistance: sumDistance))
        }
        return statisticPoints
    }

    func max<T>(elements: [Statistic.Point], keyPath: KeyPath<Statistic.Point, T?>) -> T? where T: Comparable {
        elements.reduce(nil) { result, element in
            guard let element = element[keyPath: keyPath] else { return result }
            guard let result = result else { return element }
            return result > element ? result : element
        }
    }

    func min<T>(elements: [Statistic.Point], keyPath: KeyPath<Statistic.Point, T?>) -> T? where T: Comparable {
        elements.reduce(nil) { result, element in
            guard let element = element[keyPath: keyPath] else { return result }
            guard let result = result else { return element }
            return result < element ? result : element
        }
    }

    func meen(elements: [Statistic.Point], keyPath: KeyPath<Statistic.Point, Double?>) -> Double? {
        guard elements.count > 0 else {
            return nil
        }

        return elements.reduce(0) { $0 + ($1[keyPath: keyPath] ?? 0) } / Double(elements.count)
    }

    func percentile(elements: [Statistic.Point], sum: Double?, percentile: Double, keyPath: KeyPath<Statistic.Point, Double?>) -> Double? {
        guard !elements.isEmpty, let sum else { return nil }
        let mid = sum * percentile

        let (index, _): (index: Int?, partialSum: Double) = elements.enumerated().reduce(into: (nil, 0)) { result, element, stop in
            result.partialSum += element.element.distance
            if result.partialSum >= mid {
                result.index = element.offset
                stop = true
            }
        }

        guard let index else { return nil }
        if elements.count % 2 == 0 {
            guard let first = elements[index][keyPath: keyPath], let second = elements[index][keyPath: keyPath] else {
                return nil
            }
            return (first + second) / 2
        } else {
            return elements[index][keyPath: keyPath]
        }
    }

    func isInMove(speed: Double?) -> Bool {
        guard let speed = speed else { return false }
        return speed > 0.5
    }
}
