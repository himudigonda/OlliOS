// FrontEnd/OlliOS/OlliOS/OlliOSApp.swift
import SwiftUI

@main
struct OlliOSApp: App {
  @StateObject var viewModel = ChatViewModel()
  @StateObject var modelService = ModelService()  // Add this line
  @State private var navigationPath = NavigationPath()

  var body: some Scene {
    WindowGroup {
      ContentView()
        .environmentObject(viewModel)
        .environmentObject(modelService)  // Add this line
    }
  }
}
