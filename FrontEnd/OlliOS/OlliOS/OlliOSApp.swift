// frontend/OlliOS/OlliOS/OlliOSApp.swift
import SwiftUI

@main
struct OlliOSApp: App {
  @StateObject var viewModel = ChatViewModel()
  @State private var navigationPath = NavigationPath()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(viewModel)
    }
  }
}
