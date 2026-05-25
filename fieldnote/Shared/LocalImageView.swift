//
//  LocalImageView.swift
//  fieldnote
//
//  Created by David Contreras on 5/25/26.
//

import SwiftUI
import UIKit

/// A view that loads local images directly from file URLs without AsyncImage caching
/// This ensures Dashboard updates when photos change by bypassing URLCache
struct LocalImageView<Placeholder: View>: View {
    let url: URL
    let placeholder: Placeholder

    @State private var uiImage: UIImage?

    var body: some View {
        Group {
            if let uiImage = uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
            } else {
                placeholder
            }
        }
        .task(id: url.absoluteString) {
            await loadImage()
        }
    }

    private func loadImage() async {
        // Load image directly from file system
        guard url.isFileURL else {
            // Fallback to AsyncImage behavior for non-local files
            return
        }

        // Read image data directly, bypassing any cache
        if let data = try? Data(contentsOf: url),
           let image = UIImage(data: data) {
            uiImage = image
        }
    }
}
