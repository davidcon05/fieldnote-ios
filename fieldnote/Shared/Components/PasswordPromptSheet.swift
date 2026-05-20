//
//  PasswordPromptSheet.swift
//  fieldnote
//
//  Created by David Contreras on 5/9/26.
//

import SwiftUI

struct PasswordPromptSheet: View {
    let title: String
    let message: String
    let actionButtonText: String
    let onSubmit: (String) -> Bool // Returns true if password is correct
    let lockoutMessage: String? // Optional lockout message from ViewModel
    let onBiometricAuth: (() async -> Bool)? // Optional biometric authentication callback
    let keychainManager: KeychainManaging

    @State private var password = ""
    @State private var isShaking = false
    @State private var showError = false
    @State private var isPasswordVisible = false

    @Environment(\.dismiss) private var dismiss

    private var biometricType: BiometricType {
        keychainManager.getBiometricType()
    }

    private var showBiometricButton: Bool {
        onBiometricAuth != nil && biometricType != .none
    }

    // Password requirements
    private var passwordMinLength: Int { 8 }
    private var meetsMinLength: Bool { password.count >= passwordMinLength }
    private var isPasswordValid: Bool { meetsMinLength }

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
                    let isValid = onSubmit(password)
                    if isValid {
                        dismiss()
                    } else {
                        triggerError()
                    }
                }
                .font(.body(17, weight: .semibold))
                .foregroundColor(!isPasswordValid ? .gray : .blue)
                .disabled(!isPasswordValid)
                .padding(.trailing, 16)
            }

            Divider()

            // Content
            VStack(alignment: .leading, spacing: 16) {
                Text(message)
                    .font(.body(15))
                    .foregroundColor(.onSurfaceVariant)

                HStack {
                    Group {
                        if isPasswordVisible {
                            TextField("Enter password", text: $password)
                        } else {
                            SecureField("Enter password", text: $password)
                        }
                    }
                    .font(.body(17))
                    .onChange(of: password) { _, _ in
                        showError = false
                    }
                    .onSubmit {
                        if !password.isEmpty {
                            let isValid = onSubmit(password)
                            if isValid {
                                dismiss()
                            } else {
                                triggerError()
                            }
                        }
                    }

                    Button(action: {
                        isPasswordVisible.toggle()
                    }) {
                        Image(systemName: isPasswordVisible ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.gray)
                            .font(.system(size: 16))
                    }
                    .buttonStyle(.plain)
                }
                .textFieldStyle(.roundedBorder)
                .modifier(ShakeEffect(animatableData: isShaking ? 1 : 0))

                // Password requirements indicator
                HStack(spacing: 4) {
                    Image(systemName: meetsMinLength ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 14))
                        .foregroundColor(meetsMinLength ? .green : .gray)
                    Text("At least \(passwordMinLength) characters")
                        .font(.body(13))
                        .foregroundColor(meetsMinLength ? .green : .gray)
                }
                .padding(.top, 4)

                if let lockoutMsg = lockoutMessage {
                    Text(lockoutMsg)
                        .font(.body(13))
                        .foregroundColor(.red)
                } else if showError {
                    Text("Incorrect password")
                        .font(.body(13))
                        .foregroundColor(.red)
                }

                // Biometric authentication button
                if showBiometricButton {
                    Button(action: {
                        Task {
                            if let onBiometricAuth = onBiometricAuth {
                                let success = await onBiometricAuth()
                                if success {
                                    dismiss()
                                }
                            }
                        }
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: biometricType.icon)
                                .font(.system(size: 16))
                            Text("Use \(biometricType.displayName)")
                                .font(.body(15))
                        }
                        .foregroundColor(.blue)
                    }
                    .padding(.top, 12)
                }
            }
            .padding(24)

            Spacer()
        }
        .background(Color.surfaceBackground)
        .presentationDetents([.height(showBiometricButton ? 260 : 220)])
        .presentationDragIndicator(.visible)
    }

    func triggerError() {
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)

        // Shake animation
        withAnimation(.default) {
            isShaking = true
            showError = true
        }

        // Reset shake after animation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isShaking = false
        }

        // Clear password field
        password = ""
    }
}

// MARK: - Shake Effect

struct ShakeEffect: GeometryEffect {
    var animatableData: CGFloat

    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(
            CGAffineTransform(translationX: 10 * sin(animatableData * .pi * 2), y: 0)
        )
    }
}

// MARK: - Preview

#Preview("Default State") {
    PasswordPromptSheet(
        title: "Enter Password",
        message: "This journal is password protected. Enter the password to continue.",
        actionButtonText: "Unlock",
        onSubmit: { password in
            print("Password entered: \(password)")
            return password == "correct"
        },
        lockoutMessage: nil,
        onBiometricAuth: nil,
        keychainManager: KeychainManager()
    )
}

#Preview("With Lockout Message") {
    PasswordPromptSheet(
        title: "Enter Password",
        message: "This journal is password protected. Enter the password to continue.",
        actionButtonText: "Unlock",
        onSubmit: { password in
            print("Password entered: \(password)")
            return false // Always fail to show lockout
        },
        lockoutMessage: "Too many failed attempts. Try again in 5 minutes.",
        onBiometricAuth: nil,
        keychainManager: KeychainManager()
    )
}

#Preview("With Biometric Auth") {
    PasswordPromptSheet(
        title: "Enter Password",
        message: "This journal is password protected. Enter the password to continue.",
        actionButtonText: "Unlock",
        onSubmit: { password in
            print("Password entered: \(password)")
            return password == "correct"
        },
        lockoutMessage: nil,
        onBiometricAuth: {
            print("Biometric auth requested")
            return true
        },
        keychainManager: KeychainManager()
    )
}
