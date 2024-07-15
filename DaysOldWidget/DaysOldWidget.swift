//
//  DaysOldWidget.swift
//  DaysOldWidget
//
//  Created by Glen Brixey on 7/14/24.
//

import WidgetKit
import SwiftUI

struct DaysOldProvider: TimelineProvider {
    func placeholder(in context: Context) -> DaysOldEntry {
        DaysOldEntry(date: .now, daysSinceBirthdate: 12345)
    }

    func getSnapshot(in context: Context, completion: @escaping (DaysOldEntry) -> ()) {
        let entry = DaysOldEntry(date: .now, daysSinceBirthdate: daysSinceBirthdate ?? 10958)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let entry = DaysOldEntry(date: .now, daysSinceBirthdate: daysSinceBirthdate)
        let calendar = Calendar.autoupdatingCurrent
        let nextUpdateDate = calendar
            .date(byAdding: .day, value: 1, to: .now, wrappingComponents: true)!
            .movingToBeginningOfDay(with: calendar)
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
        completion(timeline)
    }

    private var daysSinceBirthdate: Int? {
        KeychainHelper.live.fetchBirthdate()?.daysBefore(.now)
    }
}

struct DaysOldEntry: TimelineEntry {
    let date: Date
    let daysSinceBirthdate: Int?
}

struct DaysOldWidgetEntryView : View {
    var entry: DaysOldProvider.Entry

    var body: some View {
        VStack(spacing: 4) {
            if let daysSinceBirthdate = entry.daysSinceBirthdate {
                Text("days.old.prefix")
                    .font(.system(size: 16))
                Text(daysSinceBirthdate, format: .number)
                    .font(.system(size: 24, weight: .semibold))
                Text(daysSinceBirthdate == 1 ? "days.old.suffix.singular" : "days.old.suffix.plural")
                    .font(.system(size: 16))
            } else {
                Text("tap.to.set.up")
            }
        }
    }
}

struct DaysOldWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "DaysOldWidget", provider: DaysOldProvider()) { entry in
            DaysOldWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("configuration.display.name")
        .description("configuration.description")
        .supportedFamilies([.systemSmall])
    }
}

#Preview(as: .systemSmall) {
    DaysOldWidget()
} timeline: {
    DaysOldEntry(date: .now, daysSinceBirthdate: 12345)
}
