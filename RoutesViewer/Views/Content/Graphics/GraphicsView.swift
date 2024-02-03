//
//  GraphicsView.swift
//  RoutesViewer
//
//  Created by Ivan Ushakov on 03.02.2024.
//

import SwiftUI
import Charts

struct GraphicsView: View {
    var documentStorage: DocumentStorage

    var body: some View {
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
                .frame(height: 200)
            }
        }
    }
}

#Preview {
    GraphicsView(documentStorage: .init())
}
