//
//  KeychainManagerTests.swift
//  fieldnoteTests
//
//  Created by David Contreras on 5/9/26.
//

import Testing
import Foundation
@testable import fieldnote

@MainActor
struct KeychainManagerTests {

    // MARK: - Test Helpers

    private func cleanupKeychain(for journalID: String) {
        let manager = KeychainManager()
        try? manager.deletePassword(for: journalID)
    }

    // MARK: - Password Saving Tests

    @Test("Save password successfully")
    func testSavePassword_Success() async throws {
        // Given
        let manager = KeychainManager()
        let journalID = "test-journal-\(UUID().uuidString)"
        let password = "testPassword123"

        // When
        try manager.savePassword(password, for: journalID)

        // Then - should be able to retrieve it
        let retrievedValue = try manager.getPassword(for: journalID)
        #expect(retrievedValue.contains("|")) // Should contain hash|salt format

        // Cleanup
        cleanupKeychain(for: journalID)
    }

    @Test("Save password overwrites existing password")
    func testSavePassword_Overwrites() async throws {
        // Given
        let manager = KeychainManager()
        let journalID = "test-journal-\(UUID().uuidString)"
        let oldPassword = "oldPassword"
        let newPassword = "newPassword"

        // Save first password
        try manager.savePassword(oldPassword, for: journalID)

        // When - Save new password
        try manager.savePassword(newPassword, for: journalID)

        // Then - old password should not work, new password should work
        #expect(manager.verifyPassword(oldPassword, for: journalID) == false)
        #expect(manager.verifyPassword(newPassword, for: journalID) == true)

        // Cleanup
        cleanupKeychain(for: journalID)
    }

    @Test("Save password creates unique salt per save")
    func testSavePassword_UniqueSalt() async throws {
        // Given
        let manager = KeychainManager()
        let journalID1 = "test-journal-\(UUID().uuidString)"
        let journalID2 = "test-journal-\(UUID().uuidString)"
        let samePassword = "samePassword123"

        // When - Save same password for two different journals
        try manager.savePassword(samePassword, for: journalID1)
        try manager.savePassword(samePassword, for: journalID2)

        // Then - Stored hashes should be different (due to different salts)
        let stored1 = try manager.getPassword(for: journalID1)
        let stored2 = try manager.getPassword(for: journalID2)
        #expect(stored1 != stored2)

        // Cleanup
        cleanupKeychain(for: journalID1)
        cleanupKeychain(for: journalID2)
    }

    // MARK: - Password Retrieval Tests

    @Test("Get password returns stored value")
    func testGetPassword_Success() async throws {
        // Given
        let manager = KeychainManager()
        let journalID = "test-journal-\(UUID().uuidString)"
        let password = "testPassword123"
        try manager.savePassword(password, for: journalID)

        // When
        let retrieved = try manager.getPassword(for: journalID)

        // Then - Should be in "hash|salt" format
        let components = retrieved.components(separatedBy: "|")
        #expect(components.count == 2)
        #expect(components[0].isEmpty == false) // Hash
        #expect(components[1].isEmpty == false) // Salt

        // Cleanup
        cleanupKeychain(for: journalID)
    }

    @Test("Get password throws when password not found")
    func testGetPassword_NotFound() async throws {
        // Given
        let manager = KeychainManager()
        let nonExistentJournalID = "non-existent-\(UUID().uuidString)"

        // When/Then
        #expect(throws: KeychainError.self) {
            try manager.getPassword(for: nonExistentJournalID)
        }
    }

    // MARK: - Password Verification Tests

    @Test("Verify password succeeds with correct password")
    func testVerifyPassword_Correct() async throws {
        // Given
        let manager = KeychainManager()
        let journalID = "test-journal-\(UUID().uuidString)"
        let password = "correctPassword123"
        try manager.savePassword(password, for: journalID)

        // When
        let result = manager.verifyPassword(password, for: journalID)

        // Then
        #expect(result == true)

        // Cleanup
        cleanupKeychain(for: journalID)
    }

    @Test("Verify password fails with incorrect password")
    func testVerifyPassword_Incorrect() async throws {
        // Given
        let manager = KeychainManager()
        let journalID = "test-journal-\(UUID().uuidString)"
        let correctPassword = "correctPassword123"
        let wrongPassword = "wrongPassword456"
        try manager.savePassword(correctPassword, for: journalID)

        // When
        let result = manager.verifyPassword(wrongPassword, for: journalID)

        // Then
        #expect(result == false)

        // Cleanup
        cleanupKeychain(for: journalID)
    }

    @Test("Verify password returns false when no password stored")
    func testVerifyPassword_NoPassword() async throws {
        // Given
        let manager = KeychainManager()
        let journalID = "test-journal-\(UUID().uuidString)"

        // When
        let result = manager.verifyPassword("anyPassword", for: journalID)

        // Then
        #expect(result == false)
    }

    @Test("Verify password is case sensitive")
    func testVerifyPassword_CaseSensitive() async throws {
        // Given
        let manager = KeychainManager()
        let journalID = "test-journal-\(UUID().uuidString)"
        let password = "TestPassword123"
        try manager.savePassword(password, for: journalID)

        // When/Then
        #expect(manager.verifyPassword("testpassword123", for: journalID) == false)
        #expect(manager.verifyPassword("TESTPASSWORD123", for: journalID) == false)
        #expect(manager.verifyPassword(password, for: journalID) == true)

        // Cleanup
        cleanupKeychain(for: journalID)
    }

    @Test("Verify password handles special characters")
    func testVerifyPassword_SpecialCharacters() async throws {
        // Given
        let manager = KeychainManager()
        let journalID = "test-journal-\(UUID().uuidString)"
        let password = "P@ssw0rd!#$%^&*()"
        try manager.savePassword(password, for: journalID)

        // When
        let result = manager.verifyPassword(password, for: journalID)

        // Then
        #expect(result == true)

        // Cleanup
        cleanupKeychain(for: journalID)
    }

    @Test("Verify password handles unicode characters")
    func testVerifyPassword_Unicode() async throws {
        // Given
        let manager = KeychainManager()
        let journalID = "test-journal-\(UUID().uuidString)"
        let password = "パスワード123🔐"
        try manager.savePassword(password, for: journalID)

        // When
        let result = manager.verifyPassword(password, for: journalID)

        // Then
        #expect(result == true)

        // Cleanup
        cleanupKeychain(for: journalID)
    }

    // MARK: - Password Deletion Tests

    @Test("Delete password removes password from keychain")
    func testDeletePassword_Success() async throws {
        // Given
        let manager = KeychainManager()
        let journalID = "test-journal-\(UUID().uuidString)"
        let password = "testPassword123"
        try manager.savePassword(password, for: journalID)

        // Verify password exists
        #expect(manager.verifyPassword(password, for: journalID) == true)

        // When
        try manager.deletePassword(for: journalID)

        // Then - password should no longer exist
        #expect(manager.verifyPassword(password, for: journalID) == false)

        // Should throw when trying to retrieve
        #expect(throws: KeychainError.self) {
            try manager.getPassword(for: journalID)
        }
    }

    @Test("Delete password succeeds when password doesn't exist")
    func testDeletePassword_NotFound() async throws {
        // Given
        let manager = KeychainManager()
        let journalID = "test-journal-\(UUID().uuidString)"

        // When/Then - should not throw
        try manager.deletePassword(for: journalID)
    }

    @Test("Delete password can be followed by save")
    func testDeletePassword_ThenSave() async throws {
        // Given
        let manager = KeychainManager()
        let journalID = "test-journal-\(UUID().uuidString)"
        let oldPassword = "oldPassword"
        let newPassword = "newPassword"

        try manager.savePassword(oldPassword, for: journalID)
        try manager.deletePassword(for: journalID)

        // When - Save new password after deletion
        try manager.savePassword(newPassword, for: journalID)

        // Then
        #expect(manager.verifyPassword(oldPassword, for: journalID) == false)
        #expect(manager.verifyPassword(newPassword, for: journalID) == true)

        // Cleanup
        cleanupKeychain(for: journalID)
    }

    // MARK: - Biometric Tests

    @Test("isBiometricAvailable returns boolean without crashing")
    func testIsBiometricAvailable() async throws {
        // Given
        let manager = KeychainManager()

        // When
        let isAvailable = manager.isBiometricAvailable()

        // Then - Should return a boolean (true or false depending on device)
        #expect(isAvailable == true || isAvailable == false)
    }

    @Test("getBiometricType returns valid type")
    func testGetBiometricType() async throws {
        // Given
        let manager = KeychainManager()

        // When
        let type = manager.getBiometricType()

        // Then - Should be one of the valid types
        let validTypes: [BiometricType] = [.none, .touchID, .faceID, .opticID]
        #expect(validTypes.contains { $0.displayName == type.displayName })
    }

    @Test("Biometric type display names are not empty")
    func testBiometricType_DisplayNames() async throws {
        // When/Then
        #expect(BiometricType.none.displayName.isEmpty == false)
        #expect(BiometricType.touchID.displayName.isEmpty == false)
        #expect(BiometricType.faceID.displayName.isEmpty == false)
        #expect(BiometricType.opticID.displayName.isEmpty == false)
    }

    @Test("Biometric type icons are not empty")
    func testBiometricType_Icons() async throws {
        // When/Then
        #expect(BiometricType.none.icon.isEmpty == false)
        #expect(BiometricType.touchID.icon.isEmpty == false)
        #expect(BiometricType.faceID.icon.isEmpty == false)
        #expect(BiometricType.opticID.icon.isEmpty == false)
    }

    // MARK: - Error Tests

    @Test("KeychainError has descriptions")
    func testKeychainError_Descriptions() async throws {
        // Given
        let errors: [KeychainError] = [
            .encodingFailed,
            .decodingFailed,
            .saveFailed(-1),
            .retrievalFailed(-25300),
            .deleteFailed(-1)
        ]

        // When/Then
        for error in errors {
            #expect(error.errorDescription?.isEmpty == false)
        }
    }

    // MARK: - Edge Cases

    @Test("Empty password can be saved and verified")
    func testEmptyPassword() async throws {
        // Given
        let manager = KeychainManager()
        let journalID = "test-journal-\(UUID().uuidString)"
        let emptyPassword = ""

        // When
        try manager.savePassword(emptyPassword, for: journalID)

        // Then
        #expect(manager.verifyPassword(emptyPassword, for: journalID) == true)
        #expect(manager.verifyPassword("notEmpty", for: journalID) == false)

        // Cleanup
        cleanupKeychain(for: journalID)
    }

    @Test("Very long password can be saved and verified")
    func testVeryLongPassword() async throws {
        // Given
        let manager = KeychainManager()
        let journalID = "test-journal-\(UUID().uuidString)"
        let longPassword = String(repeating: "a", count: 1000)

        // When
        try manager.savePassword(longPassword, for: journalID)

        // Then
        #expect(manager.verifyPassword(longPassword, for: journalID) == true)
        #expect(manager.verifyPassword(longPassword + "x", for: journalID) == false)

        // Cleanup
        cleanupKeychain(for: journalID)
    }

    @Test("Multiple journals can have different passwords")
    func testMultipleJournals() async throws {
        // Given
        let manager = KeychainManager()
        let journal1 = "test-journal-\(UUID().uuidString)"
        let journal2 = "test-journal-\(UUID().uuidString)"
        let journal3 = "test-journal-\(UUID().uuidString)"

        let password1 = "password1"
        let password2 = "password2"
        let password3 = "password3"

        // When
        try manager.savePassword(password1, for: journal1)
        try manager.savePassword(password2, for: journal2)
        try manager.savePassword(password3, for: journal3)

        // Then - Each journal should only accept its own password
        #expect(manager.verifyPassword(password1, for: journal1) == true)
        #expect(manager.verifyPassword(password2, for: journal1) == false)
        #expect(manager.verifyPassword(password3, for: journal1) == false)

        #expect(manager.verifyPassword(password1, for: journal2) == false)
        #expect(manager.verifyPassword(password2, for: journal2) == true)
        #expect(manager.verifyPassword(password3, for: journal2) == false)

        #expect(manager.verifyPassword(password1, for: journal3) == false)
        #expect(manager.verifyPassword(password2, for: journal3) == false)
        #expect(manager.verifyPassword(password3, for: journal3) == true)

        // Cleanup
        cleanupKeychain(for: journal1)
        cleanupKeychain(for: journal2)
        cleanupKeychain(for: journal3)
    }
}
