//
//  MockKeychainManager.swift
//  EcoJournalTests
//
//  Created by David Contreras on 5/9/26.
//

import Foundation
import CryptoKit
@testable import EcoJournal

final class MockKeychainManager: KeychainManaging {
    // MARK: - Mock State

    var savedPasswords: [String: String] = [:] // Stores "hash|salt" format
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

        // Mimic real KeychainManager behavior: hash password with salt
        let salt = UUID().uuidString
        let passwordWithSalt = password + salt
        let passwordHash = SHA256.hash(data: Data(passwordWithSalt.utf8))
        let hashString = passwordHash.compactMap { String(format: "%02x", $0) }.joined()

        // Store in "hash|salt" format, just like real implementation
        let storedValue = "\(hashString)|\(salt)"
        savedPasswords[journalID] = storedValue
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

        guard let storedValue = try? getPassword(for: journalID) else {
            return false
        }

        // Parse stored format: "hash|salt"
        let components = storedValue.components(separatedBy: "|")
        guard components.count == 2 else {
            return false
        }

        let storedHash = components[0]
        let salt = components[1]

        // Hash entered password with same salt
        let enteredPasswordWithSalt = enteredPassword + salt
        let enteredHash = SHA256.hash(data: Data(enteredPasswordWithSalt.utf8))
        let enteredHashString = enteredHash.compactMap { String(format: "%02x", $0) }.joined()

        // Use constant-time comparison (mimic real implementation)
        return constantTimeCompare(storedHash, enteredHashString)
    }

    // MARK: - Helper Methods

    private func constantTimeCompare(_ a: String, _ b: String) -> Bool {
        guard a.count == b.count else { return false }

        var result = 0
        for (char1, char2) in zip(a, b) {
            result |= Int(char1.asciiValue ?? 0) ^ Int(char2.asciiValue ?? 0)
        }

        return result == 0
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
