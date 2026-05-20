//
//  GPSTelemetryCard.swift
//  fieldnote
//
//  Created by David Contreras on 5/10/26.
//

import SwiftUI
import CoreLocation

struct GPSTelemetryCard: View {
    let location: CLLocation?
    let isLoading: Bool
    let error: String?
    var onRefresh: (() -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.primaryContainer)
                        .frame(width: 48, height: 48)

                    Image(systemName: "location.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.onPrimaryContainer)
                }

                Spacer()

                // Refresh Button
                if let onRefresh = onRefresh {
                    Button(action: onRefresh) {
                        if isLoading {
                            ProgressView()
                                .scaleEffect(0.7)
                                .tint(.primaryColor)
                        } else {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primaryColor)
                        }
                    }
                    .disabled(isLoading)
                    .opacity(isLoading ? 0.4 : 1.0)
                }
            }

            Spacer()

                // Content
                VStack(alignment: .leading, spacing: 4) {
                    Text("GPS Telemetry")
                        .font(.display(18, weight: .bold))
                        .foregroundColor(.onSurface)

                    if isLoading {
                        HStack(spacing: 4) {
                            ProgressView()
                                .scaleEffect(0.7)
                            Text("Acquiring signal...")
                                .font(.body(12))
                                .foregroundColor(.onSurfaceVariant)
                        }
                    } else if let error = error {
                        Text(error)
                            .font(.body(12))
                            .foregroundColor(.error)
                            .lineLimit(2)
                    } else if let location = location {
                        Text(formatCoordinates(location))
                            .font(.body(12))
                            .foregroundColor(.onSurfaceVariant)
                            .lineLimit(2)
                    } else {
                        Text("Waiting for GPS lock...")
                            .font(.body(12))
                            .foregroundColor(.onSurfaceVariant)
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
                .stroke(Color.outlineVariant.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
        .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
    }

    private func formatCoordinates(_ location: CLLocation) -> String {
        let lat = location.coordinate.latitude
        let lon = location.coordinate.longitude
        let latDirection = lat >= 0 ? "N" : "S"
        let lonDirection = lon >= 0 ? "E" : "W"
        return String(format: "%.4f° %@, %.4f° %@", abs(lat), latDirection, abs(lon), lonDirection)
    }
}

#Preview("With Location") {
    GPSTelemetryCard(
        location: CLLocation(latitude: 47.8013, longitude: -123.6044),
        isLoading: false,
        error: nil,
        onRefresh: {
            print("GPS refresh tapped")
        }
    )
    .padding()
}

#Preview("Loading") {
    GPSTelemetryCard(
        location: nil,
        isLoading: true,
        error: nil,
        onRefresh: {
            print("GPS refresh tapped")
        }
    )
    .padding()
}

#Preview("Error State") {
    GPSTelemetryCard(
        location: nil,
        isLoading: false,
        error: "GPS unavailable - location services disabled",
        onRefresh: {
            print("GPS refresh tapped")
        }
    )
    .padding()
}

#Preview("Waiting for GPS") {
    GPSTelemetryCard(
        location: nil,
        isLoading: false,
        error: nil,
        onRefresh: {
            print("GPS refresh tapped")
        }
    )
    .padding()
}

#Preview("Refreshing with Location") {
    GPSTelemetryCard(
        location: CLLocation(latitude: 47.8013, longitude: -123.6044),
        isLoading: true,
        error: nil,
        onRefresh: {
            print("GPS refresh tapped")
        }
    )
    .padding()
}

#Preview("No Refresh Button") {
    GPSTelemetryCard(
        location: CLLocation(latitude: 47.8013, longitude: -123.6044),
        isLoading: false,
        error: nil,
        onRefresh: nil
    )
    .padding()
}
