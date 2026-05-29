//
//  CapturePhotoButton.swift
//  EcoJournal
//
//  Created by David Contreras on 5/10/26.
//

import SwiftUI

struct CapturePhotoButton: View {
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 16) {
                // Camera Icon in Circle
                ZStack {
                    Circle()
                        .fill(Color.primaryColor)
                        .frame(width: 80, height: 80)
                        .shadow(color: Color.primaryColor.opacity(0.3), radius: 8, x: 0, y: 4)

                    Image(systemName: "camera.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.onPrimary)
                }
                .scaleEffect(isPressed ? 0.9 : 1.0)

                // Text
                VStack(spacing: 4) {
                    Text("Capture Photo")
                        .font(.display(20, weight: .bold))
                        .foregroundColor(.onSurface)

                    Text("High-resolution specimen documentation")
                        .font(.body(14))
                        .foregroundColor(.onSurfaceVariant)
                        .multilineTextAlignment(.center)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 32)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isPressed ? Color.primaryColor : Color.clear, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
            .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .animation(.easeInOut(duration: 0.1), value: isPressed)
    }
}

#Preview("Default State") {
    CapturePhotoButton {
        print("Camera tapped")
    }
    .padding()
}

#Preview("Pressed State") {
    // Create a stateful wrapper to simulate pressed state
    struct PressedStateWrapper: View {
        @State private var isSimulatingPress = true

        var body: some View {
            CapturePhotoButton {
                print("Camera tapped")
            }
            .padding()
            .onAppear {
                // Simulate continuous press for preview
                Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
                    isSimulatingPress.toggle()
                }
            }
        }
    }

    return PressedStateWrapper()
}
