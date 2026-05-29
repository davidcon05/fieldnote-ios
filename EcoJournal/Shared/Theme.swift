//
//  Theme.swift
//  EcoJournal
//
//  Created by David Contreras on 5/8/26.
//

import SwiftUI

  extension Color {
      init(hex: String) {
          let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
          var int: UInt64 = 0
          Scanner(string: hex).scanHexInt64(&int)
          let a, r, g, b: UInt64
          switch hex.count {
          case 6: // RGB
              (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
          case 8: // ARGB
              (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
          default:
              (a, r, g, b) = (255, 0, 0, 0)
          }
          self.init(
              .sRGB,
              red: Double(r) / 255,
              green: Double(g) / 255,
              blue: Double(b) / 255,
              opacity: Double(a) / 255
          )
      }

      // MARK: - Brand Colors
      static let primaryColor = Color(hex: "#4A7C59")
      static let secondaryColor = Color(hex: "#6B6358")
      static let tertiaryColor = Color(hex: "#C4A66A")
      static let neutralColor = Color(hex: "#4A4E4A")

      // MARK: - Surface Colors
      static let background = Color(hex: "#FAF6F0")
      static let surfaceBackground = Color(hex: "#FAF6F0")
      static let surfaceContainer = Color(hex: "#F0ECE4")
      static let surfaceContainerLow = Color(hex: "#F5F1EA")
      static let surfaceContainerHigh = Color(hex: "#EAE6DE")
      static let surfaceContainerHighest = Color(hex: "#E4E0D8")
      static let surfaceDim = Color(hex: "#DBD7CF")

      // MARK: - Text Colors
      static let onBackground = Color(hex: "#2E3230")
      static let onSurface = Color(hex: "#2E3230")
      static let onSurfaceVariant = Color(hex: "#4A4E4A")
      static let onPrimary = Color.white
      static let onPrimaryContainer = Color(hex: "#002110")
      static let onTertiaryContainer = Color(hex: "#554020")

      // MARK: - Container Colors
      static let primaryContainer = Color(hex: "#78A886")
      static let tertiaryContainer = Color(hex: "#C4A66A")
      static let tertiary = Color(hex: "#705C30")

      // MARK: - Border Colors
      static let outline = Color(hex: "#74796E")
      static let outlineVariant = Color(hex: "#C4C8BC")

      // MARK: - Semantic Colors
      static let error = Color(hex: "#B83230")
  }

  extension Font {
      // MARK: - Headlines (Literata)
      static func headline(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
          .custom("Literata", size: size).weight(weight)
      }

      // MARK: - Display (Literata)
      static func display(_ size: CGFloat, weight: Font.Weight = .bold) -> Font {
          .custom("Literata", size: size).weight(weight)
      }

      // MARK: - Body/Label (Nunito Sans)
      static func body(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
          .custom("Nunito Sans", size: size).weight(weight)
      }

      static func label(_ size: CGFloat, weight: Font.Weight = .regular) -> Font {
          .custom("Nunito Sans", size: size).weight(weight)
      }
  }

  // MARK: - Journal Themes
  struct JournalTheme {
      let icon: String
      let color: Color
      let colorHex: String

      static let themes = [
          JournalTheme(icon: "leaf.fill", color: .primaryColor, colorHex: "#4A7C59"),
          JournalTheme(icon: "drop.fill", color: .secondaryColor, colorHex: "#6B6358"),
          JournalTheme(icon: "mountain.2.fill", color: .tertiaryColor, colorHex: "#C4A66A"),
          JournalTheme(icon: "tree.fill", color: Color(hex: "#2A6038"), colorHex: "#2A6038"),
          JournalTheme(icon: "flame.fill", color: Color(hex: "#B83230"), colorHex: "#B83230"),
          JournalTheme(icon: "snowflake", color: Color(hex: "#8ECFA0"), colorHex: "#8ECFA0"),
      ]

      static func random() -> JournalTheme {
          themes.randomElement() ?? themes[0]
      }

      static func from(icon: String, colorHex: String) -> JournalTheme {
          JournalTheme(icon: icon, color: Color(hex: colorHex), colorHex: colorHex)
      }
  }
