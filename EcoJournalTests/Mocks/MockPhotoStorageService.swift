//
//  MockPhotoStorageService.swift
//  EcoJournalTests
//
//  Created by David Contreras on 5/29/26.
//

import Foundation
import UIKit
@testable import EcoJournal

/// Mock implementation of PhotoStorageService for unit testing
final class MockPhotoStorageService {
    // MARK: - Mock State

    var savedPhotos: [URL: UIImage] = [:]
    var shouldFailSave = false
    var shouldFailLoad = false
    var savePhotoCallCount = 0
    var loadPhotoCallCount = 0
    var deletePhotoCallCount = 0
    var deletePhotosCallCount = 0

    // MARK: - PhotoStorage Methods

    func savePhoto(_ image: UIImage) -> URL? {
        savePhotoCallCount += 1

        if shouldFailSave {
            return nil
        }

        // Generate a fake URL
        let filename = "\(UUID().uuidString).jpg"
        let fakeURL = URL(fileURLWithPath: "/tmp/\(filename)")

        savedPhotos[fakeURL] = image
        return fakeURL
    }

    func loadPhoto(from url: URL) -> UIImage? {
        loadPhotoCallCount += 1

        if shouldFailLoad {
            return nil
        }

        return savedPhotos[url]
    }

    func deletePhoto(at url: URL) {
        deletePhotoCallCount += 1
        savedPhotos.removeValue(forKey: url)
    }

    func deletePhotos(at urls: [URL]) {
        deletePhotosCallCount += 1
        for url in urls {
            savedPhotos.removeValue(forKey: url)
        }
    }

    // MARK: - Test Helpers

    func reset() {
        savedPhotos.removeAll()
        shouldFailSave = false
        shouldFailLoad = false
        savePhotoCallCount = 0
        loadPhotoCallCount = 0
        deletePhotoCallCount = 0
        deletePhotosCallCount = 0
    }
}
