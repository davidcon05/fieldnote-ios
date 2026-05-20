//
//  CardButtonStyle.swift
//  fieldnote
//
//  Created by David Contreras on 5/10/26.
//

import SwiftUI

struct CardButtonStyle: ButtonStyle {
    let highlightColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(configuration.isPressed ? highlightColor : Color.clear, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}
