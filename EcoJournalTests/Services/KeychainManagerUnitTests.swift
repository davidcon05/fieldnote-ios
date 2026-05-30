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

    // MARK: - Error Handling Tests

    @Test("Throws error when mock configured to fail")
    func testThrowsError() async throws {
        // Given
        let manager = MockKeychainManager()
        manager.shouldFailSave = true

        // When/Then
        #expect(throws: KeychainError.self) {
            try manager.savePassword("password", for: "test")
        }
    }
}
