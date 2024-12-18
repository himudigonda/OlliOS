import SwiftUI

// MARK: - API Constants
struct APIConstants {
  static let baseURL = "http://192.168.0.3:8000"  // Replace with your backend URL if needed
  static let listModelsEndpoint = "/list_models"
  static let generateTextEndpoint = "/generate_text"
}

// MARK: - UI Constants
struct UIConstants {
  struct Spacing {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 24
    static let xlarge: CGFloat = 32
  }

  struct CornerRadius {
    static let regular: CGFloat = 10
    static let large: CGFloat = 20
  }

  struct ButtonSize {
    static let regular: CGFloat = 32
    static let send: CGFloat = 38  // Slightly larger for better touch target
  }

  struct IconSizes {
    static let small: CGFloat = 16
    static let medium: CGFloat = 20  // Slightly smaller for better proportion
    static let large: CGFloat = 24
  }
}

// MARK: - App Constants
struct AppConstants {
  static let appName = "OlliOS"
}

// MARK: - UserDefaults Keys
struct UserDefaultsKeys {
  static let userPreferences = "userPreferences"
  static let savedChats = "savedChats"
}
