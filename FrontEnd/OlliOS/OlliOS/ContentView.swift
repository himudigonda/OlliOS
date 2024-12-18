// frontend/OlliOS/OlliOS/Views/ContentView.swift
import SwiftUI

struct ContentView: View {
  @StateObject var viewModel = ChatViewModel()
  @StateObject var modelService = ModelService()

  var body: some View {
    NavigationStack {
      ChatView()
        .environmentObject(viewModel)
        .onAppear {
          print("ContentView.swift: onAppear called")
          modelService.fetchModels()
          print("ContentView.swift: modelService.fetchModels called")
          // Set the selected model from ModelService
          if let selectedModel = modelService.selectedModel {
            viewModel.selectedModel = selectedModel
            print("ContentView.swift: Loaded saved model - \(selectedModel.model_name)")
          }
        }
    }
  }
}
