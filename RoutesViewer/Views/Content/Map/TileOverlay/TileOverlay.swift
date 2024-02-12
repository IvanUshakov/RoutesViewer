//
//  TileOverlay.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 03.02.2024.
//

import Foundation
import MapKit

class TileOverlay: MKTileOverlay {
    var cache: NSCache<NSString, TileCacheElement>
    let tileServer: TileServer

    let subdomainLock = UnfairLock()
    var currentSubdomainIndex = 0

    init(tileServer: TileServer) {
        self.cache = .init()
        self.cache.totalCostLimit = 512 * 1024 * 1024
        self.tileServer = tileServer
        super.init(urlTemplate: tileServer.templateUrl)
        self.maximumZ = tileServer.maximumZ
        self.minimumZ = tileServer.minimumZ
        self.canReplaceMapContent = tileServer.canReplaceMapContent
    }

    override func loadTile(at path: MKTileOverlayPath, result: @escaping (Data?, Error?) -> Void) {
        guard let url = url(forTilePath: path) else {
            result(nil, TileOverlayError.invalidURL)
            return
        }

        if let cachedElement = cache.object(forKey: url.absoluteString as NSString) {
            print("Find chache for: \(url.absoluteString)")
            result(cachedElement.data, nil)
            return
        }

        loadFromNetwork(url: url) { [weak self] data, error in
            guard let self else { return }
            guard let data else {
                result(data, error)
                return
            }

            self.cache.setObject(.init(data: data), forKey: url.absoluteString as NSString, cost: data.count)
            print("Load from network: \(url.absoluteString)")
            result(data, error)
        }
    }

    // TODO: support to subdomains
    func url(forTilePath path: MKTileOverlayPath) -> URL? {
        let subdomain = nextSubdomain()
        var urlString = tileServer.templateUrl
        urlString = urlString.replacingOccurrences(of: "{s}", with: subdomain)
        urlString = urlString.replacingOccurrences(of: "{z}", with: String(path.z))
        urlString = urlString.replacingOccurrences(of: "{x}", with: String(path.x))
        urlString = urlString.replacingOccurrences(of: "{y}", with: String(path.y))
        return URL(string: urlString)
    }

    func nextSubdomain() -> String {
        guard !tileServer.subdomains.isEmpty else { return "" }
        return subdomainLock.around {
            let subdomain = tileServer.subdomains[self.currentSubdomainIndex]
            self.currentSubdomainIndex = (self.currentSubdomainIndex + 1) % tileServer.subdomains.count
            return subdomain
        }
    }

    func loadFromNetwork(url: URL, result: @escaping (Data?, Error?) -> Void) {
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            if let error {
                result(nil, error)
                return
            }

            guard let data = data else {
                result(nil, TileOverlayError.invalidData)
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                result(nil, TileOverlayError.invalidData)
                return
            }

            guard let contentType = httpResponse.value(forHTTPHeaderField: "Content-Type") else {
                result(nil, TileOverlayError.invalidData)
                return
            }

            guard Self.validContentTypes.contains(contentType) else {
                result(nil, TileOverlayError.invalidData)
                return
            }

            result(data, nil)
        }
        task.resume()
    }

    static var validContentTypes: Set<String> = [
        "image/png",
        "image/jpeg"
    ]
}
