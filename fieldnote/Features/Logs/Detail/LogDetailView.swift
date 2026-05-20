//
//  LogDetailView.swift
//  fieldnote
//
//  Created by David Contreras on 5/19/26.
//

import SwiftUI
import CoreLocation
import SwiftData
import MapKit

struct LogDetailView: View {
    let log: Log
    let journal: Journal

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var showingEditView = false
    @State private var showingDeleteConfirmation = false
    @State private var deleteConfirmationText = ""
    @State private var selectedPhotoIndex: Int = 0

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Hero Section: Immersive Media Header
                heroSection

                // Content Section
                VStack(spacing: 32) {
                    // Title Section
                    titleSection

                    // Field Notes Section
                    if !log.notes.isEmpty {
                        fieldNotesSection
                    }

                    // Field Observations (Audio Memos)
                    if !log.audioMemos.isEmpty {
                        fieldObservationsSection
                    }

                    // Telemetry Data Grid (Weather)
                    if log.weather != nil {
                        telemetryDataSection
                    }

                    // Location Sync Section
                    if hasGPSData {
                        locationSyncSection
                    }

                    // Action Buttons
                    actionButtons
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 32)
            }
        }
        .background(Color.background)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                VStack(spacing: 2) {
                    Text("Log Details")
                        .font(.body(16, weight: .bold))
                        .foregroundColor(.onSurface)
                    Text(journal.name.uppercased())
                        .font(.label(9, weight: .bold))
                        .foregroundColor(.onSurfaceVariant)
                        .tracking(1.2)
                }
            }

            // MARK: - Future Feature: Share/Export (Hidden for now)
            // Uncomment when share/export functionality is implemented
            /*
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {
                    Button(action: { shareLog() }) {
                        Label("Share", systemImage: "square.and.arrow.up")
                    }
                    Button(action: { exportLog() }) {
                        Label("Export", systemImage: "arrow.down.doc")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.onSurfaceVariant)
                }
            }
            */
        }
        .navigationDestination(isPresented: $showingEditView) {
            EditLogView(log: log, journal: journal)
        }
        .alert("Delete Log Entry", isPresented: $showingDeleteConfirmation) {
            TextField("Type DELETE to confirm", text: $deleteConfirmationText)
            Button("Cancel", role: .cancel) {
                deleteConfirmationText = ""
            }
            Button("Delete", role: .destructive) {
                deleteLog()
            }
            .disabled(deleteConfirmationText != "DELETE")
        } message: {
            Text("This will permanently delete this observation. This action cannot be undone.\n\nType DELETE to confirm.")
        }
    }

    // MARK: - Hero Section

    private var heroImageHeight: CGFloat { 320 } // Fixed height ~40% of iPhone screen

    private var heroSection: some View {
        VStack(spacing: 8) {
            // Primary Media Display
            if !log.mediaURLs.isEmpty {
                ZStack(alignment: .bottom) {
                    AsyncImage(url: log.mediaURLs[selectedPhotoIndex]) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(Color.surfaceContainerHigh)
                                .frame(maxWidth: .infinity)
                                .frame(height: heroImageHeight)
                                .overlay {
                                    ProgressView()
                                }
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(maxWidth: .infinity)
                                .frame(height: heroImageHeight)
                                .clipped()
                        case .failure:
                            Rectangle()
                                .fill(Color.surfaceContainerHigh)
                                .frame(maxWidth: .infinity)
                                .frame(height: heroImageHeight)
                                .overlay {
                                    Image(systemName: "photo")
                                        .font(.system(size: 48))
                                        .foregroundColor(.onSurfaceVariant)
                                }
                        @unknown default:
                            EmptyView()
                        }
                    }

                    // Gradient overlay
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.6),
                            Color.clear,
                            Color.clear,
                            Color.black.opacity(0.85)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )

                    // Meta Overlays
                    if hasGPSData || log.weather != nil {
                        VStack(spacing: 0) {
                            Spacer()
                            metadataOverlay
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 0))

                // Thumbnail Gallery
                if log.mediaURLs.count > 1 {
                    thumbnailGallery
                }
            } else {
                // No photos - show placeholder with gradient
                ZStack(alignment: .bottom) {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [Color.primaryColor.opacity(0.3), Color.primaryColor],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(maxWidth: .infinity)
                        .frame(height: heroImageHeight)
                        .overlay {
                            VStack {
                                Image(systemName: "leaf.fill")
                                    .font(.system(size: 64))
                                    .foregroundColor(.white.opacity(0.5))
                                Text("No Photos")
                                    .font(.body(16, weight: .bold))
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }

                    // Meta Overlays
                    if hasGPSData || log.weather != nil {
                        VStack(spacing: 0) {
                            Spacer()
                            metadataOverlay
                        }
                    }
                }
            }
        }
    }

    private var metadataOverlay: some View {
        VStack(spacing: 12) {
            // Divider line
            Rectangle()
                .fill(Color.white.opacity(0.2))
                .frame(height: 1)

            // Metadata grid - only GPS and Elevation (unique data not in telemetry)
            HStack(spacing: 16) {
                if let lat = log.latitude, let lon = log.longitude {
                    MetadataItem(
                        label: "GPS Coordinates",
                        value: String(format: "%.4f° N, %.4f° W", abs(lat), abs(lon)),
                        alignment: .leading
                    )
                }

                if let altitude = log.altitude {
                    MetadataItem(
                        label: "Elevation",
                        value: String(format: "%.0fm ASL", altitude),
                        alignment: .trailing
                    )
                }
            }
        }
        .padding(16)
        .background(Color.black.opacity(0.4).background(.ultraThinMaterial))
    }

    private var thumbnailGallery: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(log.mediaURLs.enumerated()), id: \.offset) { index, url in
                    Button(action: {
                        selectedPhotoIndex = index
                    }) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 72, height: 72)
                                    .clipped()
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(selectedPhotoIndex == index ? Color.primaryColor : Color.clear, lineWidth: 2)
                                    )
                            default:
                                Rectangle()
                                    .fill(Color.surfaceContainerHigh)
                                    .frame(width: 72, height: 72)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }

                // Add Photo placeholder
                Button(action: {
                    showingEditView = true
                }) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.surfaceContainer)
                        .frame(width: 72, height: 72)
                        .overlay {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.onSurfaceVariant)
                        }
                }
            }
            .padding(.horizontal, 16)
        }
    }

    // MARK: - Title Section

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(log.timestamp.formatted(date: .abbreviated, time: .shortened).uppercased())
                .font(.label(10, weight: .bold))
                .foregroundColor(.primaryColor)
                .tracking(1.5)

            Text(log.title)
                .font(.display(28, weight: .black))
                .foregroundColor(.onBackground)
                .tracking(-0.5)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Field Notes Section

    private var fieldNotesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(icon: "doc.text", title: "Field Notes")

            Text(log.notes)
                .font(.body(16))
                .foregroundColor(.onSurface)
                .lineSpacing(6)
                .padding(20)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.surfaceContainerLow)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.outlineVariant.opacity(0.3), lineWidth: 1)
                )
        }
    }

    // MARK: - Field Observations Section (Audio)

    private var fieldObservationsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(icon: "waveform", title: "Field Observations")

            VStack(spacing: 12) {
                ForEach(Array(log.audioMemos.enumerated()), id: \.element.id) { index, memo in
                    AudioMemoDisplayCard(memo: memo, index: index + 1)
                }
            }
        }
    }

    // MARK: - Telemetry Data Section (Weather)

    private var telemetryDataSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(icon: "chart.line.uptrend.xyaxis", title: "Telemetry Data")

            if let weather = log.weather {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                    TelemetryCard(
                        icon: "thermometer.medium",
                        label: "Temperature",
                        value: String(format: "%.1f°F", weather.temperature)
                    )

                    TelemetryCard(
                        icon: "humidity",
                        label: "Humidity",
                        value: "\(weather.humidity)%"
                    )

                    TelemetryCard(
                        icon: "wind",
                        label: "Wind Speed",
                        value: String(format: "%.1f mph", weather.windSpeed * 0.621371)
                    )

                    if let aqi = weather.aqi {
                        TelemetryCard(
                            icon: "aqi.medium",
                            label: "Air Quality",
                            value: aqiLabel(aqi)
                        )
                    }
                }
            }
        }
    }

    // MARK: - Location Sync Section

    private var locationSyncSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader(icon: "map", title: "Location Sync")

            if let lat = log.latitude, let lon = log.longitude {
                ZStack(alignment: .bottom) {
                    // Map preview
                    Map(
                        position: .constant(.region(MKCoordinateRegion(
                            center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                        )))
                    ) {
                        Marker("", coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon))
                            .tint(Color.primaryColor)
                    }
                    .mapStyle(.hybrid)
                    .frame(height: 200)
                    .cornerRadius(12)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.outlineVariant.opacity(0.3), lineWidth: 1)
                    )

                    // Info bar at bottom
                    HStack {
                        Text("SECTOR: FIELD")
                            .font(.label(9, weight: .bold))
                            .foregroundColor(.onSurfaceVariant)
                            .tracking(1.5)

                        Spacer()

                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.primaryColor)
                            Text("SYNCED")
                                .font(.label(9, weight: .bold))
                                .foregroundColor(.onSurfaceVariant)
                                .tracking(1.2)
                        }
                    }
                    .padding(12)
                    .background(Color.surfaceContainer.opacity(0.95))
                    .cornerRadius(8, corners: [.bottomLeft, .bottomRight])
                }
            }
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        VStack(spacing: 16) {
            // Edit Button
            Button(action: {
                showingEditView = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "square.and.pencil")
                        .font(.system(size: 18))
                    Text("Edit Field Note")
                        .font(.body(16, weight: .bold))
                }
                .foregroundColor(.onSurface)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.surfaceContainerHigh)
                .cornerRadius(24)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.outlineVariant.opacity(0.5), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
            }

            // Delete Button
            Button(action: {
                showingDeleteConfirmation = true
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "trash.fill")
                        .font(.system(size: 16))
                    Text("Delete Log Entry")
                        .font(.body(15, weight: .bold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.red)
                .cornerRadius(24)
            }
        }
    }

    // MARK: - Helper Views

    private func sectionHeader(icon: String, title: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(.primaryColor)

            Text(title.uppercased())
                .font(.label(11, weight: .bold))
                .foregroundColor(.primaryColor)
                .tracking(1.5)
        }
        .padding(.bottom, 4)
        .frame(maxWidth: .infinity, alignment: .leading)
        .overlay(
            Rectangle()
                .fill(Color.outlineVariant.opacity(0.3))
                .frame(height: 1),
            alignment: .bottom
        )
    }

    // MARK: - Computed Properties

    private var hasGPSData: Bool {
        log.latitude != nil && log.longitude != nil
    }

    private func aqiLabel(_ aqi: Int) -> String {
        switch aqi {
        case 1: return "1 Good"
        case 2: return "2 Fair"
        case 3: return "3 Moderate"
        case 4: return "4 Poor"
        case 5: return "5 Very Poor"
        default: return "\(aqi)"
        }
    }

    // MARK: - Action Handlers

    private func shareLog() {
        // TODO: Implement share functionality
        print("Share log")
    }

    private func exportLog() {
        // TODO: Implement export functionality
        print("Export log")
    }

    private func deleteLog() {
        guard deleteConfirmationText == "DELETE" else { return }

        modelContext.delete(log)
        dismiss()
    }
}

// MARK: - Supporting Views

struct MetadataItem: View {
    let label: String
    let value: String
    let alignment: HorizontalAlignment

    var body: some View {
        VStack(alignment: alignment, spacing: 2) {
            Text(label.uppercased())
                .font(.label(8, weight: .bold))
                .foregroundColor(.white.opacity(0.6))
                .tracking(1.2)

            Text(value)
                .font(.body(13, weight: .regular))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: alignment == .leading ? .leading : .trailing)
    }
}

struct TelemetryCard: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(.tertiary)

            Text(label.uppercased())
                .font(.label(10, weight: .bold))
                .foregroundColor(.onSurfaceVariant)
                .tracking(1.2)

            Text(value)
                .font(.display(18, weight: .black))
                .foregroundColor(.onSurface)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(Color.surfaceContainerLow)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.outlineVariant.opacity(0.2), lineWidth: 1)
        )
    }
}

// MARK: - Audio Memo Display Card (Read-Only)

struct AudioMemoDisplayCard: View {
    let memo: AudioMemo
    let index: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Text("Memo #\(index) • \(memo.title)")
                    .font(.label(10, weight: .bold))
                    .foregroundColor(.onSurfaceVariant)
                    .tracking(1.2)

                Spacer()

                if memo.transcription != nil {
                    Text("TRANSCRIBED")
                        .font(.label(9, weight: .bold))
                        .foregroundColor(.onPrimaryContainer)
                        .tracking(1)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.primaryColor.opacity(0.15))
                        .cornerRadius(4)
                }
            }

            // Transcription (if available)
            if let transcription = memo.transcription {
                Text(transcription)
                    .font(.body(14))
                    .italic()
                    .foregroundColor(.onSurfaceVariant)
                    .padding(12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.5))
                    .cornerRadius(8)
            }

            // Audio Player Controls (placeholder)
            HStack(spacing: 12) {
                Button(action: {
                    // TODO: Implement audio playback
                }) {
                    Circle()
                        .fill(memo.transcription != nil ? Color.primaryColor : Color.primaryColor.opacity(0.1))
                        .frame(width: 40, height: 40)
                        .overlay {
                            Image(systemName: "play.fill")
                                .font(.system(size: 16))
                                .foregroundColor(memo.transcription != nil ? .onPrimary : .primaryColor)
                        }
                }

                // Progress bar placeholder
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.surfaceContainerHighest)
                            .frame(height: 4)

                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.primaryColor)
                            .frame(width: geometry.size.width * 0.0, height: 4) // No progress by default
                    }
                }
                .frame(height: 4)

                Text(formattedDuration(memo.duration))
                    .font(.label(11, weight: .regular))
                    .foregroundColor(.onSurfaceVariant)
                    .monospacedDigit()
            }
        }
        .padding(16)
        .background(Color.surfaceContainer)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.outlineVariant.opacity(0.3), lineWidth: 1)
        )
    }

    private func formattedDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

// Helper extension for selective corner radius
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

// MARK: - Previews

#Preview("Complete Log with All Data") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Journal.self, Log.self, AudioMemo.self, configurations: config)

    let journal = Journal(name: "Olympic National Park")
    let log = Log(title: "Coastal Observation Log", notes: "Surface scan reveals unusual tectonic shifting near the shoreline. Bio-organic presence detected in the tide pools near sector 4. The structural integrity of the basalt stacks appears compromised by accelerated erosion.\n\nRecommend follow-up survey within 30 days to monitor progression of coastal changes.")
    log.latitude = 47.8021
    log.longitude = -123.6044
    log.altitude = 142.0
    log.weather = Weather(
        condition: "Clear",
        temperature: 64.1, // 18°C in Fahrenheit
        humidity: 92,
        windSpeed: 14.0, // km/h
        icon: "01d",
        aqi: 1,
        pm25: 5.2,
        pm10: 8.1
    )

    // Add multiple audio memos
    let memo1 = AudioMemo(
        title: "Soil Moisture",
        audioURL: URL(string: "file:///memo1.m4a")!,
        transcription: "Observed significant moisture levels in the soil at the base of the Hoh Rain Forest perimeter. Initial tests suggest increase in microbial activity.",
        duration: 42
    )
    memo1.log = log

    let memo2 = AudioMemo(
        title: "Ambient Acoustics",
        audioURL: URL(string: "file:///memo2.m4a")!,
        transcription: nil,
        duration: 75
    )
    memo2.log = log

    log.audioMemos = [memo1, memo2]

    journal.logs.append(log)
    container.mainContext.insert(journal)

    return NavigationStack {
        LogDetailView(log: log, journal: journal)
            .modelContainer(container)
    }
}

#Preview("Minimal Log - Notes Only") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Journal.self, Log.self, configurations: config)

    let journal = Journal(name: "Field Journal 2026")
    let log = Log(title: "Bird Activity Observation", notes: "Quick observation - noticed unusual bird activity in the western sector. Will follow up tomorrow with proper equipment.")

    journal.logs.append(log)
    container.mainContext.insert(journal)

    return NavigationStack {
        LogDetailView(log: log, journal: journal)
            .modelContainer(container)
    }
}

#Preview("With Single Voice Memo") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Journal.self, Log.self, AudioMemo.self, configurations: config)

    let journal = Journal(name: "Field Research")
    let log = Log(title: "Soil Analysis", notes: "Initial soil sample collection from northern sector. High clay content observed.")
    log.latitude = 47.8597
    log.longitude = -123.9346
    log.altitude = 182.0

    // Single audio memo with transcription
    let memo = AudioMemo(
        title: "Sample Collection Notes",
        audioURL: URL(string: "file:///sample-notes.m4a")!,
        transcription: "Collected three soil samples from depth of 15 centimeters. Samples show high moisture content and rich organic material. Will conduct pH testing in lab tomorrow.",
        duration: 58
    )
    memo.log = log
    log.audioMemos = [memo]

    journal.logs.append(log)
    container.mainContext.insert(journal)

    return NavigationStack {
        LogDetailView(log: log, journal: journal)
            .modelContainer(container)
    }
}

#Preview("With Photos & GPS") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Journal.self, Log.self, AudioMemo.self, configurations: config)

    let journal = Journal(name: "Coastal Survey")
    let log = Log(title: "Coastal Erosion Documentation", notes: "Documenting erosion patterns along the northern coastline. Three distinct formations showing advanced weathering.")
    log.latitude = 48.1234
    log.longitude = -124.5678
    log.altitude = 85.0
    log.mediaURLs = [
        URL(string: "https://picsum.photos/800/1000?1")!,
        URL(string: "https://picsum.photos/800/1000?2")!,
        URL(string: "https://picsum.photos/800/1000?3")!
    ]

    journal.logs.append(log)
    container.mainContext.insert(journal)

    return NavigationStack {
        LogDetailView(log: log, journal: journal)
            .modelContainer(container)
    }
}
