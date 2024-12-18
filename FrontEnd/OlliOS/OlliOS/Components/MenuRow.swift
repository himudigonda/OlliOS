// frontend/OlliOS/OlliOS/Components/MenuRow.swift
import SwiftUI

struct MenuRow: View {
  let icon: String
  let title: String

  var body: some View {
    HStack(spacing: UIConstants.Spacing.medium) {
      Image(systemName: icon)
        .frame(width: UIConstants.IconSizes.large, height: UIConstants.IconSizes.large)
        .foregroundColor(.primary)
      Text(title)
        .font(.system(size: 16))
        .foregroundColor(.primary)
      Spacer()
    }
    .padding(.horizontal)
    .padding(.vertical, UIConstants.Spacing.small)
  }
}
