// FrontEnd/OlliOS/OlliOS/Models/ChatMessage.swift
import Foundation

struct ChatMessage: Identifiable, Codable {
  let id: UUID
  let content: String
  let sender: Sender
  let isThinking: Bool
  let timestamp: Date
  var resourcePath: String?  // Store the resourcePath
  var chat_id: UUID?
  enum Sender: String, Codable {
    case user
    case assistant
  }

  enum CodingKeys: String, CodingKey {
    case id, content, sender, isThinking, timestamp, resourcePath, chat_id
  }

  init(
    id: UUID = UUID(), content: String, sender: Sender, isThinking: Bool, timestamp: Date,
    resourcePath: String? = nil, chat_id: UUID? = nil
  ) {
    self.id = id
    self.content = content
    self.sender = sender
    self.isThinking = isThinking
    self.timestamp = timestamp
    self.resourcePath = resourcePath
    self.chat_id = chat_id
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    id = try container.decode(UUID.self, forKey: .id)
    content = try container.decode(String.self, forKey: .content)
    sender = try container.decode(Sender.self, forKey: .sender)
    isThinking = try container.decode(Bool.self, forKey: .isThinking)
    timestamp = try container.decode(Date.self, forKey: .timestamp)
    resourcePath = try container.decodeIfPresent(String.self, forKey: .resourcePath)
    chat_id = try container.decodeIfPresent(UUID.self, forKey: .chat_id)
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(id, forKey: .id)
    try container.encode(content, forKey: .content)
    try container.encode(sender, forKey: .sender)
    try container.encode(isThinking, forKey: .isThinking)
    try container.encode(timestamp, forKey: .timestamp)
    try container.encode(resourcePath, forKey: .resourcePath)
    try container.encode(chat_id, forKey: .chat_id)
  }
}
