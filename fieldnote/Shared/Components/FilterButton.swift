//
//  FilterButton.swift
//  fieldnote
//
//  Created by David Contreras on 5/13/26.
//

import SwiftUI

struct FilterButton: View {
    let isActive: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.system(size: 20))
                .foregroundColor(isActive ? .secondaryColor : .onSurfaceVariant)
                .frame(width: 48, height: 48)
                .background(Color.white)
                .cornerRadius(24) // Fully rounded circle
                .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}

#Preview("Inactive") {
    FilterButton(isActive: false, action: {})
        .padding()
}

#Preview("Active") {
    FilterButton(isActive: true, action: {})
        .padding()
}
