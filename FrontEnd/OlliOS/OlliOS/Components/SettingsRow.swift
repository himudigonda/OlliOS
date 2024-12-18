// frontend/OlliOS/OlliOS/Components/SettingsRow.swift
import SwiftUI

struct SettingsRow: View {
  let icon: String
  let title: String
  var rightText: String? = nil
  var rightView: AnyView? = nil

  var body: some View {
    HStack(spacing: UIConstants.Spacing.medium) {
      Image(systemName: icon)
        .settingsIconStyle()
      Text(title)
        .font(.system(size: 16))
        .foregroundColor(.primary)
      Spacer()
      if let rightText = rightText {
        Text(rightText)
          .font(.system(size: 16))
          .foregroundColor(.gray)
      }
      if let rightView = rightView {
        rightView
      }
    }
    .padding(.horizontal)
  }
}
