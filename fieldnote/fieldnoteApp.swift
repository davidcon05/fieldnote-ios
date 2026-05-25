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
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])

            // Clear state when running UI tests (equivalent to Maestro's clearState: true)
            if ProcessInfo.processInfo.arguments.contains("--uitesting") {
                let context = ModelContext(container)
                do {
                    // Delete all journals (cascade will delete logs and audio memos)
                    try context.delete(model: Journal.self)
                    try context.save()
                } catch {
                    print("Failed to clear UI test state: \(error)")
                }
            }

            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            DashboardView()
                .onAppear {
                    // Disable animations during UI tests for faster, more reliable execution
                    if ProcessInfo.processInfo.arguments.contains("--uitesting") {
                        UIView.setAnimationsEnabled(false)
                        UIApplication.shared.connectedScenes
                            .compactMap { $0 as? UIWindowScene }
                            .flatMap { $0.windows }
                            .forEach { $0.layer.speed = 100 }
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }
}
