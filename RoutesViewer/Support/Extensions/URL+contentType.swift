//
//  URL+contentType.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 13.01.2024.
//

import Foundation
import UniformTypeIdentifiers

extension URL {
    var contentType: UTType? {
        if let resourceValues = try? resourceValues(forKeys: [.contentTypeKey]), let contentType = resourceValues.contentType {
            return contentType
        } else if let contentType = UTType(filenameExtension: pathExtension) {
            return contentType
        } else {
            return nil
        }
    }
}
