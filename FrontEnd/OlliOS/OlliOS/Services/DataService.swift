// frontend/OlliOS/OlliOS/Services/DataService.swift
import Foundation

class DataService {
  func save<T: Codable>(data: T, forKey key: String) {
    if let encoded = try? JSONEncoder().encode(data) {
      UserDefaults.standard.set(encoded, forKey: key)
      print("DataService.swift: Saved data successfully for key - \(key)")
    } else {
      print("DataService.swift: Failed to save data for key - \(key)")
    }
  }
  func load<T: Codable>(forKey key: String) -> T? {
    if let savedData = UserDefaults.standard.data(forKey: key) {
      if let decoded = try? JSONDecoder().decode(T.self, from: savedData) {
        print("DataService.swift: Loaded data successfully for key - \(key)")
        return decoded
      }
    }
    print("DataService.swift: No data found for key - \(key)")
    return nil
  }
  func saveChats(chats: [Chat], forKey key: String) {
    if let encoded = try? JSONEncoder().encode(chats) {
      UserDefaults.standard.set(encoded, forKey: key)
      print("DataService.swift: Saved chats successfully for key - \(key)")
    } else {
      print("DataService.swift: Failed to save chats for key - \(key)")
    }
  }

  func loadChats(forKey key: String) -> [Chat]? {
    if let savedData = UserDefaults.standard.data(forKey: key) {
      if let decoded = try? JSONDecoder().decode([Chat].self, from: savedData) {
        print("DataService.swift: Loaded chats successfully for key - \(key)")
        return decoded
      }
    }
    print("DataService.swift: No chats found for key - \(key)")
    return nil
  }
}
