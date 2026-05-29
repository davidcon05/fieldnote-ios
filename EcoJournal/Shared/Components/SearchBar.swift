//
//  SearchBar.swift
//  EcoJournal
//
//  Created by David Contreras on 5/13/26.
//

import SwiftUI

struct SearchBar: View {
    @Binding var text: String
    let placeholder: String

    var body: some View {
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

            // Clear button (only show when text is not empty)
            if !text.isEmpty {
                Button(action: { text = "" }) {
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
}

#Preview("Empty") {
    SearchBar(text: .constant(""), placeholder: "Search Journals...")
        .padding()
}

#Preview("With Text") {
    SearchBar(text: .constant("Olympic"), placeholder: "Search logs...")
        .padding()
}
