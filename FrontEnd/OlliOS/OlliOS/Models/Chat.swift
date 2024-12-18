// FrontEnd/OlliOS/OlliOS/Models/Chat.swift
import Foundation

struct Chat: Identifiable, Codable {
  let id: UUID
  var title: String
  var messages: [ChatMessage] = []
  var isPinned: Bool = false
  let createdDate: Date

  init(
    id: UUID = UUID(), title: String, messages: [ChatMessage] = [], isPinned: Bool = false,
    createdDate: Date = Date()
  ) {
    self.id = id
    self.title = title
    self.messages = messages
    self.isPinned = isPinned
    self.createdDate = createdDate
  }

  enum CodingKeys: String, CodingKey {
    case id, title, messages, isPinned, createdDate
  }

  static func == (lhs: Chat, rhs: Chat) -> Bool {
    return lhs.id == rhs.id
  }
}
