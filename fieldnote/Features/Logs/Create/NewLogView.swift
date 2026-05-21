//
//  NewLogView.swift
//  fieldnote
//
//  Created by David Contreras on 5/9/26.
//

import SwiftUI
import CoreLocation
internal import Combine
import SwiftData

struct NewLogView: View {
    let journal: Journal

    @Environment(\.modelContext) private var modelContext
    @StateObject private var locationManager = LocationManager()
    private let weatherService: WeatherService
    private let airQualityService: AirQualityService

    @State private var title = ""
    @State private var notes = ""
    @State private var photoURLs: [URL] = []
    @State private var audioMemos: [AudioMemo] = []
    @State private var currentWeather: Weather?
    @State private var weatherError: String?
    @State private var isLoadingWeather = false
    @State private var showingSaveConfirmation = false
    @State private var weatherTask: Task<Void, Never>?

    init(journal: Journal) {
        self.journal = journal
        // TODO: Move to proper config once xcconfig is linked
        let apiKey = "e4fe2848d6d479aa409cdcf5937e7e7c"
        self.weatherService = WeatherService(apiKey: apiKey)
        self.airQualityService = AirQualityService(apiKey: apiKey)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 32) {
                // Session Header
                VStack(alignment: .leading, spacing: 4) {
                    Text("Capture Portal")
                        .font(.label(10, weight: .bold))
                        .foregroundColor(.tertiary)
                        .tracking(1.5)

                    Text("NEW LOG ENTRY")
                        .font(.display(24, weight: .black))
                        .foregroundColor(.onBackground)
                        .tracking(-0.5)
                }

                // Title Field (Required)
                VStack(alignment: .leading, spacing: 12) {
                    Text("TITLE (REQUIRED)")
                        .font(.label(10, weight: .bold))
                        .foregroundColor(.tertiary)
                        .tracking(1.5)

                    TextField("Enter log title...", text: $title)
                        .font(.body(16, weight: .semibold))
                        .textFieldStyle(.plain)
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(title.isEmpty ? Color.error.opacity(0.5) : Color.outlineVariant, lineWidth: 1)
                        )
                }

                // Bento Grid Layout
                VStack(spacing: 16) {
                    // Row 1: Photo Gallery (Large)
                    PhotoGalleryView(photoURLs: $photoURLs)

                    // Row 2: Audio Memos
                    MultiAudioMemoView(audioMemos: $audioMemos)

                    // Row 3: GPS Telemetry
                    GPSTelemetryCard(
                        location: locationManager.location,
                        isLoading: locationManager.location == nil && locationManager.locationError == nil,
                        error: locationManager.locationError,
                        onRefresh: {
                            locationManager.startUpdatingLocation()
                        }
                    )

                    // Row 3: Weather Data (Wide)
                    WeatherDataCard(
                        weather: currentWeather,
                        location: locationManager.location,
                        isLoading: isLoadingWeather,
                        error: weatherError
                    )

                    // Retry button for weather errors
                    if weatherError != nil && !isLoadingWeather {
                        Button(action: retryWeatherFetch) {
                            HStack {
                                Image(systemName: "arrow.clockwise")
                                Text("Retry Weather")
                            }
                            .font(.body(14, weight: .medium))
                            .foregroundColor(.primaryColor)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(Color.primaryColor.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                }

                // Field Notes Section (Optional)
                VStack(alignment: .leading, spacing: 12) {
                    Text("FIELD NOTES (OPTIONAL)")
                        .font(.label(10, weight: .bold))
                        .foregroundColor(.tertiary)
                        .tracking(1.5)

                    TextField("Enter your observations...", text: $notes, axis: .vertical)
                        .font(.body(15))
                        .lineLimit(6...10)
                        .textFieldStyle(.plain)
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.outlineVariant, lineWidth: 1)
                        )
                }

                // Finalize Entry Button
                Button(action: saveLog) {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                        Text("Finalize Entry")
                            .font(.display(18, weight: .bold))
                    }
                    .foregroundColor(.onPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(isValid ? Color.primaryColor : Color.outlineVariant)
                    .cornerRadius(12)
                    .shadow(color: Color.primaryColor.opacity(isValid ? 0.2 : 0), radius: 8, x: 0, y: 4)
                }
                .disabled(!isValid)
                .scaleEffect(isValid ? 1.0 : 0.98)
                .animation(.easeInOut(duration: 0.2), value: isValid)
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 24)
        }
        .background(Color.background)
        .onAppear {
            locationManager.requestPermission()
            locationManager.startUpdatingLocation()
        }
        .onDisappear {
            weatherTask?.cancel()
            locationManager.stopUpdatingLocation()
        }
        .onChange(of: locationManager.location) { oldLocation, newLocation in
            // When location updates, fetch weather
            if let location = newLocation, currentWeather == nil {
                fetchWeatherWithTimeout(for: location)
            }
        }
        .alert("Log Saved", isPresented: $showingSaveConfirmation) {
            Button("OK") {
                resetForm()
            }
        } message: {
            Text("Your field observation has been saved to \(journal.name)")
        }
    }

    // MARK: - Validation

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Action Handlers

    private func handleGPSTap() {
        // Show GPS details or copy coordinates
        if let location = locationManager.location {
            print("📍 GPS: \(location.coordinate.latitude), \(location.coordinate.longitude)")
        }
    }

    // MARK: - Weather Fetching

    private func fetchWeatherWithTimeout(for location: CLLocation) {
        // Cancel any existing weather fetch
        weatherTask?.cancel()

        isLoadingWeather = true
        weatherError = nil

        weatherTask = Task {
            do {
                // Fetch weather and air quality concurrently with 10 second timeout
                let (weather, airQuality) = try await withTimeout(seconds: 10) {
                    async let weatherData = weatherService.fetchWeather(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude
                    )

                    async let airQualityData = airQualityService.fetchAirQuality(
                        latitude: location.coordinate.latitude,
                        longitude: location.coordinate.longitude
                    )

                    return try await (weatherData, airQualityData)
                }

                // Check if task was cancelled
                guard !Task.isCancelled else { return }

                // Combine weather and air quality data
                let combinedWeather = Weather(
                    condition: weather.condition,
                    temperature: weather.temperature,
                    humidity: weather.humidity,
                    windSpeed: weather.windSpeed,
                    icon: weather.icon,
                    aqi: airQuality.aqi,
                    pm25: airQuality.pm25,
                    pm10: airQuality.pm10
                )

                await MainActor.run {
                    currentWeather = combinedWeather
                    isLoadingWeather = false
                }
            } catch is TimeoutError {
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    weatherError = "Weather fetch timed out"
                    isLoadingWeather = false
                }
            } catch {
                guard !Task.isCancelled else { return }
                await MainActor.run {
                    weatherError = error.localizedDescription
                    isLoadingWeather = false
                }
            }
        }
    }

    private func retryWeatherFetch() {
        guard let location = locationManager.location else {
            weatherError = "No location available"
            return
        }
        currentWeather = nil
        fetchWeatherWithTimeout(for: location)
    }

    // Timeout helper
    private func withTimeout<T>(seconds: TimeInterval, operation: @escaping () async throws -> T) async throws -> T {
        try await withThrowingTaskGroup(of: T.self) { group in
            group.addTask {
                try await operation()
            }

            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
                throw TimeoutError()
            }

            let result = try await group.next()!
            group.cancelAll()
            return result
        }
    }

    struct TimeoutError: Error {}

    // MARK: - Actions

    private func saveLog() {
        // Create new Log with all captured data
        let log = Log(
            title: title,
            notes: notes,
            mediaURLs: photoURLs
        )

        // Add GPS coordinates
        if let location = locationManager.location {
            log.latitude = location.coordinate.latitude
            log.longitude = location.coordinate.longitude
            log.altitude = location.altitude
        }

        // Add weather data
        log.weather = currentWeather

        // Add audio memos
        for memo in audioMemos {
            memo.log = log
            log.audioMemos.append(memo)
            modelContext.insert(memo)
        }

        // Associate with journal
        log.journal = journal

        // Save to SwiftData
        modelContext.insert(log)

        do {
            try modelContext.save()
            journal.touch() // Update journal's lastModified
            try modelContext.save() // Save again after touch
            showingSaveConfirmation = true
        } catch {
            print("❌ Error saving log: \(error)")
            // TODO: Show error alert to user
        }
    }

    private func resetForm() {
        title = ""
        notes = ""
        photoURLs = []
        audioMemos = []
        currentWeather = nil
        weatherError = nil
        // Location keeps updating for next log
    }
}

#Preview("Initial State") {
    NavigationStack {
        TabView {
            NewLogView(journal: Journal(name: "Olympic National Park"))
                .tabItem {
                    Label("New Log", systemImage: "plus.circle.fill")
                }
        }
    }
}

#Preview("Form Filled - Ready to Save") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Journal.self, Log.self, configurations: config)
    let journal = Journal(name: "Olympic National Park")
    container.mainContext.insert(journal)

    return NavigationStack {
        TabView {
            NewLogView(journal: journal)
                .tabItem {
                    Label("New Log", systemImage: "plus.circle.fill")
                }
        }
    }
    .modelContainer(container)
}

#Preview("Minimal - No GPS or Weather") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Journal.self, Log.self, configurations: config)
    let journal = Journal(name: "Test Journal")
    container.mainContext.insert(journal)

    return NavigationStack {
        TabView {
            NewLogView(journal: journal)
                .tabItem {
                    Label("New Log", systemImage: "plus.circle.fill")
                }
        }
    }
    .modelContainer(container)
}
