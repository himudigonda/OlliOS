// FrontEnd/OlliOS/OlliOS/Views/SettingsPage.swift
import SwiftUI

struct SettingsPage: View {
  @EnvironmentObject var viewModel: ChatViewModel
  @Environment(\.dismiss) var dismiss
  @State private var showDeleteConfirmation = false

  var body: some View {
    List {
      Section(header: Text("Account")) {
        SettingsRow(icon: "envelope", title: "Email", rightText: "himudigonda@gmail.com")
        SettingsRow(icon: "plus.square", title: "Subscription", rightText: "OlliOS Plus")
      }

      Section(header: Text("Chat Management")) {
        Button("Delete All Chats") {
          showDeleteConfirmation = true
          print("SettingsPage.swift: Delete All Chats button pressed")
        }
        .foregroundColor(.red)  // Highlight destructive action with red
      }
    }
    .navigationTitle("Settings")
    .alert("Delete All Chats", isPresented: $showDeleteConfirmation) {
      Button("Delete", role: .destructive) {
        viewModel.deleteAllChats()
        print("SettingsPage.swift: All chats deleted")
      }
      Button("Cancel", role: .cancel) {
        showDeleteConfirmation = false
        print("SettingsPage.swift: Delete All Chats cancelled")
      }
    } message: {
      Text("Are you sure you want to delete all chats?")
    }

  }
}
