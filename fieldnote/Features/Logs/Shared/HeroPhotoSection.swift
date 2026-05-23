//
//  HeroPhotoSection.swift
//  fieldnote
//
//  Created by David Contreras on 5/23/26.
//

import SwiftUI
import CoreLocation

/// Reusable hero photo section component
/// Displays full-width photo with optional gradient overlay and metadata
/// Used in both LogDetailView (read-only) and EditLogView (with edit capabilities)
struct HeroPhotoSection: View {
    let photoURLs: [URL]
    let selectedPhotoIndex: Int
    let location: CLLocation?
    let altitude: Double?
    let mode: Mode
    let showGradientOverlay: Bool
    let showMetadata: Bool

    let onPhotoSelect: ((Int) -> Void)?
    let onAddPhoto: (() -> Void)?

    enum Mode {
        case readOnly
        case editable
    }

    private var heroImageHeight: CGFloat { 320 }

    init(
        photoURLs: [URL],
        selectedPhotoIndex: Int = 0,
        location: CLLocation? = nil,
        altitude: Double? = nil,
        mode: Mode = .readOnly,
        showGradientOverlay: Bool = true,
        showMetadata: Bool = true,
        onPhotoSelect: ((Int) -> Void)? = nil,
        onAddPhoto: (() -> Void)? = nil
    ) {
        self.photoURLs = photoURLs
        self.selectedPhotoIndex = selectedPhotoIndex
        self.location = location
        self.altitude = altitude
        self.mode = mode
        self.showGradientOverlay = showGradientOverlay
        self.showMetadata = showMetadata
        self.onPhotoSelect = onPhotoSelect
        self.onAddPhoto = onAddPhoto
    }

    var body: some View {
        VStack(spacing: 8) {
            // Primary Media Display
            if !photoURLs.isEmpty {
                ZStack(alignment: .bottom) {
                    // Hero Photo
                    AsyncImage(url: photoURLs[selectedPhotoIndex]) { phase in
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

                    // Gradient overlay (optional)
                    if showGradientOverlay {
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
                    }

                    // Meta Overlays (optional)
                    if showMetadata && hasGPSData {
                        VStack(spacing: 0) {
                            Spacer()
                            metadataOverlay
                        }
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 0))

                // Thumbnail Gallery
                if photoURLs.count > 1 || mode == .editable {
                    thumbnailGallery
                }
            } else if mode == .readOnly {
                // No photos - show placeholder with gradient (read-only mode)
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
                    if showMetadata && hasGPSData {
                        VStack(spacing: 0) {
                            Spacer()
                            metadataOverlay
                        }
                    }
                }
            }
        }
    }

    private var hasGPSData: Bool {
        location != nil
    }

    private var metadataOverlay: some View {
        VStack(spacing: 12) {
            // Divider line
            Rectangle()
                .fill(Color.white.opacity(0.2))
                .frame(height: 1)

            // Metadata grid - GPS and Elevation
            HStack(spacing: 16) {
                if let location = location {
                    MetadataItem(
                        label: "GPS Coordinates",
                        value: String(format: "%.4f° N, %.4f° W", abs(location.coordinate.latitude), abs(location.coordinate.longitude)),
                        alignment: .leading
                    )
                }

                if let altitude = altitude {
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
                // Add Photo placeholder FIRST (only in editable mode)
                if mode == .editable {
                    Button(action: {
                        onAddPhoto?()
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

                // Then existing photos
                ForEach(Array(photoURLs.enumerated()), id: \.offset) { index, url in
                    Button(action: {
                        onPhotoSelect?(index)
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
            }
            .padding(.horizontal, 16)
        }
    }
}

// MetadataItem moved from LogDetailView to be reusable
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

#Preview("Hero with Gradient & Metadata (LogDetailView style)") {
    let location = CLLocation(latitude: 47.8597, longitude: -123.9346)

    return HeroPhotoSection(
        photoURLs: [URL(string: "https://picsum.photos/800/1000")!],
        selectedPhotoIndex: 0,
        location: location,
        altitude: 182.0,
        mode: .readOnly,
        showGradientOverlay: true,
        showMetadata: true
    )
}

#Preview("Hero without Gradient - Add button first (EditLogView style)") {
    let location = CLLocation(latitude: 47.8597, longitude: -123.9346)

    return HeroPhotoSection(
        photoURLs: [
            URL(string: "https://picsum.photos/800/1000?1")!,
            URL(string: "https://picsum.photos/800/1000?2")!
        ],
        selectedPhotoIndex: 0,
        location: location,
        altitude: 182.0,
        mode: .editable,
        showGradientOverlay: false,
        showMetadata: false,
        onPhotoSelect: { index in
            print("Selected photo: \(index)")
        },
        onAddPhoto: {
            print("Add photo tapped")
        }
    )
}

#Preview("Hero - Multiple Photos, Editable") {
    return HeroPhotoSection(
        photoURLs: [
            URL(string: "https://picsum.photos/800/1000?1")!,
            URL(string: "https://picsum.photos/800/1000?2")!,
            URL(string: "https://picsum.photos/800/1000?3")!
        ],
        selectedPhotoIndex: 0,
        mode: .editable,
        showGradientOverlay: false,
        showMetadata: false,
        onPhotoSelect: { index in
            print("Selected photo: \(index)")
        },
        onAddPhoto: {
            print("Add photo tapped")
        }
    )
}
