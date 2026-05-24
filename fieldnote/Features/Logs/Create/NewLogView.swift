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
    @Environment(\.modelContext) private var modelContext
    @StateObject private var viewModel: NewLogViewModel
    @StateObject private var locationManager = LocationManager()

    init(journal: Journal) {
        // TODO: Move to proper config once xcconfig is linked
        let apiKey = "e4fe2848d6d479aa409cdcf5937e7e7c"
        let weatherService = WeatherService(apiKey: apiKey)
        let airQualityService = AirQualityService(apiKey: apiKey)
        let locationMgr = LocationManager()

        _locationManager = StateObject(wrappedValue: locationMgr)

        // Initialize ViewModel - modelContext will be injected in onAppear
        _viewModel = StateObject(wrappedValue: NewLogViewModel(
            journal: journal,
            modelContext: try! ModelContext(ModelContainer(for: Journal.self, Log.self, AudioMemo.self)),
            locationManager: locationMgr,
            weatherService: weatherService,
            airQualityService: airQualityService
        ))
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                // Hero Photo Section (if photos exist)
                if !viewModel.photoURLs.isEmpty {
                    HeroPhotoSection(
                        photoURLs: viewModel.photoURLs,
                        selectedPhotoIndex: min(viewModel.selectedPhotoIndex, viewModel.photoURLs.count - 1),
                        location: locationManager.location,
                        altitude: locationManager.location?.altitude,
                        mode: .editable,
                        showGradientOverlay: false,
                        showMetadata: false,
                        onPhotoSelect: { index in
                            viewModel.selectedPhotoIndex = index
                        },
                        onAddPhoto: {
                            viewModel.showingPhotoSource = true
                        },
                        onDeletePhoto: { index in
                            viewModel.deletePhoto(at: index)
                        }
                    )
                }

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

                        TextField("Enter log title...", text: $viewModel.title)
                            .font(.body(16, weight: .semibold))
                            .textFieldStyle(.plain)
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(viewModel.title.isEmpty ? Color.error.opacity(0.5) : Color.outlineVariant, lineWidth: 1)
                            )
                    }

                    // Bento Grid Layout
                    VStack(spacing: 16) {
                        // Row 1: Photo Gallery (only show when no photos - for adding first photo)
                        if viewModel.photoURLs.isEmpty {
                            PhotoGalleryView(photoURLs: $viewModel.photoURLs)
                        }

                    // Row 2: Audio Memos
                    MultiAudioMemoView(audioMemos: $viewModel.audioMemos)

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
                        weather: viewModel.currentWeather,
                        location: locationManager.location,
                        isLoading: viewModel.isLoadingWeather,
                        error: viewModel.weatherError
                    )

                    // Retry button for weather errors
                    if viewModel.weatherError != nil && !viewModel.isLoadingWeather {
                        Button(action: viewModel.retryWeatherFetch) {
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

                    TextField("Enter your observations...", text: $viewModel.notes, axis: .vertical)
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
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 100) // Extra space for fixed bottom button
            }
            }
            .background(Color.background)

            // Fixed Bottom Button
            VStack(spacing: 0) {
                // Gradient fade at top of button bar
                LinearGradient(
                    colors: [Color.background.opacity(0), Color.background],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 20)

                Button(action: viewModel.saveLog) {
                    HStack(spacing: 12) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 20))
                        Text("Finalize Entry")
                            .font(.display(18, weight: .bold))
                    }
                    .foregroundColor(.onPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(viewModel.isValid ? Color.primaryColor : Color.outlineVariant)
                    .cornerRadius(12)
                    .shadow(color: Color.primaryColor.opacity(viewModel.isValid ? 0.2 : 0), radius: 8, x: 0, y: 4)
                }
                .disabled(!viewModel.isValid)
                .scaleEffect(viewModel.isValid ? 1.0 : 0.98)
                .animation(.easeInOut(duration: 0.2), value: viewModel.isValid)
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
                .background(Color.background)
            }
        }
        .confirmationDialog("Add Photo", isPresented: $viewModel.showingPhotoSource, titleVisibility: .visible) {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button("Take Photo") {
                    viewModel.showingCamera = true
                }
            }
            Button("Choose from Library") {
                viewModel.showingPhotoPicker = true
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $viewModel.showingCamera) {
            CameraPickerRepresentable(
                selectedImage: $viewModel.capturedImage,
                sourceType: .camera
            )
            .ignoresSafeArea()
        }
        .sheet(isPresented: $viewModel.showingPhotoPicker) {
            PhotoPickerRepresentable(selectedImages: $viewModel.selectedImages)
                .ignoresSafeArea()
        }
        .onChange(of: viewModel.capturedImage) { _, newImage in
            if let image = newImage {
                viewModel.addPhoto(image)
                viewModel.capturedImage = nil
            }
        }
        .onChange(of: viewModel.selectedImages) { _, newImages in
            if !newImages.isEmpty {
                for image in newImages {
                    viewModel.addPhoto(image)
                }
                viewModel.selectedImages = []
            }
        }
        .onAppear {
            viewModel.startLocationServices()
        }
        .onDisappear {
            viewModel.stopLocationServices()
        }
        .onChange(of: locationManager.location) { oldLocation, newLocation in
            // When location updates, fetch weather
            if let location = newLocation {
                viewModel.fetchWeatherIfNeeded(for: location)
            }
        }
        .alert("Log Saved", isPresented: $viewModel.showingSaveConfirmation) {
            Button("OK") {
                viewModel.resetForm()
            }
        } message: {
            Text("Your field observation has been saved to \(viewModel.journal.name)")
        }
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
