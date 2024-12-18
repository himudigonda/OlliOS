// frontend/OlliOS/OlliOS/Models/AppIcon.swift
import SwiftUI

enum AppIcon: String, CaseIterable, Codable {
  case defaultIcon = "Default"
  case alternateIcon1 = "Alternate1"
  case alternateIcon2 = "Alternate2"

  var iconName: String {
    switch self {
    case .defaultIcon: return "AppIcon"
    case .alternateIcon1: return "AlternateIcon1"
    case .alternateIcon2: return "AlternateIcon2"
    }
  }
}
