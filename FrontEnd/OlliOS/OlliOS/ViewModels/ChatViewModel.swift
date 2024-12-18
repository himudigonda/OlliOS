// FrontEnd/OlliOS/OlliOS/ViewModels/ChatViewModel.swift
import Combine
import Foundation
import SwiftUI

class ChatViewModel: ObservableObject {
  @Published var chats: [Chat] = []
  @Published var selectedChat: Chat? = nil
  @Published var userInput: String = ""
  @Published var isLoading: Bool = false
  @Published var selectedModel: Model?
  @Published var attachments: [URL] = []
  private let apiService = ApiService()
  private let dataService = DataService()
  private var cancellables = Set<AnyCancellable>()

  init() {
    loadChats()
    if chats.isEmpty {
      createNewChat()
    } else {
      selectedChat = chats.first
    }
    print("ChatViewModel.swift: Initialized")
  }

  // MARK: - Chat Management
  func createNewChat() {
    let newChat = Chat(title: "New Chat", messages: [])
    chats.append(newChat)
    selectedChat = newChat
    saveChats()
    print("ChatViewModel.swift: Created new chat - \(newChat.title)")
  }

  func selectChat(chat: Chat) {
    selectedChat = chat
    print("ChatViewModel.swift: Selected chat - \(chat.title)")
  }

  func deleteChat(chat: Chat) {
    if let index = chats.firstIndex(where: { $0.id == chat.id }) {
      chats.remove(at: index)
      if selectedChat?.id == chat.id {
        selectedChat = chats.first
      }
      saveChats()
      print("ChatViewModel.swift: Chat deleted - \(chat.title)")
    }
  }
  func pinChat(chat: Chat) {
    if let index = chats.firstIndex(where: { $0.id == chat.id }) {
      chats[index].isPinned.toggle()
      saveChats()
      print("ChatViewModel.swift: Chat pinned - \(chat.title)")
    }
  }

  // MARK: - Message Handling
  func sendMessage() {
    guard let currentChat = selectedChat, !userInput.isEmpty || !attachments.isEmpty else {
      print("ChatViewModel.swift: Message not sent due to empty user input and attachments")
      return
    }
    let message = ChatMessage(
      content: userInput, sender: .user, isThinking: false, timestamp: Date(),
      chat_id: currentChat.id
    )

    if let chatIndex = chats.firstIndex(where: { $0.id == currentChat.id }) {
      chats[chatIndex].messages.append(message)
      saveChats()
    }
    print("ChatViewModel.swift: Added user message - \(message.content)")
    userInput = ""
    print("ChatViewModel.swift: Input cleared")
    fetchResponse(for: message.content, attachments: attachments, currentChatId: currentChat.id)

    print(
      "ChatViewModel.swift: Message sent - \(message.content) with attachments - \(attachments.map { $0.lastPathComponent }.joined(separator: ", "))"
    )
    attachments.removeAll()  // Clear attachments after sending
    print("ChatViewModel.swift: Attachments cleared")
  }
  private func fetchResponse(for input: String, attachments: [URL], currentChatId: UUID) {
    guard let url = URL(string: "\(APIConstants.baseURL)\(APIConstants.generateTextEndpoint)"),
      let model = selectedModel
    else {
      isLoading = false
      hideThinkingBubble(chatId: currentChatId)
      addMessage(
        message: ChatMessage(
          content: "Error: Invalid URL, model not selected or no current chat",
          sender: .assistant,
          isThinking: false,
          timestamp: Date(), chat_id: currentChatId
        ),
        chatId: currentChatId
      )
      print("ChatViewModel.swift: Error - Invalid URL or model not selected")
      return
    }
    let body: [String: String] = [
      "user_input": input,
      "model_name": model.model_name,
      "chat_id": currentChatId.uuidString,
    ]
    let queryParams: [String: String] = [:]

    isLoading = true
    print("ChatViewModel.swift: Loading started")
    addThinkingBubble(chatId: currentChatId)

    apiService.post(to: url, body: body, queryParams: queryParams, fileURLs: attachments)
      .receive(on: DispatchQueue.main)
      .sink(
        receiveCompletion: { completion in
          self.isLoading = false
          print("ChatViewModel.swift: Loading completed")
          self.hideThinkingBubble(chatId: currentChatId)
          if case .failure(let error) = completion {
            self.addMessage(
              message: ChatMessage(
                content: "Error: \(error.localizedDescription)",
                sender: .assistant,
                isThinking: false,
                timestamp: Date(), chat_id: currentChatId
              ),
              chatId: currentChatId
            )
            print("ChatViewModel.swift: Error - \(error.localizedDescription)")
          }
        },
        receiveValue: { (response: TextResponse) in
          self.hideThinkingBubble(chatId: currentChatId)
          self.addMessage(
            message: ChatMessage(
              content: response.response,
              sender: .assistant,
              isThinking: false,
              timestamp: Date(), chat_id: currentChatId
            ),
            chatId: currentChatId
          )
          print("ChatViewModel.swift: Response received - \(response.response)")
        }
      )
      .store(in: &cancellables)
  }

  private func addMessage(message: ChatMessage, chatId: UUID) {
    if let chatIndex = chats.firstIndex(where: { $0.id == chatId }) {
      chats[chatIndex].messages.append(message)
      saveChats()
    }
    print("ChatViewModel.swift: Message added - \(message.content)")
  }

  private func addThinkingBubble(chatId: UUID) {
    let thinkingMessage = ChatMessage(
      content: "Thinking...", sender: .assistant, isThinking: true, timestamp: Date(),
      chat_id: chatId
    )

    if let chatIndex = chats.firstIndex(where: { $0.id == chatId }) {
      chats[chatIndex].messages.append(thinkingMessage)
      saveChats()
    }
    print("ChatViewModel.swift: Thinking bubble added")
  }

  private func hideThinkingBubble(chatId: UUID) {
    if let chatIndex = chats.firstIndex(where: { $0.id == chatId }),
      let index = chats[chatIndex].messages.firstIndex(where: { $0.isThinking })
    {
      chats[chatIndex].messages.remove(at: index)
      saveChats()
      print("ChatViewModel.swift: Thinking bubble hidden")
    }
  }

  // MARK: - Saving & Loading
  private func loadChats() {
    if let savedChats: [Chat] = dataService.loadChats(forKey: "savedChats") {
      self.chats = savedChats
      print("ChatViewModel.swift: Chats loaded successfully")
    }
    print("ChatViewModel.swift: No chats found, created default")
  }

  private func saveChats() {
    dataService.saveChats(chats: chats, forKey: "savedChats")
  }

  // MARK: - Utility functions
  func resetChat() {
    if let chatIndex = chats.firstIndex(where: { $0.id == selectedChat?.id }) {
      chats[chatIndex].messages.removeAll()
      saveChats()
    }
    print("ChatViewModel.swift: Chat reset")
  }

  func deleteAllChats() {
    chats.removeAll()
    selectedChat = nil
    saveChats()
    print("ChatViewModel.swift: All chats deleted")
  }

  func savePreferences() {
    // Implement saving preferences if needed
    print("ChatViewModel.swift: Preferences saved")
  }
}
