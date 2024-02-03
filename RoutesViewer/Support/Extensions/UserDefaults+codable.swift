//
//  UserDefaults+codable.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 03.02.2024.
//

import Foundation

extension UserDefaults {
    func set<T: Encodable>(encodable: T, forKey key: String) {
        if let data = try? JSONEncoder().encode(encodable) {
            set(data, forKey: key)
        }
    }

    func value<T: Decodable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = object(forKey: key) as? Data else { return nil }
        guard let value = try? JSONDecoder().decode(type, from: data) else { return nil }
        return value
    }
}
