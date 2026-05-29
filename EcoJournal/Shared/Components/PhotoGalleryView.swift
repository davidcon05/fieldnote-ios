//
//  PhotoGalleryView.swift
//  EcoJournal
//
//  Created by David Contreras on 5/13/26.
//

import SwiftUI
import UIKit

/// Photo gallery component with multi-photo slider
/// Replaces CapturePhotoButton with functional camera/library integration
struct PhotoGalleryView: View {
    @Binding var photoURLs: [URL]

    @State private var showingPhotoSource = false
    @State private var showingCamera = false
    @State private var showingPhotoPicker = false
    @State private var capturedImage: UIImage?
    @State private var selectedImages: [UIImage] = []
    @State private var photoToDelete: URL?
    @State private var showingDeleteConfirmation = false

    private let photoStorage = PhotoStorageService.shared

    var body: some View {
        if photoURLs.isEmpty {
            // Empty state: Show "Add Photo" button
            emptyStateButton
        } else {
            // Gallery state: TabView slider with photos
            photoGallerySlider
        }
    }

    // MARK: - Empty State

    private var emptyStateButton: some View {
        Button(action: { showingPhotoSource = true }) {
            VStack(spacing: 16) {
                // Camera Icon in Circle
                ZStack {
                    Circle()
                        .fill(Color.primaryColor)
                        .frame(width: 80, height: 80)
                        .shadow(color: Color.primaryColor.opacity(0.3), radius: 8, x: 0, y: 4)

                    Image(systemName: "camera.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.onPrimary)
                }

                // Text
                VStack(spacing: 4) {
                    Text("Add Photos")
                        .font(.display(20, weight: .bold))
                        .foregroundColor(.onSurface)

                    Text("Capture or import field observations")
                        .font(.body(14))
                        .foregroundColor(.onSurfaceVariant)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.outlineVariant, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
            .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .confirmationDialog("Add Photo", isPresented: $showingPhotoSource, titleVisibility: .visible) {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button("Take Photo") {
                    showingCamera = true
                }
            }
            Button("Choose from Library") {
                showingPhotoPicker = true
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showingCamera) {
            CameraPickerRepresentable(
                selectedImage: $capturedImage,
                sourceType: .camera
            )
            .ignoresSafeArea()
        }
        .sheet(isPresented: $showingPhotoPicker) {
            PhotoPickerRepresentable(selectedImages: $selectedImages)
                .ignoresSafeArea()
        }
        .onChange(of: capturedImage) { _, newImage in
            if let image = newImage {
                addPhoto(image)
                capturedImage = nil
            }
        }
        .onChange(of: selectedImages) { _, newImages in
            if !newImages.isEmpty {
                addPhotos(newImages)
                selectedImages = []
            }
        }
    }

    // MARK: - Gallery Slider

    private var photoGallerySlider: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Photo count label
            HStack {
                Text("PHOTOS (\(photoURLs.count))")
                    .font(.label(10, weight: .bold))
                    .foregroundColor(.tertiary)
                    .tracking(1.5)

                Spacer()

                Button(action: { showingPhotoSource = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                        Text("Add More")
                    }
                    .font(.body(16, weight: .medium))
                    .foregroundColor(.primaryColor)
                }
            }
            .padding(.horizontal, 4)

            // TabView slider
            TabView {
                ForEach(Array(photoURLs.enumerated()), id: \.offset) { index, url in
                    photoSlide(url: url, index: index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .frame(height: 240)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.outlineVariant, lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        }
        .confirmationDialog("Add Photo", isPresented: $showingPhotoSource, titleVisibility: .visible) {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                Button("Take Photo") {
                    showingCamera = true
                }
            }
            Button("Choose from Library") {
                showingPhotoPicker = true
            }
            Button("Cancel", role: .cancel) {}
        }
        .sheet(isPresented: $showingCamera) {
            CameraPickerRepresentable(
                selectedImage: $capturedImage,
                sourceType: .camera
            )
            .ignoresSafeArea()
        }
        .sheet(isPresented: $showingPhotoPicker) {
            PhotoPickerRepresentable(selectedImages: $selectedImages)
                .ignoresSafeArea()
        }
        .alert("Delete Photo?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {
                photoToDelete = nil
            }
            Button("Delete", role: .destructive) {
                if let url = photoToDelete {
                    deletePhoto(url)
                }
            }
        } message: {
            Text("This photo will be permanently removed from this log entry.")
        }
        .onChange(of: capturedImage) { _, newImage in
            if let image = newImage {
                addPhoto(image)
                capturedImage = nil
            }
        }
        .onChange(of: selectedImages) { _, newImages in
            if !newImages.isEmpty {
                addPhotos(newImages)
                selectedImages = []
            }
        }
    }

    // MARK: - Photo Slide

    private func photoSlide(url: URL, index: Int) -> some View {
        ZStack(alignment: .topTrailing) {
            // Photo
            if let image = photoStorage.loadPhoto(from: url) {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 240)
                    .clipped()
            } else {
                // Fallback if photo fails to load
                Rectangle()
                    .fill(Color.surfaceContainer)
                    .frame(height: 240)
                    .overlay(
                        VStack(spacing: 8) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 32))
                                .foregroundColor(.onSurfaceVariant)
                            Text("Failed to load photo")
                                .font(.body(14))
                                .foregroundColor(.onSurfaceVariant)
                        }
                    )
            }

            // Delete button overlay
            Button(action: {
                photoToDelete = url
                showingDeleteConfirmation = true
            }) {
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.6))
                        .frame(width: 36, height: 36)

                    Image(systemName: "trash.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
            }
            .padding(12)
        }
    }

    // MARK: - Actions

    private func addPhoto(_ image: UIImage) {
        guard let url = photoStorage.savePhoto(image) else { return }
        photoURLs.append(url)
    }

    private func addPhotos(_ images: [UIImage]) {
        for image in images {
            addPhoto(image)
        }
    }

    private func deletePhoto(_ url: URL) {
        // Remove from array
        photoURLs.removeAll { $0 == url }
        // Delete file from disk
        photoStorage.deletePhoto(at: url)
        photoToDelete = nil
    }
}

// MARK: - Previews

#Preview("Empty State") {
    @Previewable @State var photoURLs: [URL] = []

    return PhotoGalleryView(photoURLs: $photoURLs)
        .padding()
}

#Preview("With Photos") {
    @Previewable @State var photoURLs: [URL] = [
        URL(string: "file:///photo1.jpg")!,
        URL(string: "file:///photo2.jpg")!,
        URL(string: "file:///photo3.jpg")!
    ]

    return PhotoGalleryView(photoURLs: $photoURLs)
        .padding()
}
