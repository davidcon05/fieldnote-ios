//
//  KeychainManagerUnitTests.swift
//  EcoJournalTests
//
//  Fast unit tests using MockKeychainManager (no simulator required)
//
//  Created by David Contreras on 5/29/26.
//

import Testing
import Foundation
@testable import EcoJournal

/// Fast unit tests that use MockKeychainManager
/// These test business logic without hitting real iOS Keychain
@MainActor
struct KeychainManagerUnitTests {

    // MARK: - Password Saving Tests

    @Test("Save password successfully with mock")
    func testSavePassword_Success() async throws {
        // Given
        let manager = MockKeychainManager()
        let journalID = "test-journal-123"
        let password = "testPassword123"

        // When
        try manager.savePassword(password, for: journalID)

        // Then
        #expect(manager.savePasswordCallCount == 1)
        let retrievedValue = try manager.getPassword(for: journalID)
        #expect(retrievedValue.contains("|")) // Should contain hash|salt format
    }

    @Test("Save password overwrites existing password")
    func testSavePassword_Overwrites() async throws {
        // Given
        let manager = MockKeychainManager()
        let journalID = "test-journal-123"
        let oldPassword = "oldPassword"
        let newPassword = "newPassword"

        // Save first password
        try manager.savePassword(oldPassword, for: journalID)

        // When - Save new password
        try manager.savePassword(newPassword, for: journalID)

        // Then - old password should not work, new password should work
        #expect(manager.verifyPassword(oldPassword, for: journalID) == false)
        #expect(manager.verifyPassword(newPassword, for: journalID) == true)
        #expect(manager.savePasswordCallCount == 2)
    }

    @Test("Save password creates unique salt per save")
    func testSavePassword_UniqueSalt() async throws {
        // Given
        let manager = MockKeychainManager()
        let journalID1 = "journal-1"
        let journalID2 = "journal-2"
        let samePassword = "samePassword123"

        // When - Save same password for two different journals
        try manager.savePassword(samePassword, for: journalID1)
        try manager.savePassword(samePassword, for: journalID2)

        // Then - Stored hashes should be different (due to different salts)
        let stored1 = try manager.getPassword(for: journalID1)
        let stored2 = try manager.getPassword(for: journalID2)
        #expect(stored1 != stored2)
    }

    // MARK: - Password Verification Tests

    @Test("Verify password succeeds with correct password")
    func testVerifyPassword_Correct() async throws {
        // Given
        let manager = MockKeychainManager()
        let journalID = "test-journal-123"
        let password = "testPassword123"
        try manager.savePassword(password, for: journalID)

        // When
        let result = manager.verifyPassword(password, for: journalID)

        // Then
        #expect(result == true)
        #expect(manager.verifyPasswordCallCount == 1)
    }

    @Test("Verify password fails with incorrect password")
    func testVerifyPassword_Incorrect() async throws {
        // Given
        let manager = MockKeychainManager()
        let journalID = "test-journal-123"
        let correctPassword = "correctPassword"
        let wrongPassword = "wrongPassword"
        try manager.savePassword(correctPassword, for: journalID)

        // When
        let result = manager.verifyPassword(wrongPassword, for: journalID)

        // Then
        #expect(result == false)
    }

    @Test("Verify password is case sensitive")
    func testVerifyPassword_CaseSensitive() async throws {
        // Given
        let manager = MockKeychainManager()
        let journalID = "test-journal-123"
        let password = "TestPassword"
        try manager.savePassword(password, for: journalID)

        // When/Then
        #expect(manager.verifyPassword("TestPassword", for: journalID) == true)
        #expect(manager.verifyPassword("testpassword", for: journalID) == false)
        #expect(manager.verifyPassword("TESTPASSWORD", for: journalID) == false)
    }

    @Test("Verify password handles special characters")
    func testVerifyPassword_SpecialCharacters() async throws {
        // Given
        let manager = MockKeychainManager()
        let journalID = "test-journal-123"
        let password = "P@ssw0rd!#$%^&*()"
        try manager.savePassword(password, for: journalID)

        // When
        let result = manager.verifyPassword(password, for: journalID)

        // Then
        #expect(result == true)
    }

    @Test("Verify password handles unicode characters")
    func testVerifyPassword_Unicode() async throws {
        // Given
        let manager = MockKeychainManager()
        let journalID = "test-journal-123"
        let password = "パスワード123🔐"
        try manager.savePassword(password, for: journalID)

        // When
        let result = manager.verifyPassword(password, for: journalID)

        // Then
        #expect(result == true)
    }

    // MARK: - Password Deletion Tests

    @Test("Delete password removes password from storage")
    func testDeletePassword_Success() async throws {
        // Given
        let manager = MockKeychainManager()
        let journalID = "test-journal-123"
        let password = "testPassword123"
        try manager.savePassword(password, for: journalID)

        // Verify password exists
        #expect(manager.verifyPassword(password, for: journalID) == true)

        // When
        try manager.deletePassword(for: journalID)

        // Then
        #expect(manager.deletePasswordCallCount == 1)
        #expect(manager.verifyPassword(password, for: journalID) == false)

        // Should throw when trying to retrieve
        #expect(throws: KeychainError.self) {
            try manager.getPassword(for: journalID)
        }
    }

    @Test("Delete password for non-existent journal doesn't crash")
    func testDeletePassword_NotFound() async throws {
        // Given
        let manager = MockKeychainManager()
        let journalID = "non-existent-journal"

        // When/Then - should not throw
        try manager.deletePassword(for: journalID)
        #expect(manager.deletePasswordCallCount == 1)
    }

    // MARK: - Error Handling Tests

    @Test("Save password throws error when configured to fail")
    func testSavePassword_ThrowsError() async throws {
        // Given
        let manager = MockKeychainManager()
        manager.shouldFailSave = true
        let journalID = "test-journal-123"

        // When/Then
        #expect(throws: KeychainError.self) {
            try manager.savePassword("password", for: journalID)
        }
    }

    @Test("Get password throws error when configured to fail")
    func testGetPassword_ThrowsError() async throws {
        // Given
        let manager = MockKeychainManager()
        manager.shouldFailRetrieve = true
        let journalID = "test-journal-123"

        // When/Then
        #expect(throws: KeychainError.self) {
            try manager.getPassword(for: journalID)
        }
    }

    @Test("Delete password throws error when configured to fail")
    func testDeletePassword_ThrowsError() async throws {
        // Given
        let manager = MockKeychainManager()
        manager.shouldFailDelete = true
        let journalID = "test-journal-123"

        // When/Then
        #expect(throws: KeychainError.self) {
            try manager.deletePassword(for: journalID)
        }
    }

    // MARK: - Biometric Tests

    @Test("Biometric availability returns configured value")
    func testIsBiometricAvailable() async throws {
        // Given
        let manager = MockKeychainManager()

        // When/Then - default true
        #expect(manager.isBiometricAvailable() == true)

        // When configured false
        manager.biometricAvailable = false
        #expect(manager.isBiometricAvailable() == false)
    }

    @Test("Biometric type returns configured value")
    func testGetBiometricType() async throws {
        // Given
        let manager = MockKeychainManager()

        // When/Then - default FaceID
        #expect(manager.getBiometricType() == .faceID)

        // When configured as TouchID
        manager.biometricType = .touchID
        #expect(manager.getBiometricType() == .touchID)
    }

    @Test("Biometric authentication returns configured result")
    func testAuthenticateWithBiometrics() async throws {
        // Given
        let manager = MockKeychainManager()

        // When - configured to succeed
        manager.biometricAuthResult = true
        let successResult = await manager.authenticateWithBiometrics(for: "Test Journal")

        // Then
        #expect(successResult == true)
        #expect(manager.biometricAuthCallCount == 1)

        // When - configured to fail
        manager.biometricAuthResult = false
        let failResult = await manager.authenticateWithBiometrics(for: "Test Journal")

        // Then
        #expect(failResult == false)
        #expect(manager.biometricAuthCallCount == 2)
    }
}
