//
//  AudioMemoView.swift
//  EcoJournal
//
//  Created by David Contreras on 5/13/26.
//

import SwiftUI

/// Audio memo component with recording, playback, and transcription
/// Replaces RecordMemoCard with functional audio integration
struct AudioMemoView: View {
    @Binding var audioURL: URL?
    @Binding var transcription: String?

    @StateObject private var audioService = AudioRecorderService()
    @StateObject private var transcriptionService = AudioTranscriptionService()

    @State private var isRecording = false
    @State private var recordingURL: URL?
    @State private var showingDeleteConfirmation = false
    @State private var showingOverwriteWarning = false
    @State private var isEditingTranscription = false
    @State private var editedTranscription = ""
    @State private var isTranscriptionExpanded = false

    var body: some View {
        if audioURL == nil {
            // Empty state: Record button
            emptyStateButton
        } else {
            // Recorded state: Playback controls + transcription
            recordedStateCard
        }
    }

    // MARK: - Empty State

    private var emptyStateButton: some View {
        Button(action: handleRecordButtonTap) {
            VStack(alignment: .leading, spacing: 16) {
                // Microphone Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.tertiaryContainer)
                        .frame(width: 48, height: 48)

                    Image(systemName: isRecording ? "stop.fill" : "mic.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.onTertiaryContainer)
                }

                Spacer()

                // Text
                VStack(alignment: .leading, spacing: 4) {
                    if isRecording {
                        Text("Recording...")
                            .font(.display(18, weight: .bold))
                            .foregroundColor(.onSurface)

                        Text(audioService.formatTime(audioService.recordingDuration))
                            .font(.body(14, weight: .medium))
                            .foregroundColor(.error)
                    } else {
                        Text("Record Memo")
                            .font(.display(18, weight: .bold))
                            .foregroundColor(.onSurface)

                        Text("Voice-to-text field observations")
                            .font(.body(12))
                            .foregroundColor(.onSurfaceVariant)
                            .lineLimit(2)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
            .frame(height: 200)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isRecording ? Color.error : Color.clear, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
            .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .alert("Replace Existing Recording?", isPresented: $showingOverwriteWarning) {
            Button("Cancel", role: .cancel) {}
            Button("Replace", role: .destructive) {
                // Delete old audio first
                if let oldURL = audioURL {
                    audioService.deleteAudio(at: oldURL)
                }
                audioURL = nil
                transcription = nil
                editedTranscription = ""
                // Start new recording
                startRecording()
            }
        } message: {
            Text("Starting a new recording will permanently delete your existing audio memo and transcription.")
        }
    }

    // MARK: - Recorded State

    private var recordedStateCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with delete button
            HStack {
                Text("AUDIO MEMO")
                    .font(.label(10, weight: .bold))
                    .foregroundColor(.tertiary)
                    .tracking(1.5)

                Spacer()

                Button(action: { showingDeleteConfirmation = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "trash")
                        Text("Delete")
                    }
                    .font(.body(12, weight: .medium))
                    .foregroundColor(.error)
                }
            }

            // Playback controls
            HStack(spacing: 12) {
                // Play/Pause button
                Button(action: togglePlayback) {
                    Image(systemName: audioService.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.primaryColor)
                }

                VStack(alignment: .leading, spacing: 4) {
                    // Progress bar
                    if let url = audioURL, let duration = audioService.getDuration(for: url) {
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background track
                                Rectangle()
                                    .fill(Color.outlineVariant)
                                    .frame(height: 4)
                                    .cornerRadius(2)

                                // Progress
                                Rectangle()
                                    .fill(Color.primaryColor)
                                    .frame(width: geometry.size.width * (audioService.playbackProgress / duration), height: 4)
                                    .cornerRadius(2)
                            }
                        }
                        .frame(height: 4)

                        // Time display
                        HStack {
                            Text(audioService.formatTime(audioService.playbackProgress))
                                .font(.body(12))
                                .foregroundColor(.onSurfaceVariant)

                            Spacer()

                            Text(audioService.formatTime(duration))
                                .font(.body(12))
                                .foregroundColor(.onSurfaceVariant)
                        }
                    }
                }
            }
            .padding(16)
            .background(Color.surfaceContainer)
            .cornerRadius(12)

            // Transcription section
            if transcriptionService.isTranscribing {
                // Transcribing indicator
                HStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(0.8)

                    Text("Transcribing audio...")
                        .font(.body(14))
                        .foregroundColor(.onSurfaceVariant)

                    Spacer()

                    Text(String(format: "%.0f%%", transcriptionService.transcriptionProgress * 100))
                        .font(.body(12, weight: .medium))
                        .foregroundColor(.onSurfaceVariant)
                }
                .padding(16)
                .background(Color.surfaceContainer)
                .cornerRadius(12)
            } else if let text = transcription, !text.isEmpty {
                // Transcription display
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("TRANSCRIPTION")
                            .font(.label(10, weight: .bold))
                            .foregroundColor(.tertiary)
                            .tracking(1.5)

                        Spacer()

                        Button(action: { isEditingTranscription.toggle() }) {
                            HStack(spacing: 4) {
                                Image(systemName: isEditingTranscription ? "checkmark" : "pencil")
                                Text(isEditingTranscription ? "Done" : "Edit")
                            }
                            .font(.body(12, weight: .medium))
                            .foregroundColor(.primaryColor)
                        }

                        Button(action: { isTranscriptionExpanded.toggle() }) {
                            Image(systemName: isTranscriptionExpanded ? "chevron.up" : "chevron.down")
                                .font(.system(size: 14))
                                .foregroundColor(.onSurfaceVariant)
                        }
                    }

                    if isEditingTranscription {
                        TextEditor(text: $editedTranscription)
                            .font(.body(14))
                            .frame(minHeight: isTranscriptionExpanded ? 200 : 100)
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(Color.outlineVariant, lineWidth: 1)
                            )
                            .onChange(of: isEditingTranscription) { _, newValue in
                                if !newValue {
                                    // Save edited transcription
                                    transcription = editedTranscription
                                }
                            }
                    } else {
                        Text(text)
                            .font(.body(14))
                            .foregroundColor(.onSurface)
                            .lineLimit(isTranscriptionExpanded ? nil : 3)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.surfaceContainer)
                            .cornerRadius(8)
                    }
                }
            } else if transcriptionService.transcriptionError != nil {
                // Transcription error
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.triangle")
                        .foregroundColor(.error)

                    Text("Transcription failed")
                        .font(.body(14))
                        .foregroundColor(.error)

                    Spacer()

                    Button("Retry") {
                        retryTranscription()
                    }
                    .font(.body(12, weight: .medium))
                    .foregroundColor(.primaryColor)
                }
                .padding(12)
                .background(Color.surfaceContainer)
                .cornerRadius(8)
            } else {
                // No transcription yet - show "Transcribe" button
                Button(action: { startTranscription() }) {
                    HStack(spacing: 8) {
                        Image(systemName: "text.bubble")
                            .font(.system(size: 16))

                        Text("Transcribe Audio")
                            .font(.body(14, weight: .medium))

                        Spacer()

                        Image(systemName: "chevron.right")
                            .font(.system(size: 12))
                            .foregroundColor(.onSurfaceVariant)
                    }
                    .foregroundColor(.primaryColor)
                    .padding(12)
                    .background(Color.surfaceContainer)
                    .cornerRadius(8)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(16)
        .background(Color.white)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.outlineVariant, lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        .alert("Delete Audio Memo?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteAudio()
            }
        } message: {
            Text("This will permanently delete the audio recording and transcription.")
        }
        .onAppear {
            editedTranscription = transcription ?? ""
        }
    }

    // MARK: - Actions

    private func handleRecordButtonTap() {
        // If audio already exists, warn before overwriting
        if audioURL != nil {
            showingOverwriteWarning = true
        } else {
            startRecording()
        }
    }

    private func startRecording() {
        // Prevent multiple taps
        guard !audioService.isRecording else {
            stopRecording()
            return
        }

        isRecording = true
        recordingURL = audioService.startRecording()
    }

    private func stopRecording() {
        guard audioService.isRecording else { return }

        isRecording = false

        // Stop recording and get URL
        if let url = audioService.stopRecording() {
            recordingURL = url
            // Just save the URL, don't auto-transcribe
            audioURL = url
        }
    }

    private func startTranscription() {
        guard let url = audioURL else { return }

        // Ensure playback is stopped before transcribing
        if audioService.isPlaying {
            audioService.stopPlayback()
        }

        Task {
            var lastError: Error?

            // Retry once with delay to handle timing issues
            for attempt in 1...2 {
                do {
                    print("🔄 Transcription attempt \(attempt)/2")

                    // Check if file exists first
                    guard FileManager.default.fileExists(atPath: url.path) else {
                        let error = TranscriptionAttemptError.fileNotFound(path: url.path)
                        print("❌ File not found: \(url.path)")
                        lastError = error

                        // Wait before retry
                        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
                        continue
                    }

                    // Check file size to ensure it's not corrupted/empty
                    let attributes = try FileManager.default.attributesOfItem(atPath: url.path)
                    let fileSize = attributes[.size] as? Int64 ?? 0
                    guard fileSize > 0 else {
                        let error = TranscriptionAttemptError.fileEmpty(path: url.path, size: fileSize)
                        print("❌ File is empty or corrupted: \(fileSize) bytes")
                        lastError = error

                        // Wait before retry
                        try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
                        continue
                    }

                    print("✅ File exists and valid: \(fileSize) bytes")

                    // Wait before attempting transcription
                    try await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds

                    // Attempt transcription
                    let text = try await transcriptionService.transcribe(audioURL: url)
                    transcription = text
                    editedTranscription = text
                    print("✅ Transcription complete: \(text.prefix(100))...")
                    return // Success - exit

                } catch {
                    print("❌ Transcription attempt \(attempt) failed: \(error)")
                    lastError = error

                    // If not the last attempt, wait before retry
                    if attempt < 2 {
                        try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
                    }
                }
            }

            // Both attempts failed
            print("❌ Both transcription attempts failed. Removing invalid audio reference.")

            // Clean up the bad recording
            if let url = audioURL {
                audioService.deleteAudio(at: url)
            }
            audioURL = nil
            transcription = nil
            editedTranscription = ""

            // Show detailed error to user
            if let error = lastError {
                transcriptionService.transcriptionError = "Recording failed to save properly: \(error.localizedDescription). Please try recording again."
            } else {
                transcriptionService.transcriptionError = "Recording failed to save properly. Please try recording again."
            }
        }
    }

    private func togglePlayback() {
        guard let url = audioURL else { return }

        if audioService.isPlaying {
            audioService.pausePlayback()
        } else {
            audioService.playAudio(from: url)
        }
    }

    private func deleteAudio() {
        if let url = audioURL {
            audioService.deleteAudio(at: url)
        }
        audioURL = nil
        transcription = nil
        editedTranscription = ""
    }

    private func retryTranscription() {
        // Clear error and try again
        transcriptionService.transcriptionError = nil
        startTranscription()
    }
}

// MARK: - Errors

enum TranscriptionAttemptError: LocalizedError {
    case fileNotFound(path: String)
    case fileEmpty(path: String, size: Int64)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let path):
            return "Audio file not found at path: \(path)"
        case .fileEmpty(let path, let size):
            return "Audio file is empty or corrupted: \(path) (\(size) bytes)"
        }
    }
}

// MARK: - Previews

#Preview("Empty State") {
    @Previewable @State var audioURL: URL?
    @Previewable @State var transcription: String?

    return AudioMemoView(audioURL: $audioURL, transcription: $transcription)
        .padding()
}

#Preview("With Audio & Transcription") {
    @Previewable @State var audioURL: URL? = URL(string: "file:///audio.m4a")
    @Previewable @State var transcription: String? = "Found three specimens of Pseudotsuga menziesii near the creek at approximately 600 meters elevation. Bark samples collected for analysis. Weather conditions are clear with light wind from the northwest."

    return AudioMemoView(audioURL: $audioURL, transcription: $transcription)
        .padding()
}

#Preview("With Audio Only (No Transcription)") {
    @Previewable @State var audioURL: URL? = URL(string: "file:///audio.m4a")
    @Previewable @State var transcription: String?

    return AudioMemoView(audioURL: $audioURL, transcription: $transcription)
        .padding()
}
