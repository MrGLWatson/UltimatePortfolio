//
//  SimpleWidget.swift
//  PortfolioWidgetExtension
//
//  Created by Gary Watson on 30/07/2021.
//

import WidgetKit
import SwiftUI

struct PortfolioWidgetEntryView: View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            Text("Up next...")
                .font(.title)

            if let item = entry.items.first {
                Text(item.itemTitle)
            } else {
                Text("nothing")
            }
        }
    }
}

struct SimplePortfolioWidget: Widget {
    let kind: String = "SimplePortfolioWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            PortfolioWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Up next…")
        .description("Your #1 top-priority item…")
        .supportedFamilies([.systemSmall]) // only allow small widget as larger is not useful at this time
    }
}

struct PortfolioWidget_Previews: PreviewProvider {
    static var previews: some View {
        PortfolioWidgetEntryView(entry: SimpleEntry(date: Date(), items: [Item.example]))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
