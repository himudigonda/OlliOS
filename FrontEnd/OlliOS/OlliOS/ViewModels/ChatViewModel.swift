// FrontEnd/OlliOS/OlliOS/ViewModels/ChatViewModel.swift
import Combine
import Foundation
import SwiftUI

class ChatViewModel: ObservableObject {
  @Published var messages: [ChatMessage] = []
  @Published var userInput: String = ""
  @Published var isLoading: Bool = false
  @Published var selectedModel: Model?
  @Published var attachments: [URL] = []  // Store selected attachments
  private let apiService = ApiService()
  private var cancellables = Set<AnyCancellable>()

  init() {
    print("ChatViewModel.swift: Initialized")
  }

  func sendMessage() {
    guard !userInput.isEmpty || !attachments.isEmpty else {
      print("ChatViewModel.swift: Message not sent due to empty user input and attachments")
      return
    }

    let message = ChatMessage(
      content: userInput, sender: .user, isThinking: false, timestamp: Date()
    )
    messages.append(message)
    print("ChatViewModel.swift: Added user message - \(message.content)")
    userInput = ""
    print("ChatViewModel.swift: Input cleared")
    fetchResponse(for: message.content, attachments: attachments)

    print(
      "ChatViewModel.swift: Message sent - \(message.content) with attachments - \(attachments.map { $0.lastPathComponent }.joined(separator: ", "))"
    )
    attachments.removeAll()  // Clear attachments after sending
    print("ChatViewModel.swift: Attachments cleared")
  }

  private func fetchResponse(for input: String, attachments: [URL]) {
    guard let url = URL(string: "\(APIConstants.baseURL)\(APIConstants.generateTextEndpoint)"),
      let model = selectedModel
    else {
      isLoading = false
      hideThinkingBubble()
      addMessage(
        message: ChatMessage(
          content: "Error: Invalid URL or model not selected",
          sender: .assistant,
          isThinking: false,
          timestamp: Date()
        )
      )
      print("ChatViewModel.swift: Error - Invalid URL or model not selected")
      return
    }

    let body: [String: String] = ["user_input": input, "model_name": model.model_name]
    let queryParams: [String: String] = [:]

    isLoading = true
    print("ChatViewModel.swift: Loading started")
    addThinkingBubble()

    apiService.post(to: url, body: body, queryParams: queryParams, fileURLs: attachments)
      .receive(on: DispatchQueue.main)
      .sink(
        receiveCompletion: { completion in
          self.isLoading = false
          print("ChatViewModel.swift: Loading completed")
          self.hideThinkingBubble()
          if case .failure(let error) = completion {
            self.addMessage(
              message: ChatMessage(
                content: "Error: \(error.localizedDescription)",
                sender: .assistant,
                isThinking: false,
                timestamp: Date()
              )
            )
            print("ChatViewModel.swift: Error - \(error.localizedDescription)")
          }
        },
        receiveValue: { (response: TextResponse) in
          self.hideThinkingBubble()
          self.addMessage(
            message: ChatMessage(
              content: response.response,
              sender: .assistant,
              isThinking: false,
              timestamp: Date()
            )
          )
          print("ChatViewModel.swift: Response received - \(response.response)")
        }
      )
      .store(in: &cancellables)
  }

  private func addMessage(message: ChatMessage) {
    messages.append(message)
    print("ChatViewModel.swift: Message added - \(message.content)")
  }

  private func addThinkingBubble() {
    let thinkingMessage = ChatMessage(
      content: "Thinking...", sender: .assistant, isThinking: true, timestamp: Date())
    messages.append(thinkingMessage)
    print("ChatViewModel.swift: Thinking bubble added")
  }

  private func hideThinkingBubble() {
    if let index = messages.firstIndex(where: { $0.isThinking }) {
      messages.remove(at: index)
      print("ChatViewModel.swift: Thinking bubble hidden")
    }
  }

  func resetChat() {
    messages.removeAll()
    print("ChatViewModel.swift: Chat reset")
  }

  func deleteAllChats() {
    messages.removeAll()
    print("ChatViewModel.swift: All chats deleted")
  }

  func savePreferences() {
    // Implement saving preferences if needed
    print("ChatViewModel.swift: Preferences saved")
  }
}
