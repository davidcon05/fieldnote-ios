//
//  PhotoPickerRepresentable.swift
//  fieldnote
//
//  Created by David Contreras on 5/13/26.
//

import SwiftUI
import PhotosUI

/// UIViewControllerRepresentable wrapper for PHPickerViewController
/// Allows importing photos from the photo library
struct PhotoPickerRepresentable: UIViewControllerRepresentable {
    @Binding var selectedImages: [UIImage]
    @Environment(\.dismiss) private var dismiss

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 10 // Allow selecting up to 10 images
        configuration.preferredAssetRepresentationMode = .current

        let picker = PHPickerViewController(configuration: configuration)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // No updates needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: PhotoPickerRepresentable

        init(_ parent: PhotoPickerRepresentable) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)

            guard !results.isEmpty else { return }

            // Load images from results
            let dispatchGroup = DispatchGroup()
            var loadedImages: [UIImage] = []

            for result in results {
                dispatchGroup.enter()

                result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                    defer { dispatchGroup.leave() }

                    if let error = error {
                        print("❌ Error loading image: \(error)")
                        return
                    }

                    if let image = object as? UIImage {
                        loadedImages.append(image)
                    }
                }
            }

            dispatchGroup.notify(queue: .main) {
                self.parent.selectedImages = loadedImages
            }
        }
    }
}
