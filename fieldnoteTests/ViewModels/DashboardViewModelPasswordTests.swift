//
//  DashboardViewModelPasswordTests.swift
//  fieldnoteTests
//
//  Created by David Contreras on 5/9/26.
//

import Testing
import Foundation
import SwiftData
@testable import fieldnote

@MainActor
struct DashboardViewModelPasswordTests {

    // MARK: - Password Verification Tests

    @Test("Password verification succeeds with correct password")
    func testPasswordVerification_Success() async throws {
        // Given
        let mockKeychain = MockKeychainManager()
        let viewModel = DashboardViewModel(keychainManager: mockKeychain)

        let journal = Journal(name: "Test Journal")
        try mockKeychain.savePassword("password123", for: journal.id.uuidString)
        viewModel.journalToUnlock = journal

        // When
        let result = viewModel.verifyPassword("password123")

        // Then
        #expect(result == true)
        #expect(viewModel.lockoutMessage == nil)
        #expect(viewModel.failedAttempts[journal.id] == nil)
        #expect(viewModel.shouldNavigateToJournal == true)
        #expect(mockKeychain.verifyPasswordCallCount == 1)
    }

    @Test("Password verification fails with wrong password")
    func testPasswordVerification_Failure() async throws {
        // Given
        let mockKeychain = MockKeychainManager()
        let viewModel = DashboardViewModel(keychainManager: mockKeychain)

        let journal = Journal(name: "Test Journal")
        try mockKeychain.savePassword("correct", for: journal.id.uuidString)
        viewModel.journalToUnlock = journal

        // When
        let result = viewModel.verifyPassword("wrong")

        // Then
        #expect(result == false)
        #expect(viewModel.failedAttempts[journal.id] == 1)
        #expect(viewModel.shouldNavigateToJournal == false)
        #expect(viewModel.lockoutMessage == "4 attempts remaining")
    }

    // MARK: - Brute Force Protection Tests

    @Test("Journal locks after 5 failed password attempts")
    func testBruteForceProtection_LockoutAfter5Attempts() async throws {
        // Given
        let mockKeychain = MockKeychainManager()
        let viewModel = DashboardViewModel(keychainManager: mockKeychain)

        let journal = Journal(name: "Test Journal")
        try mockKeychain.savePassword("correct", for: journal.id.uuidString)
        viewModel.journalToUnlock = journal

        // When - Make 5 failed attempts
        for _ in 1...5 {
            _ = viewModel.verifyPassword("wrong")
        }

        // Then
        #expect(viewModel.failedAttempts[journal.id] == 5)
        #expect(viewModel.lockedJournals.contains(journal.id) == true)
        #expect(viewModel.lockoutMessage == "Too many failed attempts. Journal locked for 5 minutes.")
    }

    @Test("Locked journal rejects password attempts")
    func testBruteForceProtection_LockedJournalRejectsAttempts() async throws {
        // Given
        let mockKeychain = MockKeychainManager()
        let viewModel = DashboardViewModel(keychainManager: mockKeychain)

        let journal = Journal(name: "Test Journal")
        try mockKeychain.savePassword("correct", for: journal.id.uuidString)
        viewModel.journalToUnlock = journal

        // Lock the journal
        for _ in 1...5 {
            _ = viewModel.verifyPassword("wrong")
        }

        // When - Try with correct password while locked
        let result = viewModel.verifyPassword("correct")

        // Then
        #expect(result == false)
        #expect(viewModel.lockoutMessage == "Too many failed attempts. Try again in a few minutes.")
    }

    @Test("Failed attempts reset after successful password entry")
    func testBruteForceProtection_FailedAttemptsReset() async throws {
        // Given
        let mockKeychain = MockKeychainManager()
        let viewModel = DashboardViewModel(keychainManager: mockKeychain)

        let journal = Journal(name: "Test Journal")
        try mockKeychain.savePassword("correct", for: journal.id.uuidString)
        viewModel.journalToUnlock = journal

        // Make 3 failed attempts
        for _ in 1...3 {
            _ = viewModel.verifyPassword("wrong")
        }

        // When - Enter correct password
        let result = viewModel.verifyPassword("correct")

        // Then
        #expect(result == true)
        #expect(viewModel.failedAttempts[journal.id] == nil)
        #expect(viewModel.lockoutMessage == nil)
    }

    // MARK: - Biometric Authentication Tests

    @Test("Biometric unlock succeeds when biometrics available")
    func testBiometricUnlock_Success() async throws {
        // Given
        let mockKeychain = MockKeychainManager()
        mockKeychain.biometricAvailable = true
        mockKeychain.biometricAuthResult = true

        let viewModel = DashboardViewModel(keychainManager: mockKeychain)

        let journal = Journal(name: "Test Journal")
        viewModel.journalToUnlock = journal

        // When
        let result = await viewModel.attemptBiometricUnlock(for: journal)

        // Then
        #expect(result == true)
        #expect(viewModel.shouldNavigateToJournal == true)
        #expect(viewModel.showingPasswordPrompt == false)
        #expect(mockKeychain.biometricAuthCallCount == 1)
    }

    @Test("Biometric unlock shows password prompt when biometrics unavailable")
    func testBiometricUnlock_FallbackToPassword() async throws {
        // Given
        let mockKeychain = MockKeychainManager()
        mockKeychain.biometricAvailable = false

        let viewModel = DashboardViewModel(keychainManager: mockKeychain)

        let journal = Journal(name: "Test Journal")
        viewModel.journalToUnlock = journal

        // When
        let result = await viewModel.attemptBiometricUnlock(for: journal)

        // Then
        #expect(result == false)
        #expect(viewModel.showingPasswordPrompt == true)
        #expect(mockKeychain.biometricAuthCallCount == 0)
    }

    @Test("Biometric unlock fails when cancelled")
    func testBiometricUnlock_Cancelled() async throws {
        // Given
        let mockKeychain = MockKeychainManager()
        mockKeychain.biometricAvailable = true
        mockKeychain.biometricAuthResult = false // User cancelled

        let viewModel = DashboardViewModel(keychainManager: mockKeychain)

        let journal = Journal(name: "Test Journal")
        viewModel.journalToUnlock = journal

        // When
        let result = await viewModel.attemptBiometricUnlock(for: journal)

        // Then
        #expect(result == false)
        #expect(viewModel.shouldNavigateToJournal == false)
        #expect(viewModel.showingPasswordPrompt == true)
    }

    @Test("Biometric unlock respects lockout state")
    func testBiometricUnlock_RespectsLockout() async throws {
        // Given
        let mockKeychain = MockKeychainManager()
        mockKeychain.biometricAvailable = true

        let viewModel = DashboardViewModel(keychainManager: mockKeychain)

        let journal = Journal(name: "Test Journal")
        viewModel.journalToUnlock = journal
        viewModel.setLockedJournal(journal.id)

        // When
        let result = await viewModel.attemptBiometricUnlock(for: journal)

        // Then
        #expect(result == false)
        #expect(viewModel.showingPasswordPrompt == true)
        #expect(viewModel.lockoutMessage == "Too many failed attempts. Try again in a few minutes.")
        #expect(mockKeychain.biometricAuthCallCount == 0)
    }

    // MARK: - Settings Password Tests

    @Test("Verify password for settings succeeds")
    func testVerifyPasswordForSettings_Success() async throws {
        // Given
        let mockKeychain = MockKeychainManager()
        let viewModel = DashboardViewModel(keychainManager: mockKeychain)

        let journal = Journal(name: "Test Journal")
        try mockKeychain.savePassword("password123", for: journal.id.uuidString)
        viewModel.journalForSettings = journal

        // When
        let result = viewModel.verifyPasswordForSettings("password123")

        // Then
        #expect(result == true)
        #expect(viewModel.showingPasswordPromptForSettings == false)
        #expect(viewModel.showingSettings == true)
        #expect(viewModel.selectedJournal?.id == journal.id)
    }

    @Test("Verify password for settings tracks failed attempts")
    func testVerifyPasswordForSettings_TracksFailedAttempts() async throws {
        // Given
        let mockKeychain = MockKeychainManager()
        let viewModel = DashboardViewModel(keychainManager: mockKeychain)

        let journal = Journal(name: "Test Journal")
        try mockKeychain.savePassword("correct", for: journal.id.uuidString)
        viewModel.journalForSettings = journal

        // When - Make 3 failed attempts
        for _ in 1...3 {
            _ = viewModel.verifyPasswordForSettings("wrong")
        }

        // Then
        #expect(viewModel.failedAttempts[journal.id] == 3)
        #expect(viewModel.lockoutMessage == "2 attempts remaining")
    }

    // MARK: - Journal Deletion Tests

    @Test("Deleting password-protected journal cleans up keychain")
    func testDeleteJournal_CleansUpPassword() async throws {
        // Given
        let mockKeychain = MockKeychainManager()
        let viewModel = DashboardViewModel(keychainManager: mockKeychain)
        let container = try ModelContainer(for: Journal.self, Log.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)

        let journal = Journal(name: "Test Journal")
        journal.isPasswordProtected = true
        try mockKeychain.savePassword("password123", for: journal.id.uuidString)
        context.insert(journal)
        try context.save()

        // When
        viewModel.deleteJournal(journal, modelContext: context)

        // Then
        #expect(mockKeychain.deletePasswordCallCount == 1)
        #expect(mockKeychain.savedPasswords[journal.id.uuidString] == nil)
    }

    @Test("Deleting journal cleans up failed attempts and lockout state")
    func testDeleteJournal_CleansUpLockoutState() async throws {
        // Given
        let mockKeychain = MockKeychainManager()
        let viewModel = DashboardViewModel(keychainManager: mockKeychain)
        let container = try ModelContainer(for: Journal.self, Log.self, configurations: ModelConfiguration(isStoredInMemoryOnly: true))
        let context = ModelContext(container)

        let journal = Journal(name: "Test Journal")
        journal.isPasswordProtected = true
        context.insert(journal)
        try context.save()

        // Set up lockout state
        viewModel.setFailedAttempts(5, for: journal.id)
        viewModel.setLockedJournal(journal.id)

        // When
        viewModel.deleteJournal(journal, modelContext: context)

        // Then
        #expect(viewModel.failedAttempts[journal.id] == nil)
        #expect(viewModel.lockedJournals.contains(journal.id) == false)
    }

    // MARK: - State Cleanup Tests

    @Test("Cancel password prompt cleans up state when not navigating")
    func testCancelPasswordPrompt_CleansUpState() async throws {
        // Given
        let mockKeychain = MockKeychainManager()
        let viewModel = DashboardViewModel(keychainManager: mockKeychain)

        let journal = Journal(name: "Test Journal")
        viewModel.journalToUnlock = journal
        viewModel.showingPasswordPrompt = true
        viewModel.lockoutMessage = "Some message"
        // shouldNavigateToJournal is false (default), so journalToUnlock should be cleared

        // When
        viewModel.cancelPasswordPrompt()

        // Then
        #expect(viewModel.showingPasswordPrompt == false)
        #expect(viewModel.journalToUnlock == nil)
        #expect(viewModel.lockoutMessage == nil)
    }

    @Test("Cancel password prompt preserves journalToUnlock when navigating")
    func testCancelPasswordPrompt_PreservesJournalWhenNavigating() async throws {
        // Given
        let mockKeychain = MockKeychainManager()
        let viewModel = DashboardViewModel(keychainManager: mockKeychain)

        let journal = Journal(name: "Test Journal")
        viewModel.journalToUnlock = journal
        viewModel.showingPasswordPrompt = true
        viewModel.lockoutMessage = "Some message"

        // Simulate successful password entry - about to navigate
        try mockKeychain.savePassword("password123", for: journal.id.uuidString)
        _ = viewModel.verifyPassword("password123")
        // Now shouldNavigateToJournal is true

        // When - Sheet dismisses and calls cancelPasswordPrompt
        viewModel.cancelPasswordPrompt()

        // Then - journalToUnlock should NOT be cleared because we're navigating
        #expect(viewModel.showingPasswordPrompt == false)
        #expect(viewModel.journalToUnlock != nil)
        #expect(viewModel.journalToUnlock?.id == journal.id)
    }

    @Test("Cancel password prompt for settings cleans up state")
    func testCancelPasswordPromptForSettings_CleansUpState() async throws {
        // Given
        let mockKeychain = MockKeychainManager()
        let viewModel = DashboardViewModel(keychainManager: mockKeychain)

        let journal = Journal(name: "Test Journal")
        viewModel.journalForSettings = journal
        viewModel.showingPasswordPromptForSettings = true
        viewModel.lockoutMessage = "Some message"

        // When
        viewModel.cancelPasswordPromptForSettings()

        // Then
        #expect(viewModel.showingPasswordPromptForSettings == false)
        #expect(viewModel.journalForSettings == nil)
        #expect(viewModel.lockoutMessage == nil)
    }
}
