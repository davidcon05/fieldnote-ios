//
//  SearchBarWithDropdown.swift
//  fieldnote
//
//  Autocomplete search bar with dropdown suggestions
//  Shows matching items as user types
//

import SwiftUI

struct SearchBarWithDropdown<Item: Identifiable & Equatable>: View {
    @Binding var text: String
    let placeholder: String
    let suggestions: [Item]
    let itemLabel: (Item) -> String
    let itemIcon: ((Item) -> String)?
    let onSelectSuggestion: (Item) -> Void
    let searchFieldIdentifier: String?

    @FocusState private var isFocused: Bool
    @State private var showDropdown = false

    init(
        text: Binding<String>,
        placeholder: String,
        suggestions: [Item],
        itemLabel: @escaping (Item) -> String,
        itemIcon: ((Item) -> String)? = nil,
        searchFieldIdentifier: String? = nil,
        onSelectSuggestion: @escaping (Item) -> Void
    ) {
        self._text = text
        self.placeholder = placeholder
        self.suggestions = suggestions
        self.itemLabel = itemLabel
        self.itemIcon = itemIcon
        self.searchFieldIdentifier = searchFieldIdentifier
        self.onSelectSuggestion = onSelectSuggestion
    }

    var body: some View {
        VStack(spacing: 0) {
            // Search bar - apply accessibility identifier here if provided
            Group {
                searchBar
            }
            .accessibilityElement(children: .contain)
            .accessibilityIdentifier(searchFieldIdentifier ?? "")

            // Dropdown suggestions - isolated from parent identifier
            if !suggestions.isEmpty && !text.isEmpty {
                suggestionDropdown
                    .accessibilityElement(children: .contain)
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: 12) {
            // Magnifying glass icon
            Image(systemName: "magnifyingglass")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.onSurfaceVariant)

            // Text field
            TextField(placeholder, text: $text)
                .font(.body(15))
                .foregroundColor(.onSurface)
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
                .focused($isFocused)
                .onChange(of: text) { _, newValue in
                    // Update showDropdown state
                    showDropdown = !newValue.isEmpty && !suggestions.isEmpty
                }
                .onChange(of: isFocused) { _, focused in
                    // Hide dropdown when focus is lost (for manual use)
                    if !focused {
                        showDropdown = false
                    } else {
                        showDropdown = !text.isEmpty && !suggestions.isEmpty
                    }
                }

            // Clear button (only show when text is not empty)
            if !text.isEmpty {
                Button(action: {
                    text = ""
                    showDropdown = false
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 16))
                        .foregroundColor(.onSurfaceVariant)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(Color.white)
        .cornerRadius(24) // Fully rounded (pill shape)
        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
    }

    private var suggestionDropdown: some View {
        VStack(spacing: 0) {
            ForEach(suggestions.prefix(5)) { suggestion in
                Button(action: {
                    text = itemLabel(suggestion)
                    onSelectSuggestion(suggestion)
                    showDropdown = false
                    isFocused = false
                }) {
                    HStack(spacing: 12) {
                        // Icon (optional)
                        if let icon = itemIcon?(suggestion) {
                            Image(systemName: icon)
                                .font(.system(size: 16))
                                .foregroundColor(.primaryColor)
                                .frame(width: 24)
                        }

                        // Label
                        Text(itemLabel(suggestion))
                            .font(.body(15))
                            .foregroundColor(.onSurface)
                            .frame(maxWidth: .infinity, alignment: .leading)

                        // Chevron
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.onSurfaceVariant)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("searchSuggestion.\(itemLabel(suggestion))")

                if suggestion != suggestions.prefix(5).last {
                    Divider()
                        .padding(.leading, itemIcon != nil ? 52 : 16)
                }
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.top, 4)
        .transition(.opacity.combined(with: .move(edge: .top)))
        .animation(.easeInOut(duration: 0.2), value: showDropdown)
    }
}

// MARK: - String-based convenience initializer

extension SearchBarWithDropdown where Item == SearchSuggestion {
    init(
        text: Binding<String>,
        placeholder: String,
        suggestions: [String],
        icon: String? = nil,
        onSelectSuggestion: @escaping (String) -> Void
    ) {
        let items = suggestions.map { SearchSuggestion(text: $0) }
        self._text = text
        self.placeholder = placeholder
        self.suggestions = items
        self.itemLabel = { $0.text }
        self.itemIcon = icon != nil ? { _ in icon! } : nil
        self.searchFieldIdentifier = nil
        self.onSelectSuggestion = { onSelectSuggestion($0.text) }
    }
}

// MARK: - Helper Types

struct SearchSuggestion: Identifiable, Equatable {
    let id = UUID()
    let text: String
}

// MARK: - Previews

#Preview("Empty Search") {
    SearchBarWithDropdown(
        text: .constant(""),
        placeholder: "Search journals...",
        suggestions: ["Olympic National Park", "Mount Rainier", "North Cascades"],
        icon: "book.closed.fill"
    ) { selected in
        print("Selected: \(selected)")
    }
    .padding()
}

#Preview("With Suggestions") {
    SearchBarWithDropdown(
        text: .constant("Oly"),
        placeholder: "Search journals...",
        suggestions: ["Olympic National Park", "North Cascades"],
        icon: "book.closed.fill"
    ) { selected in
        print("Selected: \(selected)")
    }
    .padding()
}

#Preview("Multiple Suggestions") {
    SearchBarWithDropdown(
        text: .constant("Mount"),
        placeholder: "Search locations...",
        suggestions: [
            "Mount Rainier",
            "Mount Baker",
            "Mount St. Helens",
            "Mount Adams",
            "Mount Hood"
        ],
        icon: "mountain.2.fill"
    ) { selected in
        print("Selected: \(selected)")
    }
    .padding()
}
