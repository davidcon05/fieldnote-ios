//
//  MockKeychainManager.swift
//  fieldnoteTests
//
//  Created by David Contreras on 5/9/26.
//

import Foundation
@testable import fieldnote

final class MockKeychainManager: KeychainManaging {
    // MARK: - Mock State

    var savedPasswords: [String: String] = [:]
    var shouldFailSave = false
    var shouldFailRetrieve = false
    var shouldFailDelete = false
    var biometricAvailable = true
    var biometricType: BiometricType = .faceID
    var biometricAuthResult = true
    var biometricAuthCallCount = 0
    var savePasswordCallCount = 0
    var verifyPasswordCallCount = 0
    var deletePasswordCallCount = 0

    // MARK: - KeychainManaging Implementation

    func savePassword(_ password: String, for journalID: String) throws {
        savePasswordCallCount += 1

        if shouldFailSave {
            throw KeychainError.saveFailed(-1)
        }

        savedPasswords[journalID] = password
    }

    func getPassword(for journalID: String) throws -> String {
        if shouldFailRetrieve {
            throw KeychainError.retrievalFailed(-1)
        }

        guard let password = savedPasswords[journalID] else {
            throw KeychainError.retrievalFailed(-25300) // errSecItemNotFound
        }

        return password
    }

    func verifyPassword(_ enteredPassword: String, for journalID: String) -> Bool {
        verifyPasswordCallCount += 1

        guard let storedPassword = savedPasswords[journalID] else {
            return false
        }

        return enteredPassword == storedPassword
    }

    func deletePassword(for journalID: String) throws {
        deletePasswordCallCount += 1

        if shouldFailDelete {
            throw KeychainError.deleteFailed(-1)
        }

        savedPasswords.removeValue(forKey: journalID)
    }

    func isBiometricAvailable() -> Bool {
        return biometricAvailable
    }

    func getBiometricType() -> BiometricType {
        return biometricType
    }

    func authenticateWithBiometrics(for journalName: String) async -> Bool {
        biometricAuthCallCount += 1

        // Simulate async delay
        try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

        return biometricAuthResult
    }

    // MARK: - Test Helpers

    func reset() {
        savedPasswords.removeAll()
        shouldFailSave = false
        shouldFailRetrieve = false
        shouldFailDelete = false
        biometricAvailable = true
        biometricType = .faceID
        biometricAuthResult = true
        biometricAuthCallCount = 0
        savePasswordCallCount = 0
        verifyPasswordCallCount = 0
        deletePasswordCallCount = 0
    }
}
