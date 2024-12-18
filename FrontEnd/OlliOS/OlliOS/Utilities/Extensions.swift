// frontend/OlliOS/OlliOS/Utilities/Extensions.swift
import SwiftUI

extension Color {
  static var systemBackground: Color {
    Color(UIColor.systemBackground)
  }
  static var secondarySystemBackground: Color {
    Color(UIColor.secondarySystemBackground)
  }
  static var tertiarySystemBackground: Color {
    Color(UIColor.tertiarySystemBackground)
  }
  static var systemGray5: Color {
    Color(UIColor.systemGray5)
  }
  static var systemGray6: Color {
    Color(UIColor.systemGray6)
  }
  static var lightBlue: Color {
  Color(red: 185 / 255, green: 230 / 255, blue: 255 / 255)
}

}

extension View {
  func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
    clipShape(RoundedCorner(radius: radius, corners: corners))
  }
}

struct RoundedCorner: Shape {
  var radius: CGFloat = .infinity
  var corners: UIRectCorner = .allCorners

  func path(in rect: CGRect) -> Path {
    let path = UIBezierPath(
      roundedRect: rect, byRoundingCorners: corners,
      cornerRadii: CGSize(width: radius, height: radius))
    return Path(path.cgPath)
  }
}
