//
//  KeychainManager.swift
//  fieldnote
//
//  Created by David Contreras on 5/9/26.
//

import Foundation
import Security
import CryptoKit
import LocalAuthentication

// MARK: - Protocol

protocol KeychainManaging {
    func savePassword(_ password: String, for journalID: String) throws
    func getPassword(for journalID: String) throws -> String
    func verifyPassword(_ enteredPassword: String, for journalID: String) -> Bool
    func deletePassword(for journalID: String) throws
    func isBiometricAvailable() -> Bool
    func getBiometricType() -> BiometricType
    func authenticateWithBiometrics(for journalName: String) async -> Bool
}

// MARK: - Implementation

final class KeychainManager: KeychainManaging {
    init() {}

    // MARK: - Save Password

    func savePassword(_ password: String, for journalID: String) throws {
        // Generate unique salt for this password
        let salt = UUID().uuidString

        // Hash password with salt using SHA256
        let passwordWithSalt = password + salt
        let passwordHash = SHA256.hash(data: Data(passwordWithSalt.utf8))
        let hashString = passwordHash.compactMap { String(format: "%02x", $0) }.joined()

        // Store format: "hash|salt"
        let storedValue = "\(hashString)|\(salt)"
        guard let passwordData = storedValue.data(using: .utf8) else {
            throw KeychainError.encodingFailed
        }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: journalID,
            kSecAttrService as String: "com.fieldnote.journal.password",
            kSecValueData as String: passwordData,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
            kSecAttrSynchronizable as String: false
        ]

        // Delete existing item first
        SecItemDelete(query as CFDictionary)

        // Add new item
        let status = SecItemAdd(query as CFDictionary, nil)

        guard status == errSecSuccess else {
            throw KeychainError.saveFailed(status)
        }
    }

    // MARK: - Retrieve Password

    func getPassword(for journalID: String) throws -> String {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: journalID,
            kSecAttrService as String: "com.fieldnote.journal.password",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)

        guard status == errSecSuccess else {
            throw KeychainError.retrievalFailed(status)
        }

        guard let passwordData = item as? Data,
              let password = String(data: passwordData, encoding: .utf8) else {
            throw KeychainError.decodingFailed
        }

        return password
    }

    // MARK: - Verify Password

    func verifyPassword(_ enteredPassword: String, for journalID: String) -> Bool {
        guard let storedValue = try? getPassword(for: journalID) else {
            return false
        }

        // Parse stored format: "hash|salt"
        let components = storedValue.components(separatedBy: "|")
        guard components.count == 2 else {
            return false
        }

        let storedHash = components[0]
        let salt = components[1]

        // Hash entered password with same salt
        let enteredPasswordWithSalt = enteredPassword + salt
        let enteredHash = SHA256.hash(data: Data(enteredPasswordWithSalt.utf8))
        let enteredHashString = enteredHash.compactMap { String(format: "%02x", $0) }.joined()

        // Use constant-time comparison to prevent timing attacks
        return constantTimeCompare(storedHash, enteredHashString)
    }

    // MARK: - Constant-Time Comparison

    private func constantTimeCompare(_ a: String, _ b: String) -> Bool {
        guard a.count == b.count else { return false }

        var result = 0
        for (char1, char2) in zip(a, b) {
            result |= Int(char1.asciiValue ?? 0) ^ Int(char2.asciiValue ?? 0)
        }

        return result == 0
    }

    // MARK: - Delete Password

    func deletePassword(for journalID: String) throws {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: journalID,
            kSecAttrService as String: "com.fieldnote.journal.password"
        ]

        let status = SecItemDelete(query as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.deleteFailed(status)
        }
    }

    // MARK: - Biometric Authentication

    func isBiometricAvailable() -> Bool {
        let context = LAContext()
        var error: NSError?
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    func getBiometricType() -> BiometricType {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return .none
        }

        switch context.biometryType {
        case .faceID:
            return .faceID
        case .touchID:
            return .touchID
        case .opticID:
            return .opticID
        case .none:
            return .none
        @unknown default:
            return .none
        }
    }

    func authenticateWithBiometrics(for journalName: String) async -> Bool {
        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return false
        }

        do {
            let success = try await context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "Unlock \"\(journalName)\""
            )
            return success
        } catch {
            return false
        }
    }
}

// MARK: - Biometric Type

enum BiometricType {
    case none
    case touchID
    case faceID
    case opticID

    var displayName: String {
        switch self {
        case .none:
            return "Biometrics"
        case .touchID:
            return "Touch ID"
        case .faceID:
            return "Face ID"
        case .opticID:
            return "Optic ID"
        }
    }

    var icon: String {
        switch self {
        case .none:
            return "lock.fill"
        case .touchID:
            return "touchid"
        case .faceID:
            return "faceid"
        case .opticID:
            return "opticid"
        }
    }
}

// MARK: - Keychain Errors

enum KeychainError: LocalizedError {
    case encodingFailed
    case decodingFailed
    case saveFailed(OSStatus)
    case retrievalFailed(OSStatus)
    case deleteFailed(OSStatus)

    var errorDescription: String? {
        switch self {
        case .encodingFailed:
            return "Failed to encode password"
        case .decodingFailed:
            return "Failed to decode password"
        case .saveFailed(let status):
            return "Failed to save password (status: \(status))"
        case .retrievalFailed(let status):
            return "Failed to retrieve password (status: \(status))"
        case .deleteFailed(let status):
            return "Failed to delete password (status: \(status))"
        }
    }
}
