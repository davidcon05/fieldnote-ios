//
//  FilterSheet.swift
//  EcoJournal
//
//  Created by David Contreras on 5/13/26.
//

import SwiftUI

struct FilterSheet: View {
    @Binding var selectedOption: SortOption
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Sort By")
                    .font(.headline(20, weight: .bold))
                    .foregroundColor(.onSurface)

                Spacer()

                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.tertiaryColor)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 16)

            Divider()

            // Options list
            VStack(spacing: 0) {
                ForEach(SortOption.allCases) { option in
                    Button(action: {
                        selectedOption = option
                        dismiss()
                    }) {
                        HStack(spacing: 16) {
                            // Icon
                            Image(systemName: option.systemImage)
                                .font(.system(size: 18))
                                .foregroundColor(selectedOption == option ? .primaryColor : .secondaryColor)
                                .frame(width: 24)

                            // Label
                            Text(option.rawValue)
                                .font(.body(16))
                                .foregroundColor(.onSurface)

                            Spacer()

                            // Checkmark
                            if selectedOption == option {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.primaryColor)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .padding(.horizontal, 24)
                        .padding(.vertical, 16)
                        .background(selectedOption == option ? Color.primaryContainer.opacity(0.1) : Color.clear)
                    }
                    .buttonStyle(.plain)

                    if option != SortOption.allCases.last {
                        Divider()
                            .padding(.leading, 64)
                    }
                }
            }
        }
        .background(Color.surfaceBackground)
        .presentationDetents([.height(320)])
        .presentationDragIndicator(.visible)
    }
}

#Preview {
    FilterSheet(selectedOption: .constant(.mostRecent))
}
