//
//  PhotoStorageUnitTests.swift
//  EcoJournalTests
//
//  Fast unit tests using MockPhotoStorageService (no simulator required)
//
//  Created by David Contreras on 5/29/26.
//

import Testing
import Foundation
import UIKit
@testable import EcoJournal

/// Fast unit tests that use MockPhotoStorageService
/// These test business logic without hitting real file system
struct PhotoStorageUnitTests {

    // MARK: - Test Helpers

    private func createTestImage(color: UIColor, size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }

    @Test("Save, load, delete flow with multiple photos")
    func photoStorageFlow() {
        // Given
        let sut = MockPhotoStorageService()
        let testImage = createTestImage(color: .purple, size: CGSize(width: 100, height: 100))

        // When: Save multiple photos
        guard let url1 = sut.savePhoto(testImage),
              let url2 = sut.savePhoto(testImage) else {
            Issue.record("Failed to save photos")
            return
        }

        // Then: Unique URLs created
        #expect(url1 != url2)
        #expect(sut.savedPhotos.count == 2)

        // When: Load photo
        let loadedImage = sut.loadPhoto(from: url1)

        // Then: Image loaded successfully
        #expect(loadedImage != nil)

        // When: Delete single photo
        sut.deletePhoto(at: url1)

        // Then: Photo removed, cannot be loaded
        #expect(sut.savedPhotos[url1] == nil)
        #expect(sut.loadPhoto(from: url1) == nil)
        #expect(sut.savedPhotos.count == 1)

        // When: Delete multiple photos
        sut.deletePhotos(at: [url2])

        // Then: All photos removed
        #expect(sut.savedPhotos.isEmpty)
    }

    @Test("Photo storage handles errors gracefully")
    func photoStorageErrorHandling() {
        // Given
        let sut = MockPhotoStorageService()
        let testImage = createTestImage(color: .red, size: CGSize(width: 100, height: 100))

        // When: Save fails
        sut.shouldFailSave = true
        let savedURL = sut.savePhoto(testImage)

        // Then: Returns nil
        #expect(savedURL == nil)

        // When: Load from invalid URL
        let invalidURL = URL(fileURLWithPath: "/tmp/nonexistent.jpg")
        let loadedImage = sut.loadPhoto(from: invalidURL)

        // Then: Returns nil
        #expect(loadedImage == nil)

        // When: Delete invalid URL
        sut.deletePhoto(at: invalidURL)
        sut.deletePhotos(at: [])

        // Then: No crash
        #expect(sut.deletePhotoCallCount == 1)
        #expect(sut.deletePhotosCallCount == 1)
    }
}
