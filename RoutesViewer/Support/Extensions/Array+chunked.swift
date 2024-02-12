//
//  Array+chunked.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 28.01.2024.
//

import Foundation

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}
