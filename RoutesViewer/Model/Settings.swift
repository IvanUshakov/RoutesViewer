//
//  Settings.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 03.02.2024.
//

import Foundation
import Observation

@Observable
class Settings {
    @ObservationIgnored
    var tileServer: TileServer {
        get {
            access(keyPath: \.tileServer)
            return UserDefaults.standard.value(TileServer.self, forKey: "tileServer") ?? TileServer.appleStandard
        }
        set {
            withMutation(keyPath: \.tileServer) {
                UserDefaults.standard.set(encodable: newValue, forKey: "tileServer")
            }
        }
    }

    @ObservationIgnored
    var showTrackGradient: Bool {
        get {
            access(keyPath: \.showTrackGradient)
            return UserDefaults.standard.bool(forKey: "showTrackGradient")
        }
        set {
            withMutation(keyPath: \.showTrackGradient) {
                UserDefaults.standard.set(newValue, forKey: "showTrackGradient")
            }
        }
    }
}
