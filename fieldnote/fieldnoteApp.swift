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
            .onAppear {
                // Seed data for development and map testing
                #if DEBUG
                seedDataIfNeeded()
                #endif
            }
    }

    private func seedDataIfNeeded() {
        // Only seed if there are no journals
        guard journals.isEmpty else { return }

        print("📝 Seeding development data...")

        // April 2026 dates in ascending order for testing search/filter
        let calendar = Calendar.current
        let april5 = calendar.date(from: DateComponents(year: 2026, month: 4, day: 5))!
        let april10 = calendar.date(from: DateComponents(year: 2026, month: 4, day: 10))!
        let april15 = calendar.date(from: DateComponents(year: 2026, month: 4, day: 15))!
        let april20 = calendar.date(from: DateComponents(year: 2026, month: 4, day: 20))!
        let april25 = calendar.date(from: DateComponents(year: 2026, month: 4, day: 25))!
        let april30 = calendar.date(from: DateComponents(year: 2026, month: 4, day: 30))!

        // Create Olympic National Park journal with sample logs
        let olympicJournal = Journal(name: "Olympic National Park")
        olympicJournal.createdDate = april5
        olympicJournal.lastModified = april5

        // Log 1: Hoh Rain Forest
        let log1 = Log(title: "Hoh Rain Forest Moss Survey", notes: "Found vibrant moss samples in Hoh Rain Forest. Massive Sitka spruce and western red cedar create a dense canopy. Soil extremely rich and moist.")
        log1.latitude = 47.8597
        log1.longitude = -123.9346
        log1.altitude = 182
        log1.weather = Weather(
            condition: "Rain",
            temperature: 12.5,
            humidity: 95,
            windSpeed: 2.1,
            icon: "10d",
            aqi: 1,
            pm25: 8.5,
            pm10: 12.3
        )
        log1.journal = olympicJournal

        // Log 2: Hurricane Ridge
        let log2 = Log(title: "Hurricane Ridge Wildflowers", notes: "Spectacular alpine wildflower meadows at Hurricane Ridge. Clear views of Mount Olympus. Temperature significantly cooler at elevation.")
        log2.latitude = 47.9697
        log2.longitude = -123.4985
        log2.altitude = 1605
        log2.weather = Weather(
            condition: "Clear",
            temperature: 15.2,
            humidity: 45,
            windSpeed: 8.5,
            icon: "01d",
            aqi: 1,
            pm25: 5.2,
            pm10: 8.1
        )
        log2.journal = olympicJournal

        // Log 3: Rialto Beach
        let log3 = Log(title: "Rialto Beach Tide Pools", notes: "Exploring tide pools at Rialto Beach. Sea stars, anemones, and kelp forests visible during low tide. Driftwood structures are massive.")
        log3.latitude = 47.9212
        log3.longitude = -124.6378
        log3.altitude = 3
        log3.weather = Weather(
            condition: "Clouds",
            temperature: 13.8,
            humidity: 78,
            windSpeed: 5.2,
            icon: "04d",
            aqi: 2,
            pm25: 15.8,
            pm10: 22.4
        )
        log3.journal = olympicJournal

        // Log 4: Sol Duc Falls Trail
        let log4 = Log(title: "Sol Duc Falls Observation", notes: "Waterfall observation at Sol Duc Falls. Water flow is strong from recent rainfall. Dense old-growth forest surrounds the trail.")
        log4.latitude = 47.9502
        log4.longitude = -123.8334
        log4.altitude = 564
        log4.weather = Weather(
            condition: "Rain",
            temperature: 11.5,
            humidity: 88,
            windSpeed: 3.8,
            icon: "09d",
            aqi: 1,
            pm25: 6.9,
            pm10: 10.5
        )
        log4.journal = olympicJournal

        // Log 5: Lake Crescent
        let log5 = Log(title: "Lake Crescent Survey", notes: "Crystal clear waters of Lake Crescent reveal remarkable depth. Glacially carved lake surrounded by steep forested hillsides. Water temperature notably cold even in summer months.")
        log5.latitude = 48.0545
        log5.longitude = -123.8010
        log5.altitude = 190
        log5.weather = Weather(
            condition: "Clear",
            temperature: 18.3,
            humidity: 62,
            windSpeed: 1.8,
            icon: "01d",
            aqi: 1,
            pm25: 7.2,
            pm10: 11.8
        )
        log5.journal = olympicJournal

        // Log 6: Ruby Beach
        let log6 = Log(title: "Ruby Beach Sea Stacks", notes: "Dramatic sea stacks and ruby-tinted sand at Ruby Beach. Strong Pacific waves crashing against ancient rock formations. Abundant marine life in tide pools between boulders.")
        log6.latitude = 47.7093
        log6.longitude = -124.4147
        log6.altitude = 5
        log6.weather = Weather(
            condition: "Clouds",
            temperature: 14.2,
            humidity: 82,
            windSpeed: 6.5,
            icon: "03d",
            aqi: 2,
            pm25: 12.4,
            pm10: 18.9
        )
        log6.journal = olympicJournal

        // Insert journal and logs
        modelContext.insert(olympicJournal)
        modelContext.insert(log1)
        modelContext.insert(log2)
        modelContext.insert(log3)
        modelContext.insert(log4)
        modelContext.insert(log5)
        modelContext.insert(log6)

        // Additional test journals for search/filter testing

        // Journals with "River" in name
        let cedarRiver = Journal(name: "Cedar River Watershed")
        cedarRiver.createdDate = april10
        cedarRiver.lastModified = april10
        modelContext.insert(cedarRiver)

        let snoqualmieRiver = Journal(name: "Snoqualmie River Basin")
        snoqualmieRiver.createdDate = april15
        snoqualmieRiver.lastModified = april15
        snoqualmieRiver.isPasswordProtected = true
        modelContext.insert(snoqualmieRiver)

        let columbiaRiver = Journal(name: "Columbia River Gorge")
        columbiaRiver.createdDate = april20
        columbiaRiver.lastModified = april20
        modelContext.insert(columbiaRiver)

        // Journals with "Ri" but not "River"
        let riceCreek = Journal(name: "Rice Creek Wetlands")
        riceCreek.createdDate = april25
        riceCreek.lastModified = april25
        modelContext.insert(riceCreek)

        let mountRitter = Journal(name: "Mount Ritter Expedition")
        mountRitter.createdDate = april30
        mountRitter.lastModified = april30
        mountRitter.isPasswordProtected = true
        modelContext.insert(mountRitter)

        let rimPacific = Journal(name: "Rim of the Pacific Survey")
        rimPacific.createdDate = calendar.date(from: DateComponents(year: 2026, month: 5, day: 5))!
        rimPacific.lastModified = calendar.date(from: DateComponents(year: 2026, month: 5, day: 5))!
        modelContext.insert(rimPacific)

        // Save
        do {
            try modelContext.save()
            print("✅ Seed data created successfully (7 journals)")
        } catch {
            print("❌ Error seeding data: \(error)")
        }
    }
}
