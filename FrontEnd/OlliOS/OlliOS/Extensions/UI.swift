// frontend/OlliOS/OlliOS/Extensions/UI.swift
import SwiftUI

extension Image {
  func settingsIconStyle() -> some View {
    self
      .frame(width: UIConstants.IconSizes.medium, height: UIConstants.IconSizes.medium)
      .foregroundColor(.blue)
  }
}
