// frontend/OlliOS/OlliOS/Fonts.swift
import SwiftUI

enum AppFont: String, CaseIterable, Codable {
  case system, mono

  var font: Font {
    switch self {
    case .system: return .system(size: 16)
    case .mono: return .system(size: 16, design: .monospaced)
    }
  }
}
