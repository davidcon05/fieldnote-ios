//
//  NewLogView.swift
//  EcoJournal
//
//  Created by David Contreras on 5/9/26.
//

import SwiftUI
import CoreLocation
internal import Combine
import SwiftData

struct NewLogView: View {
    @Environment(\.modelContext) private var modelContext
    @StateObject private var locationManager = LocationManager()

    let journal: Journal

    // Create ViewModel lazily after we have access to environment's modelContext
    @State private var viewModel: NewLogViewModel?

    init(journal: Journal) {
        self.journal = journal
        let locationMgr = LocationManager()
        _locationManager = StateObject(wrappedValue: locationMgr)
    }

    var body: some View {
        Group {
            if let viewModel = viewModel {
                NewLogContentView(viewModel: viewModel, locationManager: locationManager)
            } else {
                ProgressView("Loading...")
            }
        }
        .onAppear {
            if viewModel == nil {
                // Initialize ViewModel with environment's modelContext
                let apiKey = Bundle.main.infoDictionary?["WEATHER_API_KEY"] as? String ?? ""
                let weatherService = WeatherService(apiKey: apiKey)
                let airQualityService = AirQualityService(apiKey: apiKey)

                viewModel = NewLogViewModel(
                    journal: journal,
                    modelContext: modelContext,  // Use environment's modelContext!
                    locationManager: locationManager,
                    weatherService: weatherService,
                    airQualityService: airQualityService
                )
            }
        }
    }
}

// MARK: - Content View with ObservedObject
private struct NewLogContentView: View {
    @ObservedObject var viewModel: NewLogViewModel
    @ObservedObject var locationManager: LocationManager

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    heroSection
                    formContent
                }
                .padding(.horizontal, 24)
                .padding(.top, 24)
                .padding(.bottom, 100)
            }
            .background(Color.background)

            saveButton
        }
        .confirmationDialog("Add Photo", isPresented: $viewModel.showingPhotoSource, titleVisibility: .visible) {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button("Take Photo") { viewModel.showingCamera = true }
            }
            Button("Choose from Library") { viewModel.showingPhotoPicker = true }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $viewModel.showingCamera) {
            CameraPickerRepresentable(selectedImage: $viewModel.capturedImage, sourceType: .camera)
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
        .onAppear { viewModel.startLocationServices() }
        .onDisappear { viewModel.stopLocationServices() }
        .onChange(of: locationManager.location) { _, newLocation in
            if let location = newLocation {
                viewModel.fetchWeatherIfNeeded(for: location)
            }
        }
        .alert("Log Saved", isPresented: $viewModel.showingSaveConfirmation) {
            Button("OK") { viewModel.resetForm() }
        } message: {
            Text("Your field observation has been saved to \(viewModel.journal.name)")
        }
    }

    // MARK: - Main Sections

    @ViewBuilder
    private var heroSection: some View {
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
    }

    private var formContent: some View {
        VStack(alignment: .leading, spacing: 32) {
            sessionHeader
            titleField
            bentoGrid
        }
    }

    private var saveButton: some View {
        VStack(spacing: 0) {
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
            .accessibilityIdentifier(NewLogAccessibilityIdentifiers.finalizeButton)
            .disabled(!viewModel.isValid)
            .scaleEffect(viewModel.isValid ? 1.0 : 0.98)
            .animation(.easeInOut(duration: 0.2), value: viewModel.isValid)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            .background(Color.background)
        }
    }

    // MARK: - Form Sections

    private var sessionHeader: some View {
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
    }

    private var titleField: some View {
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
                .accessibilityIdentifier(NewLogAccessibilityIdentifiers.titleField)
        }
    }

    private var bentoGrid: some View {
        VStack(spacing: 16) {
            if viewModel.photoURLs.isEmpty {
                PhotoGalleryView(photoURLs: $viewModel.photoURLs)
            }

            MultiAudioMemoView(audioMemos: $viewModel.audioMemos)

            fieldNotesSection

            GPSTelemetryCard(
                location: locationManager.location,
                isLoading: locationManager.location == nil && locationManager.locationError == nil,
                error: locationManager.locationError,
                onRefresh: {
                    locationManager.startUpdatingLocation()
                }
            )
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(NewLogAccessibilityIdentifiers.gpsTelemetryCard)

            WeatherDataCard(
                weather: viewModel.currentWeather,
                location: locationManager.location,
                isLoading: viewModel.isLoadingWeather,
                error: viewModel.weatherError
            )
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(NewLogAccessibilityIdentifiers.weatherDataCard)

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
                .accessibilityIdentifier(NewLogAccessibilityIdentifiers.weatherRetryButton)
            }
        }
    }

    private var fieldNotesSection: some View {
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
                .accessibilityIdentifier(NewLogAccessibilityIdentifiers.notesField)
        }
    }
}

// MARK: - View Modifiers

// These view modifiers need to be applied inline since they need Binding access
// Custom view modifiers don't work well with @Published properties

// MARK: - Previews

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
