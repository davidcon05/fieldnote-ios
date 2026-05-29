//
//  LocationManager.swift
//  EcoJournal
//
//  Created by David Contreras on 5/9/26.
//

import Foundation
import CoreLocation
internal import Combine

@MainActor
class LocationManager: NSObject, ObservableObject {
    // MARK: - Published Properties

    @Published var location: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationError: String?

    // MARK: - Private Properties

    private let manager = CLLocationManager()
    private var isUpdating = false

    // MARK: - Initialization

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 10 // Update every 10 meters
        authorizationStatus = manager.authorizationStatus
    }

    // MARK: - Public Methods

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func startUpdatingLocation() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            locationError = "Location permission not granted"
            return
        }

        guard !isUpdating else { return }

        isUpdating = true
        manager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        guard isUpdating else { return }

        isUpdating = false
        manager.stopUpdatingLocation()
    }

    func getCurrentLocation() async throws -> CLLocation {
        // If we already have a recent location (< 30 seconds old), return it
        if let location = location,
           Date().timeIntervalSince(location.timestamp) < 30 {
            return location
        }

        // Request permission if not determined
        if authorizationStatus == .notDetermined {
            requestPermission()
        }

        // Check authorization
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            throw LocationError.permissionDenied
        }

        // Start updating if not already
        if !isUpdating {
            startUpdatingLocation()
        }

        // Wait for location update
        return try await withCheckedThrowingContinuation { continuation in
            var hasResumed = false

            // Set up a one-time location observer
            let cancellable = $location
                .compactMap { $0 }
                .first()
                .sink { location in
                    guard !hasResumed else { return }
                    hasResumed = true
                    continuation.resume(returning: location)
                }

            // Timeout after 10 seconds
            Task {
                try? await Task.sleep(nanoseconds: 10_000_000_000) // 10 seconds
                guard !hasResumed else { return }
                hasResumed = true
                cancellable.cancel()
                continuation.resume(throwing: LocationError.timeout)
            }
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            authorizationStatus = manager.authorizationStatus

            switch authorizationStatus {
            case .authorizedWhenInUse, .authorizedAlways:
                locationError = nil
                startUpdatingLocation()
            case .denied, .restricted:
                locationError = "Location access denied. Please enable in Settings."
                stopUpdatingLocation()
            case .notDetermined:
                locationError = nil
            @unknown default:
                locationError = "Unknown authorization status"
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            guard let newLocation = locations.last else { return }
            location = newLocation
            locationError = nil
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            if let clError = error as? CLError {
                switch clError.code {
                case .denied:
                    locationError = "Location access denied"
                case .locationUnknown:
                    locationError = "Location currently unavailable"
                case .network:
                    locationError = "Network error while getting location"
                default:
                    locationError = "Location error: \(error.localizedDescription)"
                }
            } else {
                locationError = error.localizedDescription
            }
        }
    }
}

// MARK: - Location Errors

enum LocationError: LocalizedError {
    case permissionDenied
    case timeout
    case unavailable

    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Location permission denied. Please enable in Settings."
        case .timeout:
            return "Location request timed out. Please try again."
        case .unavailable:
            return "Location services unavailable."
        }
    }
}
