//
//  Sequence.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 20.01.2024.
//

import Foundation

extension Sequence {
    /// Returns the first element in `self` that `transform` maps to a `.some`.
    func firstNonNil<Result>(_ transform: (Element) throws -> Result?) rethrows -> Result? {
        for value in self {
            if let value = try transform(value) {
                return value
            }
        }

        return nil
    }

    /// Returns the first element in `self` that `transform` maps to a `.some`.
    func lastNonNil<Result>(_ transform: (Element) throws -> Result?) rethrows -> Result? {
        for value in self.lazy.reversed() {
            if let value = try transform(value) {
                return value
            }
        }

        return nil
    }

    /// Returns the result of combining the elements of the sequence using the
    /// given closure.
    func reduce<Result>(_ initialResult: Result, _ nextPartialResult: (_ result: Result, _ element: Element, _ stop: inout Bool) throws -> Result) rethrows -> Result {
        var result = initialResult
        var stop = false
        for value in self {
            result = try nextPartialResult(result, value, &stop)
            if stop {
                return result
            }
        }
        return result
    }

    /// Returns the result of combining the elements of the sequence using the
    /// given closure.
    func reduce<Result>(into initialResult: Result, _ updateAccumulatingResult: (_ result: inout Result, _ element: Element, _ stop: inout Bool) throws -> ()) rethrows -> Result {
        var result = initialResult
        var stop = false
        for value in self {
            try updateAccumulatingResult(&result, value, &stop)
            if stop {
                return result
            }
        }
        return result
    }

}
