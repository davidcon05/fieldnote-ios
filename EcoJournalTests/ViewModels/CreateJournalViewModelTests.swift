//
//  CreateJournalViewModelTests.swift
//  EcoJournalTests
//
//  Created by David Contreras on 5/9/26.
//

import Testing
@testable import EcoJournal

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

    // MARK: - Reset Tests

    @Test("Reset clears journal name")
    func testReset_clearsName() {
        // Given: ViewModel with a name
        let viewModel = CreateJournalViewModel()
        viewModel.journalName = "Test Journal"
        #expect(!viewModel.journalName.isEmpty)

        // When: Reset
        viewModel.reset()

        // Then: Name should be empty and invalid
        #expect(viewModel.journalName.isEmpty)
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
