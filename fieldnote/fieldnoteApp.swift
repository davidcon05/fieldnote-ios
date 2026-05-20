//
//  fieldnoteApp.swift
//  fieldnote
//
//  Created by David Contreras on 5/5/26.
//

import SwiftUI
import SwiftData

@main
struct fieldnoteApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Journal.self,
            Log.self,
            AudioMemo.self,
        ])
        // Using persistent storage for field testing and map development
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            DashboardViewWrapper()
        }
        .modelContainer(sharedModelContainer)
    }
}

struct DashboardViewWrapper: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var journals: [Journal]

    var body: some View {
        DashboardView(modelContext: modelContext)
    }
}
