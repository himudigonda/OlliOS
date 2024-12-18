// frontend/OlliOS/OlliOS/Services/ModelService.swift
import Combine
import Foundation

class ModelService: ObservableObject {
  @Published var models: [Model] = []
  @Published var selectedModel: Model?
  private let apiService = ApiService()
  private let dataService = DataService()
  private var cancellables = Set<AnyCancellable>()

  init() {
    loadSelectedModel()
    fetchModels()  // Fetch models immediately on initialization
    print("ModelService.swift: Initialized")
  }

  func fetchModels() {
    guard let url = URL(string: "\(APIConstants.baseURL)\(APIConstants.listModelsEndpoint)") else {
      print("ModelService.swift: Invalid URL")
      return
    }
    apiService.fetch(from: url)
      .map { (models: [[String: String]]) in
        models.map { Model(model_name: $0["model_name"] ?? "Unknown") }
      }
      .receive(on: DispatchQueue.main)
      .sink(
        receiveCompletion: { completion in
          switch completion {
          case .failure(let error):
            print("ModelService.swift: Error fetching models - \(error)")
          case .finished:
            print("ModelService.swift: Successfully fetched models")
          }
        },
        receiveValue: { [weak self] models in
          if self?.models != models {
            self?.models = models
            if self?.selectedModel == nil {
              self?.selectedModel = models.first
              self?.saveSelectedModel()
            }
            print("ModelService.swift: Models updated")
          }
        }
      )
      .store(in: &cancellables)
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
