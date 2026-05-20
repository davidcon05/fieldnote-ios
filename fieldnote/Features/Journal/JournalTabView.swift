//
//  JournalTabView.swift
//  fieldnote
//
//  Created by David Contreras on 5/9/26.
//

import SwiftUI

struct JournalTabView: View {
    let journal: Journal
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            LogsListView(journal: journal)
                .tabItem {
                    Label("Logs", systemImage: "list.bullet")
                }
                .tag(0)

            NewLogView(journal: journal)
                .tabItem {
                    Label("New Log", systemImage: "plus.circle.fill")
                }
                .tag(1)

            MapView(journal: journal)
                .tabItem {
                    Label("Map", systemImage: "map")
                }
                .tag(2)
        }
        .tint(.primaryColor) // Selected tab color
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle(journal.name)
    }
}

#Preview {
    NavigationStack {
        JournalTabView(journal: Journal(name: "Olympic National Park"))
    }
}
