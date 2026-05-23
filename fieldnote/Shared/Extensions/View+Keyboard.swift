//
//  View+Keyboard.swift
//  fieldnote
//
//  Created by David Contreras on 5/23/26.
//

import SwiftUI

extension View {
    /// Adds a tap gesture to dismiss the keyboard when tapping outside text fields
    func dismissKeyboardOnTap() -> some View {
        self.onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}
