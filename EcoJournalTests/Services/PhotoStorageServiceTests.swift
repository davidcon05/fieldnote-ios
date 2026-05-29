//
//  PhotoStorageServiceTests.swift
//  EcoJournalTests
//
//  Created by David Contreras on 5/23/26.
//

import XCTest
import UIKit
@testable import EcoJournal

final class PhotoStorageServiceTests: XCTestCase {
    var sut: PhotoStorageService!
    var testPhotosDirectory: URL!

    override func setUpWithError() throws {
        try super.setUpWithError()
        sut = PhotoStorageService.shared

        // Get the photos directory to clean up test files
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        testPhotosDirectory = documentsPath.appendingPathComponent("LogPhotos", isDirectory: true)
    }

    override func tearDownWithError() throws {
        // Clean up any test photos created during tests
        if let photoURLs = try? FileManager.default.contentsOfDirectory(
            at: testPhotosDirectory,
            includingPropertiesForKeys: nil
        ) {
            for url in photoURLs {
                try? FileManager.default.removeItem(at: url)
            }
        }

        sut = nil
        try super.tearDownWithError()
    }

    // MARK: - Save Photo Tests

    func testSavePhoto_WithValidImage_ReturnsFileURL() {
        // Given
        let testImage = createTestImage(color: .red, size: CGSize(width: 100, height: 100))

        // When
        let savedURL = sut.savePhoto(testImage)

        // Then
        XCTAssertNotNil(savedURL, "Should return a valid URL when saving photo")
        XCTAssertTrue(FileManager.default.fileExists(atPath: savedURL!.path), "Photo file should exist on disk")
        XCTAssertTrue(savedURL!.lastPathComponent.hasSuffix(".jpg"), "Photo should be saved as JPEG")
    }

    func testSavePhoto_CreatesUniqueFilenames() {
        // Given
        let testImage = createTestImage(color: .blue, size: CGSize(width: 50, height: 50))

        // When
        let url1 = sut.savePhoto(testImage)
        let url2 = sut.savePhoto(testImage)

        // Then
        XCTAssertNotNil(url1)
        XCTAssertNotNil(url2)
        XCTAssertNotEqual(url1?.lastPathComponent, url2?.lastPathComponent, "Should create unique filenames for each photo")
    }

    func testSavePhoto_CreatesPhotosDirectory() {
        // Given
        let testImage = createTestImage(color: .green, size: CGSize(width: 100, height: 100))

        // When
        let savedURL = sut.savePhoto(testImage)

        // Then
        XCTAssertNotNil(savedURL)
        XCTAssertTrue(FileManager.default.fileExists(atPath: testPhotosDirectory.path), "LogPhotos directory should be created")
    }

    // MARK: - Load Photo Tests

    func testLoadPhoto_WithValidURL_ReturnsImage() {
        // Given
        let originalImage = createTestImage(color: .red, size: CGSize(width: 100, height: 100))
        guard let savedURL = sut.savePhoto(originalImage) else {
            XCTFail("Failed to save test image")
            return
        }

        // When
        let loadedImage = sut.loadPhoto(from: savedURL)

        // Then
        XCTAssertNotNil(loadedImage, "Should load image from valid URL")
        XCTAssertTrue(loadedImage!.size.width > 0, "Loaded image should have valid width")
        XCTAssertTrue(loadedImage!.size.height > 0, "Loaded image should have valid height")
    }

    func testLoadPhoto_WithInvalidURL_ReturnsNil() {
        // Given
        let invalidURL = testPhotosDirectory.appendingPathComponent("nonexistent.jpg")

        // When
        let loadedImage = sut.loadPhoto(from: invalidURL)

        // Then
        XCTAssertNil(loadedImage, "Should return nil for invalid URL")
    }

    // MARK: - Delete Photo Tests

    func testDeletePhoto_RemovesFileFromDisk() {
        // Given
        let testImage = createTestImage(color: .yellow, size: CGSize(width: 100, height: 100))
        guard let savedURL = sut.savePhoto(testImage) else {
            XCTFail("Failed to save test image")
            return
        }

        // Verify file exists
        XCTAssertTrue(FileManager.default.fileExists(atPath: savedURL.path))

        // When
        sut.deletePhoto(at: savedURL)

        // Then
        XCTAssertFalse(FileManager.default.fileExists(atPath: savedURL.path), "Photo file should be deleted")
    }

    func testDeletePhoto_WithInvalidURL_DoesNotCrash() {
        // Given
        let invalidURL = testPhotosDirectory.appendingPathComponent("nonexistent.jpg")

        // When/Then - Should not crash
        sut.deletePhoto(at: invalidURL)
    }

    // MARK: - Delete Multiple Photos Tests

    func testDeletePhotos_RemovesAllSpecifiedFiles() {
        // Given
        let image1 = createTestImage(color: .red, size: CGSize(width: 100, height: 100))
        let image2 = createTestImage(color: .blue, size: CGSize(width: 100, height: 100))
        let image3 = createTestImage(color: .green, size: CGSize(width: 100, height: 100))

        guard let url1 = sut.savePhoto(image1),
              let url2 = sut.savePhoto(image2),
              let url3 = sut.savePhoto(image3) else {
            XCTFail("Failed to save test images")
            return
        }

        let urlsToDelete = [url1, url2, url3]

        // Verify files exist
        XCTAssertTrue(FileManager.default.fileExists(atPath: url1.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: url2.path))
        XCTAssertTrue(FileManager.default.fileExists(atPath: url3.path))

        // When
        sut.deletePhotos(at: urlsToDelete)

        // Then
        XCTAssertFalse(FileManager.default.fileExists(atPath: url1.path), "Photo 1 should be deleted")
        XCTAssertFalse(FileManager.default.fileExists(atPath: url2.path), "Photo 2 should be deleted")
        XCTAssertFalse(FileManager.default.fileExists(atPath: url3.path), "Photo 3 should be deleted")
    }

    func testDeletePhotos_WithEmptyArray_DoesNotCrash() {
        // Given
        let emptyArray: [URL] = []

        // When/Then - Should not crash
        sut.deletePhotos(at: emptyArray)
    }

    // MARK: - Integration Tests

    func testSaveLoadDeleteFlow() {
        // Given
        let originalImage = createTestImage(color: .purple, size: CGSize(width: 200, height: 200))

        // When - Save
        guard let savedURL = sut.savePhoto(originalImage) else {
            XCTFail("Failed to save image")
            return
        }

        // Then - Verify saved
        XCTAssertTrue(FileManager.default.fileExists(atPath: savedURL.path))

        // When - Load
        let loadedImage = sut.loadPhoto(from: savedURL)

        // Then - Verify loaded (size may vary due to JPEG compression and scale)
        XCTAssertNotNil(loadedImage)
        XCTAssertTrue(loadedImage!.size.width > 0, "Loaded image should have positive width")
        XCTAssertTrue(loadedImage!.size.height > 0, "Loaded image should have positive height")

        // When - Delete
        sut.deletePhoto(at: savedURL)

        // Then - Verify deleted
        XCTAssertFalse(FileManager.default.fileExists(atPath: savedURL.path))
        XCTAssertNil(sut.loadPhoto(from: savedURL))
    }

    // MARK: - Helper Methods

    private func createTestImage(color: UIColor, size: CGSize) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            color.setFill()
            context.fill(CGRect(origin: .zero, size: size))
        }
    }
}
