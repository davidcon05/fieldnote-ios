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

    // MARK: - Save Photo Tests

    @Test("Save photo with valid image returns file URL")
    func testSavePhoto_WithValidImage_ReturnsFileURL() {
        // Given
        let sut = MockPhotoStorageService()
        let testImage = createTestImage(color: .red, size: CGSize(width: 100, height: 100))

        // When
        let savedURL = sut.savePhoto(testImage)

        // Then
        #expect(savedURL != nil)
        #expect(sut.savePhotoCallCount == 1)
        #expect(sut.savedPhotos.count == 1)
    }

    @Test("Save photo creates unique filenames")
    func testSavePhoto_CreatesUniqueFilenames() {
        // Given
        let sut = MockPhotoStorageService()
        let testImage = createTestImage(color: .red, size: CGSize(width: 100, height: 100))

        // When
        let url1 = sut.savePhoto(testImage)
        let url2 = sut.savePhoto(testImage)

        // Then
        #expect(url1 != url2)
        #expect(sut.savedPhotos.count == 2)
        #expect(sut.savePhotoCallCount == 2)
    }

    @Test("Save photo returns nil when configured to fail")
    func testSavePhoto_ReturnsNil_WhenFails() {
        // Given
        let sut = MockPhotoStorageService()
        sut.shouldFailSave = true
        let testImage = createTestImage(color: .red, size: CGSize(width: 100, height: 100))

        // When
        let savedURL = sut.savePhoto(testImage)

        // Then
        #expect(savedURL == nil)
        #expect(sut.savePhotoCallCount == 1)
    }

    // MARK: - Load Photo Tests

    @Test("Load photo with valid URL returns image")
    func testLoadPhoto_WithValidURL_ReturnsImage() {
        // Given
        let sut = MockPhotoStorageService()
        let testImage = createTestImage(color: .blue, size: CGSize(width: 100, height: 100))
        guard let savedURL = sut.savePhoto(testImage) else {
            Issue.record("Failed to save test image")
            return
        }

        // When
        let loadedImage = sut.loadPhoto(from: savedURL)

        // Then
        #expect(loadedImage != nil)
        #expect(sut.loadPhotoCallCount == 1)
    }

    @Test("Load photo with invalid URL returns nil")
    func testLoadPhoto_WithInvalidURL_ReturnsNil() {
        // Given
        let sut = MockPhotoStorageService()
        let invalidURL = URL(fileURLWithPath: "/tmp/nonexistent.jpg")

        // When
        let loadedImage = sut.loadPhoto(from: invalidURL)

        // Then
        #expect(loadedImage == nil)
        #expect(sut.loadPhotoCallCount == 1)
    }

    @Test("Load photo returns nil when configured to fail")
    func testLoadPhoto_ReturnsNil_WhenFails() {
        // Given
        let sut = MockPhotoStorageService()
        let testImage = createTestImage(color: .green, size: CGSize(width: 100, height: 100))
        guard let savedURL = sut.savePhoto(testImage) else {
            Issue.record("Failed to save test image")
            return
        }

        sut.shouldFailLoad = true

        // When
        let loadedImage = sut.loadPhoto(from: savedURL)

        // Then
        #expect(loadedImage == nil)
        #expect(sut.loadPhotoCallCount == 1)
    }

    // MARK: - Delete Photo Tests

    @Test("Delete photo removes file from storage")
    func testDeletePhoto_RemovesFileFromDisk() {
        // Given
        let sut = MockPhotoStorageService()
        let testImage = createTestImage(color: .red, size: CGSize(width: 100, height: 100))
        guard let savedURL = sut.savePhoto(testImage) else {
            Issue.record("Failed to save test image")
            return
        }

        // Verify photo exists
        #expect(sut.savedPhotos[savedURL] != nil)

        // When
        sut.deletePhoto(at: savedURL)

        // Then
        #expect(sut.savedPhotos[savedURL] == nil)
        #expect(sut.deletePhotoCallCount == 1)
    }

    @Test("Delete photo with invalid URL does not crash")
    func testDeletePhoto_WithInvalidURL_DoesNotCrash() {
        // Given
        let sut = MockPhotoStorageService()
        let invalidURL = URL(fileURLWithPath: "/tmp/nonexistent.jpg")

        // When/Then - should not crash
        sut.deletePhoto(at: invalidURL)
        #expect(sut.deletePhotoCallCount == 1)
    }

    // MARK: - Delete Multiple Photos Tests

    @Test("Delete photos removes all specified files")
    func testDeletePhotos_RemovesAllSpecifiedFiles() {
        // Given
        let sut = MockPhotoStorageService()
        let testImage = createTestImage(color: .red, size: CGSize(width: 100, height: 100))

        guard let url1 = sut.savePhoto(testImage),
              let url2 = sut.savePhoto(testImage),
              let url3 = sut.savePhoto(testImage) else {
            Issue.record("Failed to save test images")
            return
        }

        #expect(sut.savedPhotos.count == 3)

        // When
        sut.deletePhotos(at: [url1, url2, url3])

        // Then
        #expect(sut.savedPhotos.count == 0)
        #expect(sut.deletePhotosCallCount == 1)
    }

    @Test("Delete photos with empty array does not crash")
    func testDeletePhotos_WithEmptyArray_DoesNotCrash() {
        // Given
        let sut = MockPhotoStorageService()

        // When/Then - should not crash
        sut.deletePhotos(at: [])
        #expect(sut.deletePhotosCallCount == 1)
    }

    // MARK: - Integration Flow Tests

    @Test("Save, load, delete flow works correctly")
    func testSaveLoadDeleteFlow() {
        // Given
        let sut = MockPhotoStorageService()
        let testImage = createTestImage(color: .purple, size: CGSize(width: 100, height: 100))

        // When - Save
        guard let savedURL = sut.savePhoto(testImage) else {
            Issue.record("Failed to save photo")
            return
        }

        // Then - Load
        let loadedImage = sut.loadPhoto(from: savedURL)
        #expect(loadedImage != nil)

        // Then - Delete
        sut.deletePhoto(at: savedURL)
        #expect(sut.savedPhotos[savedURL] == nil)

        // Verify deleted photo cannot be loaded
        let reloadedImage = sut.loadPhoto(from: savedURL)
        #expect(reloadedImage == nil)
    }
}
