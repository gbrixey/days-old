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
        let daysSinceBirthdate = calendar.daysBetween(date1: birthdate, date2: .now)
        let entry = DaysOldEntry(date: .now, daysSinceBirthdate: daysSinceBirthdate ?? 10958)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        guard let birthdate = birthdate,
              let daysSinceBirthdate = calendar.daysBetween(date1: birthdate, date2: .now) else {
            let emptyTimeline = Timeline<DaysOldEntry>(entries: [], policy: .never)
            completion(emptyTimeline)
            return
        }
        let currentEntry = DaysOldEntry(date: .now, daysSinceBirthdate: daysSinceBirthdate)
        let nextUpdateDate = calendar.date(
            byAdding: .day,
            value: daysSinceBirthdate + 1,
            to: birthdate,
            wrappingComponents: true
        )!
        let nextEntry = DaysOldEntry(date: nextUpdateDate, daysSinceBirthdate: daysSinceBirthdate + 1)
        let timeline = Timeline(entries: [currentEntry, nextEntry], policy: .after(nextUpdateDate))
        completion(timeline)
    }

    private var calendar: Calendar {
        .autoupdatingCurrent
    }

    private var birthdate: Date? {
        KeychainHelper.shared.fetchBirthdate()
    }
}

struct DaysOldEntry: TimelineEntry {
    let date: Date
    let daysSinceBirthdate: Int?
}

struct DaysOldWidgetEntryView : View {
    var entry: DaysOldProvider.Entry

    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryCircular, .accessoryRectangular:
            VStack(spacing: 0) {
                if entry.daysSinceBirthdate != nil {
                    daysOldText
                        .font(.system(size: 16, weight: .semibold))
                    daysOldSuffix
                        .font(.system(size: 15))
                } else {
                    Text("tap.to.set.up")
                }
            }
            .privacySensitive()
        case .accessoryInline:
            if entry.daysSinceBirthdate != nil {
                (daysOldText + Text(" ") + daysOldSuffix)
                    .privacySensitive()
            } else {
                EmptyView()
            }
        default:
            VStack(spacing: 4) {
                if entry.daysSinceBirthdate != nil {
                    Text("days.old.prefix")
                        .font(.system(size: 16))
                    daysOldText
                        .font(.system(size: 24, weight: .semibold))
                    daysOldSuffix
                        .font(.system(size: 16))
                } else {
                    Text("tap.to.set.up")
                }
            }
            .privacySensitive()
        }
    }

    private var daysOldText: Text {
        Text(entry.daysSinceBirthdate ?? 0, format: .number)
    }

    private var daysOldSuffix: Text {
        Text(entry.daysSinceBirthdate == 1 ? "days.old.suffix.singular" : "days.old.suffix.plural")
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
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline, .systemSmall])
    }
}

#Preview(as: .systemSmall) {
    DaysOldWidget()
} timeline: {
    DaysOldEntry(date: .now, daysSinceBirthdate: 12345)
}
