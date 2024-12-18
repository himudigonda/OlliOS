// FrontEnd/OlliOS/OlliOS/Models/Model.swift
import Foundation

struct Model: Identifiable, Codable, Hashable {
  let id: UUID
  let model_name: String

  init(id: UUID = UUID(), model_name: String) {
    self.id = id
    self.model_name = model_name
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(model_name)
  }
  static func == (lhs: Model, rhs: Model) -> Bool {
    return lhs.model_name == rhs.model_name
  }

  var isMultiModal: Bool {
    return model_name.contains("bakllava") || model_name.contains("llava")
  }
}
