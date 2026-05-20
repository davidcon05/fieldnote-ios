//
//  SortOption.swift
//  fieldnote
//
//  Created by David Contreras on 5/13/26.
//

import Foundation

enum SortOption: String, CaseIterable, Identifiable {
    case mostRecent = "Most Recent"
    case oldestFirst = "Oldest First"
    case aToZ = "A → Z"
    case zToA = "Z → A"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .mostRecent:
            return "clock.arrow.circlepath"
        case .oldestFirst:
            return "clock"
        case .aToZ:
            return "arrow.up"
        case .zToA:
            return "arrow.down"
        }
    }
}
