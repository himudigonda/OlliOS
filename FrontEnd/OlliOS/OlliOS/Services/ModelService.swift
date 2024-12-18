import Combine
import Foundation

class ModelService: ObservableObject {
  @Published var models: [Model] = []
  @Published var selectedModel: Model? = nil
  private let apiService = ApiService()
  private let dataService = DataService()
  private var cancellables = Set<AnyCancellable>()

  init() {
    loadSelectedModel()
    fetchModels()
    print("ModelService.swift: Initialized")
  }

  func fetchModels() {
    guard let url = URL(string: "\(APIConstants.baseURL)/list_models") else { return }
    apiService.fetch(from: url)
      .map { (models: [[String: String]]) in
        models.compactMap { Model(model_name: $0["model_name"] ?? "") }
      }
      .receive(on: DispatchQueue.main)
      .sink(receiveCompletion: handleFetchError, receiveValue: handleModels)
      .store(in: &cancellables)
  }

  private func handleFetchError(_ completion: Subscribers.Completion<Error>) {
    if case .failure(let error) = completion {
      print("ModelService.swift: Error fetching models - \(error)")
    }
  }

  private func handleModels(_ models: [Model]) {
    if models.isEmpty {
      print("ModelService.swift: No models received, adding fallback model.")
      self.models = [Model(model_name: "Default Model")]
    } else {
      self.models = models
    }
    self.selectedModel = self.models.first
    saveSelectedModel()
  }

  func saveSelectedModel() {
    if let model = selectedModel {
      dataService.save(data: model, forKey: "selectedModel")
      print("ModelService.swift: Selected model saved - \(model.model_name)")
    }
  }

  func loadSelectedModel() {
    if let model: Model = dataService.load(forKey: "selectedModel") {
      selectedModel = model
      print("ModelService.swift: Selected model loaded - \(model.model_name)")
    } else {
      print("ModelService.swift: No selected model found")
    }
  }
}
