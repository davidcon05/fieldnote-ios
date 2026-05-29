//
//  XCUIElement+Extensions.swift
//  EcoJournalUITests
//
//  Convenience extensions for XCUIElement
//

import XCTest

extension XCUIElement {
    /// Tap the element and type text into it, then dismiss keyboard
    @discardableResult
    func enterText(_ text: String) -> Self {
        tap()
        typeText(text)
        typeText("\n") // Dismiss keyboard by hitting return
        return self
    }

    /// Clear existing text and enter new text
    @discardableResult
    func clearAndEnterText(_ text: String) -> Self {
        tap()

        // Select all and delete
        if let stringValue = value as? String, !stringValue.isEmpty {
            // Press delete for each character
            let deleteString = String(repeating: XCUIKeyboardKey.delete.rawValue, count: stringValue.count)
            typeText(deleteString)
        }

        typeText(text)
        return self
    }

    /// Tap and wait for element to exist with timeout
    func tapAndWait(timeout: TimeInterval = 2) -> Bool {
        tap()
        return waitForExistence(timeout: timeout)
    }

    /// Check if element is visible on screen (not just exists)
    func isVisible() -> Bool {
        guard exists, isHittable, !frame.isEmpty else {
            return false
        }
        let window = XCUIApplication().windows.element(boundBy: 0)
        return window.frame.contains(frame)
    }

    // MARK: - Scroll Methods

    enum ScrollDistance {
        case search
        case belowFold
        case screen

        var dragDistance: CGFloat {
            switch self {
            case .search: return 0.20
            case .belowFold: return 0.66
            case .screen: return 1
            }
        }
    }

    enum ScrollDirection {
        case up
        case down
    }

    /// Scroll the element by dragging using normalized coordinates
    /// - Parameters:
    ///   - distance: Predefined scroll distance (.search, .belowFold, .screen)
    ///   - direction: Scroll direction (.up or .down)
    ///   - velocity: Scroll velocity (default: .fast)
    /// - Returns: Self for chaining
    @discardableResult
    func scroll(
        _ distance: ScrollDistance,
        direction: ScrollDirection = .up,
        velocity: XCUIGestureVelocity = .fast
    ) -> Self {
        // Start from the center of the element
        let start = coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.5))

        // Calculate finish point based on direction and distance
        // Scrolling UP means dragging DOWN (decreasing Y coordinate)
        // Scrolling DOWN means dragging UP (increasing Y coordinate)
        let dragAmount = distance.dragDistance
        let finishY = direction == .up ? 0.5 - dragAmount : 0.5 + dragAmount
        let finish = coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: finishY))

        // Perform drag gesture with velocity control
        start.press(forDuration: 0, thenDragTo: finish, withVelocity: velocity, thenHoldForDuration: 0)
        return self
    }

    /// Scroll this element's containing scroll view - always scrolls the specified amount
    /// This is deterministic: it ALWAYS performs the scroll regardless of visibility
    /// Use this when you need to ensure element is fully visible/interactable
    /// - Parameters:
    ///   - maxAttempts: Number of scroll attempts (default: 1)
    ///   - distance: Scroll distance to use (default: .screen for full screen scroll)
    ///   - direction: Scroll direction (default: .up)
    ///   - velocity: Scroll velocity (default: .fast)
    /// - Returns: Self for chaining
    @discardableResult
    func scrollToElement(
        maxAttempts: Int = 1,
        distance: ScrollDistance = .screen,
        direction: ScrollDirection = .up,
        velocity: XCUIGestureVelocity = .fast
    ) -> Self {
        // Find the scroll view and scroll it deterministically
        let app = XCUIApplication()
        let scrollView = app.scrollViews.element(boundBy: 0)

        // Always perform the requested number of scrolls - no delays needed
        for _ in 0..<maxAttempts {
            scrollView.scroll(distance, direction: direction, velocity: velocity)
        }

        return self
    }

    /// Scroll until a target element becomes visible/hittable
    /// - Parameters:
    ///   - element: The element to scroll to
    ///   - maxAttempts: Maximum number of scroll attempts (default: 5)
    ///   - distance: Scroll distance to use (default: .search for small increments)
    ///   - direction: Scroll direction (default: .up)
    ///   - velocity: Scroll velocity (default: .fast)
    /// - Returns: Self for chaining
    @discardableResult
    func scrollToElement(
        _ element: XCUIElement,
        maxAttempts: Int = 5,
        distance: ScrollDistance = .search,
        direction: ScrollDirection = .up,
        velocity: XCUIGestureVelocity = .fast
    ) -> Self {
        var attempts = 0
        while attempts < maxAttempts {
            // Check if element is visible and hittable
            if element.isVisible() {
                return self
            }

            // Scroll in the specified direction with velocity
            scroll(distance, direction: direction, velocity: velocity)
            attempts += 1

            // Reduced delay for faster scrolling
            Thread.sleep(forTimeInterval: 0.1)
        }

        return self
    }

    /// Scroll to element, then tap it
    @discardableResult
    func scrollToAndTap() -> Self {
        scrollToElement()
        tap()
        return self
    }

    /// Scroll to element, then assert it exists
    @discardableResult
    func scrollToAndAssertExists(file: StaticString = #file, line: UInt = #line) -> Self {
        scrollToElement()
        XCTAssertTrue(exists, "Element should exist after scrolling", file: file, line: line)
        return self
    }
}

// MARK: - Debug Utilities

extension XCUIApplication {
    /// Print the full view hierarchy for debugging
    func printViewHierarchy() {
        print("=== VIEW HIERARCHY ===")
        print(debugDescription)
        print("======================\n")
    }

    /// Search and print all elements matching a search term (case-insensitive)
    /// Searches both identifier and label properties
    /// - Parameter searchTerm: The term to search for in identifiers and labels
    func printElementsContaining(_ searchTerm: String) {
        print("=== ELEMENTS CONTAINING '\(searchTerm)' ===")
        let allElements = descendants(matching: .any)
        var foundCount = 0

        for i in 0..<min(allElements.count, 1000) { // Limit to first 1000 for performance
            let element = allElements.element(boundBy: i)
            let identifier = element.identifier.lowercased()
            let label = element.label.lowercased()
            let search = searchTerm.lowercased()

            if identifier.contains(search) || label.contains(search) {
                let elementTypeName = elementTypeName(for: element.elementType)
                print("[\(elementTypeName)] identifier: '\(element.identifier)' | label: '\(element.label)' | exists: \(element.exists)")
                foundCount += 1
            }
        }

        print("Found \(foundCount) elements")
        print("==========================================\n")
    }

    /// Print details about a specific element by identifier
    /// - Parameter identifier: The accessibility identifier to search for
    func printElementDetails(identifier: String) {
        print("=== ELEMENT DETAILS: '\(identifier)' ===")

        // Try different element types
        let elementTypes: [(XCUIElement.ElementType, String)] = [
            (.any, "any"),
            (.other, "other"),
            (.button, "button"),
            (.textField, "textField"),
            (.staticText, "staticText"),
            (.image, "image"),
            (.cell, "cell"),
            (.scrollView, "scrollView")
        ]

        for (type, name) in elementTypes {
            let element = descendants(matching: type)[identifier]
            if element.exists {
                print("✅ Found as .\(name): exists=\(element.exists), hittable=\(element.isHittable), frame=\(element.frame)")
            }
        }

        print("=========================================\n")
    }

    /// Helper to get human-readable element type name
    private func elementTypeName(for type: XCUIElement.ElementType) -> String {
        switch type {
        case .any: return "Any"
        case .other: return "Other"
        case .application: return "Application"
        case .group: return "Group"
        case .window: return "Window"
        case .sheet: return "Sheet"
        case .drawer: return "Drawer"
        case .alert: return "Alert"
        case .dialog: return "Dialog"
        case .button: return "Button"
        case .radioButton: return "RadioButton"
        case .radioGroup: return "RadioGroup"
        case .checkBox: return "CheckBox"
        case .disclosureTriangle: return "DisclosureTriangle"
        case .popUpButton: return "PopUpButton"
        case .comboBox: return "ComboBox"
        case .menuButton: return "MenuButton"
        case .toolbarButton: return "ToolbarButton"
        case .popover: return "Popover"
        case .keyboard: return "Keyboard"
        case .key: return "Key"
        case .navigationBar: return "NavigationBar"
        case .tabBar: return "TabBar"
        case .tabGroup: return "TabGroup"
        case .toolbar: return "Toolbar"
        case .statusBar: return "StatusBar"
        case .table: return "Table"
        case .tableRow: return "TableRow"
        case .tableColumn: return "TableColumn"
        case .outline: return "Outline"
        case .outlineRow: return "OutlineRow"
        case .browser: return "Browser"
        case .collectionView: return "CollectionView"
        case .slider: return "Slider"
        case .pageIndicator: return "PageIndicator"
        case .progressIndicator: return "ProgressIndicator"
        case .activityIndicator: return "ActivityIndicator"
        case .segmentedControl: return "SegmentedControl"
        case .picker: return "Picker"
        case .pickerWheel: return "PickerWheel"
        case .switch: return "Switch"
        case .toggle: return "Toggle"
        case .link: return "Link"
        case .image: return "Image"
        case .icon: return "Icon"
        case .searchField: return "SearchField"
        case .scrollView: return "ScrollView"
        case .scrollBar: return "ScrollBar"
        case .staticText: return "StaticText"
        case .textField: return "TextField"
        case .secureTextField: return "SecureTextField"
        case .datePicker: return "DatePicker"
        case .textView: return "TextView"
        case .menu: return "Menu"
        case .menuItem: return "MenuItem"
        case .menuBar: return "MenuBar"
        case .menuBarItem: return "MenuBarItem"
        case .map: return "Map"
        case .webView: return "WebView"
        case .incrementArrow: return "IncrementArrow"
        case .decrementArrow: return "DecrementArrow"
        case .timeline: return "Timeline"
        case .ratingIndicator: return "RatingIndicator"
        case .valueIndicator: return "ValueIndicator"
        case .splitGroup: return "SplitGroup"
        case .splitter: return "Splitter"
        case .relevanceIndicator: return "RelevanceIndicator"
        case .colorWell: return "ColorWell"
        case .helpTag: return "HelpTag"
        case .matte: return "Matte"
        case .dockItem: return "DockItem"
        case .ruler: return "Ruler"
        case .rulerMarker: return "RulerMarker"
        case .grid: return "Grid"
        case .levelIndicator: return "LevelIndicator"
        case .cell: return "Cell"
        case .layoutArea: return "LayoutArea"
        case .layoutItem: return "LayoutItem"
        case .handle: return "Handle"
        case .stepper: return "Stepper"
        case .tab: return "Tab"
        case .touchBar: return "TouchBar"
        case .statusItem: return "StatusItem"
        @unknown default: return "Unknown(\(type.rawValue))"
        }
    }
}
