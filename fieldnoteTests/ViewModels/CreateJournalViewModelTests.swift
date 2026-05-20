//
//  CreateJournalViewModelTests.swift
//  fieldnoteTests
//
//  Created by David Contreras on 5/9/26.
//

import Testing
@testable import fieldnote

@MainActor
struct CreateJournalViewModelTests {

    // MARK: - Button State Tests (Bottom Sheet)

    @Test("Create button is disabled when journal name is empty")
    func testButtonState_disabledWhenEmpty() {
        // Given: New ViewModel with empty name
        let viewModel = CreateJournalViewModel()

        // Then: Button should be disabled
        #expect(viewModel.isValid == false)
    }

    @Test("Create button is enabled when journal name is valid")
    func testButtonState_enabledWhenValid() {
        // Given: ViewModel with valid name
        let viewModel = CreateJournalViewModel()
        viewModel.journalName = "Olympic National Park"

        // Then: Button should be enabled
        #expect(viewModel.isValid == true)
    }

    @Test("Create button is disabled when journal name is only whitespace")
    func testButtonState_disabledForWhitespace() {
        // Given: ViewModel with whitespace-only name
        let viewModel = CreateJournalViewModel()
        viewModel.journalName = "   "

        // Then: Button should be disabled
        #expect(viewModel.isValid == false)
    }

    @Test("Create button is disabled when journal name is only tabs and newlines")
    func testButtonState_disabledForTabsNewlines() {
        // Given: ViewModel with tabs/newlines
        let viewModel = CreateJournalViewModel()
        viewModel.journalName = "\t\n\t\n"

        // Then: Button should be disabled
        #expect(viewModel.isValid == false)
    }

    @Test("Create button is enabled when journal name has leading/trailing whitespace")
    func testButtonState_enabledWithTrimmedContent() {
        // Given: ViewModel with valid name and whitespace
        let viewModel = CreateJournalViewModel()
        viewModel.journalName = "  Cedar River Watershed  "

        // Then: Button should be enabled (content exists after trim)
        #expect(viewModel.isValid == true)
    }

    // MARK: - Validation Edge Cases

    @Test("Single character name is valid")
    func testValidation_singleCharacter() {
        // Given: Single character name
        let viewModel = CreateJournalViewModel()
        viewModel.journalName = "A"

        // Then: Should be valid
        #expect(viewModel.isValid == true)
    }

    @Test("Very long name is valid")
    func testValidation_longName() {
        // Given: Very long journal name
        let viewModel = CreateJournalViewModel()
        viewModel.journalName = String(repeating: "A", count: 1000)

        // Then: Should be valid (no length limit currently)
        #expect(viewModel.isValid == true)
    }

    @Test("Name with special characters is valid")
    func testValidation_specialCharacters() {
        // Given: Name with special characters
        let viewModel = CreateJournalViewModel()
        viewModel.journalName = "My Journal! 🌲 #1"

        // Then: Should be valid
        #expect(viewModel.isValid == true)
    }

    @Test("Name with emojis is valid")
    func testValidation_emojis() {
        // Given: Name with only emojis
        let viewModel = CreateJournalViewModel()
        viewModel.journalName = "🌲🏔️🌊"

        // Then: Should be valid
        #expect(viewModel.isValid == true)
    }

    // MARK: - Reset Tests

    @Test("Reset clears journal name")
    func testReset_clearsName() {
        // Given: ViewModel with a name
        let viewModel = CreateJournalViewModel()
        viewModel.journalName = "Test Journal"
        #expect(!viewModel.journalName.isEmpty)

        // When: Reset
        viewModel.reset()

        // Then: Name should be empty
        #expect(viewModel.journalName.isEmpty)
    }

    @Test("Reset makes button invalid")
    func testReset_invalidatesButton() {
        // Given: ViewModel with valid name
        let viewModel = CreateJournalViewModel()
        viewModel.journalName = "Test Journal"
        #expect(viewModel.isValid == true)

        // When: Reset
        viewModel.reset()

        // Then: Button should be invalid
        #expect(viewModel.isValid == false)
    }

    // MARK: - Reactive State Tests

    @Test("isValid updates reactively when name changes")
    func testReactive_isValidUpdates() {
        // Given: ViewModel starts empty (invalid)
        let viewModel = CreateJournalViewModel()
        #expect(viewModel.isValid == false)

        // When: Set valid name
        viewModel.journalName = "Test"

        // Then: Should become valid
        #expect(viewModel.isValid == true)

        // When: Clear name
        viewModel.journalName = ""

        // Then: Should become invalid
        #expect(viewModel.isValid == false)
    }
}
