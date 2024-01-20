//
//  SidebarTabBarItem.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 13.01.2024.
//

import Foundation

enum SidebarTabBarItem: Hashable, Identifiable, CaseIterable {
    case info
    case edit
    case statistic

    var id: Self {
        self
    }

    var icon: String {
        switch self {
        case .info: "info.square"
        case .edit: "square.and.pencil"
        case .statistic: "chart.xyaxis.line"
        }
    }
}
