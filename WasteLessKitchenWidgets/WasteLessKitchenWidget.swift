import SwiftUI
import WidgetKit

struct WasteLessWidgetEntry: TimelineEntry {
    let date: Date
    let expiringItems: [String]
    let recipeTitle: String
}

struct WasteLessWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> WasteLessWidgetEntry {
        WasteLessWidgetEntry(date: .now, expiringItems: ["Spinach", "Avocados"], recipeTitle: "Green Shakshuka")
    }

    func getSnapshot(in context: Context, completion: @escaping (WasteLessWidgetEntry) -> Void) {
        completion(placeholder(in: context))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WasteLessWidgetEntry>) -> Void) {
        let entry = WasteLessWidgetEntry(
            date: .now,
            expiringItems: ["Avocados", "Cilantro", "Spinach"],
            recipeTitle: "Avocado Chickpea Toast"
        )
        let next = Calendar.current.date(byAdding: .hour, value: 4, to: .now) ?? .now.addingTimeInterval(14_400)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }
}

struct WasteLessKitchenWidgetView: View {
    let entry: WasteLessWidgetEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Use Today", systemImage: "clock.badge.exclamationmark")
                .font(.headline)
                .foregroundStyle(.green)
            ForEach(entry.expiringItems.prefix(3), id: \.self) { item in
                Text(item)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
            }
            Spacer(minLength: 0)
            Text(entry.recipeTitle)
                .font(.caption.weight(.medium))
                .foregroundStyle(.secondary)
                .lineLimit(2)
        }
        .containerBackground(.thinMaterial, for: .widget)
    }
}

struct WasteLessKitchenWidget: Widget {
    let kind = "WasteLessKitchenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WasteLessWidgetProvider()) { entry in
            WasteLessKitchenWidgetView(entry: entry)
        }
        .configurationDisplayName("WasteLess Kitchen")
        .description("See what to use today and what to cook tonight.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct WasteLessKitchenWidgetBundle: WidgetBundle {
    var body: some Widget {
        WasteLessKitchenWidget()
    }
}
