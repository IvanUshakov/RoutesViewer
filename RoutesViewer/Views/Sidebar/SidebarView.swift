//
//  SidebarView.swift
//  GPXViewer
//
//  Created by Ivan Ushakov on 08.01.2024.
//

import SwiftUI

struct SidebarView: View {
    var documentStorage: DocumentStorage

    var body: some View {
        ScrollView {
            VStack(spacing: .large) {
                editView
                statisticView
            }
        }
    }

    @ViewBuilder
    var editView: some View {
        if let track = documentStorage.selectedTrack {
            EditTrackMetadataView(track: track)
        }
    }

    @ViewBuilder
    var statisticView: some View {
        if let track = documentStorage.selectedTrack {
            VStack(spacing: .normal) {
                VStack(spacing: .normal) {
                    statisticItemView(title: "Time:", value: timeString(from: track.statistic.time))
                    statisticItemView(title: "Time in move:", value: timeString(from: track.statistic.timeInMove))
                    statisticItemView(title: "Time in place:", value: timeString(from: track.statistic.timeInPlace))
                    statisticItemView(title: "Distance:", value: distanceString(from: track.statistic.distance))
                }

                Divider()

                VStack(spacing: .normal) {
                    statisticItemView(title: "Max speed:", value: speedString(from: track.statistic.maxSpeed))
                    statisticItemView(title: "Meen speed:", value: speedString(from: track.statistic.meenSpeed))
                    statisticItemView(title: "Median speed:", value: speedString(from: track.statistic.medianSpeed))
                }

                Divider()

                VStack(spacing: .normal) {
                    statisticItemView(title: "Meen speed in move:", value: speedString(from: track.statistic.meenSpeedInMove))
                    statisticItemView(title: "25 percentile speed in move:", value: speedString(from: track.statistic.percentile25InMooveSpeed))
                    statisticItemView(title: "Median speed in move:", value: speedString(from: track.statistic.medianSpeedInMove))
                    statisticItemView(title: "75 percentile speed in move:", value: speedString(from: track.statistic.percentile75InMooveSpeed))
                }

                Divider()

                VStack(spacing: .normal) {
                    statisticItemView(title: "Min elevation:", value: elevationString(from: track.statistic.minElevation))
                    statisticItemView(title: "Max elevation:", value: elevationString(from: track.statistic.maxElevation))
                }
            }
        }
    }

    func statisticItemView(title: String, value: String) -> some View {
        VStack(spacing: .xsmall) {
            Text(title)
                .font(.system(.headline, weight: .medium))
                .textCase(.uppercase)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .center)

            Text(value)
                .font(.body)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }

    func speedString(from speed: Double?) -> String {
        guard let speed else { return "–" }
        return String(format: "%.1f km/h", speed * 3.6)
    }

    func elevationString(from elevation: Double?) -> String {
        guard let elevation else { return "–" }
        return String(format: "%.1f m", elevation)
    }

    func timeString(from timeInterval: TimeInterval?) -> String {
        guard let timeInterval else { return "–" }
        return Duration.seconds(timeInterval)
            .formatted()
    }

    func distanceString(from distance: Double?) -> String {
        guard let distance else { return "–" }
        return String(format: "%.1f km", distance / 1000)
    }
}

//#Preview {
//    SidebarView(document: .init())
//}
