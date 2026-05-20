//
//  RecordMemoCard.swift
//  fieldnote
//
//  Created by David Contreras on 5/10/26.
//

import SwiftUI

struct RecordMemoCard: View {
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: 16) {
                // Icon
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.tertiaryContainer)
                        .frame(width: 48, height: 48)

                    Image(systemName: "mic.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.onTertiaryContainer)
                }

                Spacer()

                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text("Record Memo")
                        .font(.display(18, weight: .bold))
                        .foregroundColor(.onSurface)

                    Text("Voice-to-text field observations")
                        .font(.body(12))
                        .foregroundColor(.onSurfaceVariant)
                        .lineLimit(2)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(24)
            .frame(height: 200)
            .background(Color.white)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.clear, lineWidth: 2)
            )
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 2)
            .shadow(color: .black.opacity(0.04), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(CardButtonStyle(highlightColor: .tertiary))
    }
}

#Preview {
    RecordMemoCard {
        print("Record memo tapped")
    }
    .padding()
}
