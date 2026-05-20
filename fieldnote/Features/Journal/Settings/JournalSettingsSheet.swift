//
//  JournalSettingsSheet.swift
//  fieldnote
//
//  Created by David Contreras on 5/9/26.
//

import SwiftUI
import SwiftData

struct JournalSettingsSheet: View {
    @Binding var journal: Journal
    let onSave: () -> Void
    let onDelete: () -> Void
    let keychainManager: KeychainManaging

    @State private var journalName: String
    @State private var selectedTheme: JournalTheme
    @State private var isPasswordProtected: Bool
    @State private var showDeleteConfirmation = false
    @State private var showPasswordPrompt = false
    @State private var showPasswordWarning = false
    @State private var showChangePasswordPrompt = false
    @State private var showVerifyCurrentPasswordPrompt = false
    @State private var pendingPasswordState = false

    init(
        journal: Binding<Journal>,
        onSave: @escaping () -> Void,
        onDelete: @escaping () -> Void,
        keychainManager: KeychainManaging = KeychainManager()
    ) {
        self._journal = journal
        self.onSave = onSave
        self.onDelete = onDelete
        self.keychainManager = keychainManager

        // Initialize state from journal
        _journalName = State(initialValue: journal.wrappedValue.name)
        _selectedTheme = State(initialValue: JournalTheme.from(
            icon: journal.wrappedValue.themeIcon,
            colorHex: journal.wrappedValue.themeColorHex
        ))
        _isPasswordProtected = State(initialValue: journal.wrappedValue.isPasswordProtected)
    }

    private var isValid: Bool {
        !journalName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var hasChanges: Bool {
        journalName != journal.name ||
        selectedTheme.icon != journal.themeIcon ||
        selectedTheme.colorHex != journal.themeColorHex ||
        isPasswordProtected != journal.isPasswordProtected
    }

    var body: some View {
        BottomSheet(
            title: "Journal Settings",
            actionButtonText: "Save",
            isActionEnabled: isValid && hasChanges,
            detents: [.height(560), .large],
            onAction: saveChanges
        ) {
            VStack(alignment: .leading, spacing: 20) {
                // Journal Name
                VStack(alignment: .leading, spacing: 8) {
                    Text("Journal Name")
                        .font(.body(13, weight: .regular))
                        .foregroundColor(.onSurfaceVariant)
                        .textCase(.uppercase)
                    TextField("Enter name", text: $journalName)
                        .font(.body(17))
                        .textFieldStyle(.roundedBorder)
                }

                // Theme Picker
                VStack(alignment: .leading, spacing: 8) {
                    Text("Theme")
                        .font(.body(13, weight: .regular))
                        .foregroundColor(.onSurfaceVariant)
                        .textCase(.uppercase)

                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 60))], spacing: 12) {
                        ForEach(JournalTheme.themes.indices, id: \.self) { index in
                            let theme = JournalTheme.themes[index]
                            ThemeButton(
                                theme: theme,
                                isSelected: selectedTheme.colorHex == theme.colorHex,
                                action: { selectedTheme = theme }
                            )
                        }
                    }
                }

                // Password Protection Toggle
                Toggle("Password Protected", isOn: $isPasswordProtected)
                    .font(.body(15))
                    .onChange(of: isPasswordProtected) { oldValue, newValue in
                        if newValue && !oldValue {
                            // Turning ON password protection
                            // Only show prompt if password isn't already saved
                            if (try? keychainManager.getPassword(for: journal.id.uuidString)) == nil {
                                showPasswordWarning = true
                                isPasswordProtected = false // Reset until password is set
                            }
                        } else if !newValue && oldValue {
                            // Turning OFF password protection
                            do {
                                try keychainManager.deletePassword(for: journal.id.uuidString)
                            } catch {
                                print("Failed to delete password: \(error)")
                            }
                        }
                    }

                // Change Password Button (only show if password is enabled)
                if isPasswordProtected {
                    Button("Change Password") {
                        showVerifyCurrentPasswordPrompt = true
                    }
                    .font(.body(15))
                    .foregroundColor(.blue)
                }

                // Delete Button
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Text("Delete Journal")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
        }
        .alert("Enable Password Protection?", isPresented: $showPasswordWarning) {
            Button("Cancel", role: .cancel) {
                isPasswordProtected = false
            }
            Button("Continue") {
                showPasswordPrompt = true
            }
        } message: {
            let biometricType = keychainManager.getBiometricType()
            let biometricText = biometricType != .none ? " You can use \(biometricType.displayName) as a backup to unlock." : ""
            return Text("⚠️ Important: If you forget your password, this journal cannot be recovered.\(biometricText) Make sure to remember your password or store it securely.")
        }
        .alert("Delete Journal?", isPresented: $showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                onDelete()
            }
        } message: {
            Text("This will permanently delete \"\(journal.name)\" and all its logs. This action cannot be undone.")
        }
        .sheet(isPresented: $showPasswordPrompt) {
            PasswordPromptSheet(
                title: "Set Password",
                message: "Enter a password to protect this journal",
                actionButtonText: "Save",
                onSubmit: { password in
                    return handlePasswordSet(password)
                },
                lockoutMessage: nil, // No lockout when setting new password
                onBiometricAuth: nil, // No biometric auth when setting password
                keychainManager: keychainManager
            )
        }
        .sheet(isPresented: $showVerifyCurrentPasswordPrompt) {
            PasswordPromptSheet(
                title: "Verify Current Password",
                message: "Enter your current password to continue",
                actionButtonText: "Verify",
                onSubmit: { password in
                    return handleVerifyCurrentPassword(password)
                },
                lockoutMessage: nil,
                onBiometricAuth: nil,
                keychainManager: keychainManager
            )
        }
        .sheet(isPresented: $showChangePasswordPrompt) {
            PasswordPromptSheet(
                title: "New Password",
                message: "Enter your new password",
                actionButtonText: "Save",
                onSubmit: { password in
                    return handlePasswordChange(password)
                },
                lockoutMessage: nil,
                onBiometricAuth: nil,
                keychainManager: keychainManager
            )
        }
    }

    private func handlePasswordSet(_ password: String) -> Bool {
        do {
            try keychainManager.savePassword(password, for: journal.id.uuidString)
            isPasswordProtected = true
            return true
        } catch {
            print("Failed to save password: \(error)")
            return false
        }
    }

    private func handleVerifyCurrentPassword(_ password: String) -> Bool {
        let isValid = keychainManager.verifyPassword(password, for: journal.id.uuidString)
        if isValid {
            // Current password verified, show new password prompt
            showVerifyCurrentPasswordPrompt = false
            showChangePasswordPrompt = true
        }
        return isValid
    }

    private func handlePasswordChange(_ newPassword: String) -> Bool {
        do {
            // Save new password (overwrites old one)
            try keychainManager.savePassword(newPassword, for: journal.id.uuidString)
            return true
        } catch {
            print("Failed to change password: \(error)")
            return false
        }
    }

    private func saveChanges() {
        journal.name = journalName
        journal.themeIcon = selectedTheme.icon
        journal.themeColorHex = selectedTheme.colorHex
        journal.isPasswordProtected = isPasswordProtected
        journal.lastModified = Date()
        onSave()
    }
}

// MARK: - Theme Button Component

struct ThemeButton: View {
    let theme: JournalTheme
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(theme.color)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Circle()
                            .strokeBorder(
                                isSelected ? Color.onSurface : Color.clear,
                                lineWidth: 3
                            )
                    )

                Image(systemName: theme.icon)
                    .font(.system(size: 24))
                    .foregroundColor(.white)

                if isSelected {
                    Circle()
                        .fill(Color.onSurface)
                        .frame(width: 20, height: 20)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .offset(x: 22, y: -22)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("No Password Protection") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Journal.self, Log.self, configurations: config)

    let journal = Journal(name: "Alpine Meadows")
    journal.isPasswordProtected = false
    for i in 1...12 {
        journal.logs.append(Log(notes: "Observation \(i)"))
    }
    container.mainContext.insert(journal)

    return JournalSettingsSheet(
        journal: .constant(journal),
        onSave: { print("Settings saved") },
        onDelete: { print("Journal deleted") },
        keychainManager: KeychainManager()
    )
    .modelContainer(container)
}

#Preview("With Password Protection") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: Journal.self, Log.self, configurations: config)

    let journal = Journal(name: "Secure Field Notes")
    journal.isPasswordProtected = true
    for i in 1...8 {
        journal.logs.append(Log(notes: "Confidential observation \(i)"))
    }
    container.mainContext.insert(journal)

    return JournalSettingsSheet(
        journal: .constant(journal),
        onSave: { print("Settings saved") },
        onDelete: { print("Journal deleted") },
        keychainManager: KeychainManager()
    )
    .modelContainer(container)
}
