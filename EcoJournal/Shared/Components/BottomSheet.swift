//
//  BottomSheet.swift
//  EcoJournal
//
//  Created by David Contreras on 5/9/26.
//

import SwiftUI

struct BottomSheet<Content: View>: View {
    let title: String
    let actionButtonText: String
    let isActionEnabled: Bool
    let onAction: () -> Void
    let detents: Set<PresentationDetent>
    @ViewBuilder let content: Content

    @Environment(\.dismiss) private var dismiss

    init(
        title: String,
        actionButtonText: String,
        isActionEnabled: Bool,
        detents: Set<PresentationDetent> = [.height(280), .large],
        onAction: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.actionButtonText = actionButtonText
        self.isActionEnabled = isActionEnabled
        self.detents = detents
        self.onAction = onAction
        self.content = content()
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Spacer()
                Text(title)
                    .font(.headline(17, weight: .semibold))
                Spacer()
            }
            .padding(.vertical, 16)
            .overlay(alignment: .trailing) {
                Button(actionButtonText) {
                    onAction()
                    dismiss()
                }
                .font(.body(17, weight: .regular))
                .foregroundColor(isActionEnabled ? .blue : .gray)
                .disabled(!isActionEnabled)
                .padding(.trailing, 16)
            }

            Divider()

            // Content
            content
                .padding(24)

            Spacer()
        }
        .background(Color.surfaceBackground)
        .presentationDetents(detents)
        .presentationDragIndicator(.visible)
    }
}

#Preview("Enabled Button") {
    BottomSheet(
        title: "New Journal",
        actionButtonText: "Create",
        isActionEnabled: true,
        onAction: { print("Action tapped") }
    ) {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Journal Name")
                    .font(.body(13, weight: .regular))
                    .foregroundColor(.onSurfaceVariant)
                    .textCase(.uppercase)
                TextField("Enter name", text: .constant("My Field Notes"))
                    .font(.body(17))
                    .textFieldStyle(.roundedBorder)
            }

            Text("Create a new journal to organize your field observations")
                .font(.body(14))
                .foregroundColor(.secondaryColor)
        }
    }
}

#Preview("Disabled Button") {
    BottomSheet(
        title: "New Journal",
        actionButtonText: "Create",
        isActionEnabled: false,
        onAction: { print("Action tapped") }
    ) {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Journal Name")
                    .font(.body(13, weight: .regular))
                    .foregroundColor(.onSurfaceVariant)
                    .textCase(.uppercase)
                TextField("Enter name", text: .constant(""))
                    .font(.body(17))
                    .textFieldStyle(.roundedBorder)
            }

            Text("Create a new journal to organize your field observations")
                .font(.body(14))
                .foregroundColor(.secondaryColor)
        }
    }
}

#Preview("Settings Example") {
    BottomSheet(
        title: "Journal Settings",
        actionButtonText: "Save",
        isActionEnabled: true,
        onAction: { print("Save tapped") }
    ) {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Journal Name")
                    .font(.body(13, weight: .regular))
                    .foregroundColor(.onSurfaceVariant)
                    .textCase(.uppercase)
                TextField("Enter name", text: .constant("Alpine Meadows"))
                    .font(.body(17))
                    .textFieldStyle(.roundedBorder)
            }

            VStack(alignment: .leading, spacing: 8) {
                Text("Theme")
                    .font(.body(13, weight: .regular))
                    .foregroundColor(.onSurfaceVariant)
                    .textCase(.uppercase)
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color.primaryColor)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "leaf.fill")
                                .foregroundColor(.white)
                        )
                    Circle()
                        .fill(Color.secondaryColor)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "drop.fill")
                                .foregroundColor(.white)
                        )
                    Circle()
                        .fill(Color.tertiaryColor)
                        .frame(width: 44, height: 44)
                        .overlay(
                            Image(systemName: "mountain.2.fill")
                                .foregroundColor(.white)
                        )
                }
            }

            Toggle("Password Protected", isOn: .constant(false))
                .font(.body(15))

            Button(role: .destructive) {
                print("Delete tapped")
            } label: {
                Text("Delete Journal")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
    }
}
