// FrontEnd/OlliOS/OlliOS/ContentView.swift
import SwiftUI

struct ContentView: View {
  @State private var isSidebarVisible = false
  @EnvironmentObject var modelService: ModelService
  @EnvironmentObject var viewModel: ChatViewModel

  var body: some View {
    ZStack(alignment: .leading) {
      NavigationView {
        if let currentChat = viewModel.selectedChat {
          ChatView(chat: currentChat)  // Pass current chat to ChatView
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
              ToolbarItem(placement: .principal) {
                TopBar(selectedModel: $viewModel.selectedModel, isSidebarVisible: $isSidebarVisible)
                  .environmentObject(modelService)
              }
            }
        } else {
          Text("No Chat Selected")
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
              ToolbarItem(placement: .principal) {
                TopBar(selectedModel: $viewModel.selectedModel, isSidebarVisible: $isSidebarVisible)
                  .environmentObject(modelService)
              }
            }
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
      .offset(x: isSidebarVisible ? UIScreen.main.bounds.width * 0.75 : 0)
      .disabled(isSidebarVisible)

      if isSidebarVisible {
        SidebarView(isSidebarVisible: $isSidebarVisible)
          .frame(width: UIScreen.main.bounds.width * 0.75)
          .transition(.move(edge: .leading))
      }
    }
    .animation(.easeInOut, value: isSidebarVisible)
  }
}

struct SidebarView: View {
  @EnvironmentObject var viewModel: ChatViewModel
  @Binding var isSidebarVisible: Bool

  var sortedChats: [Chat] {
    viewModel.chats.sorted {
      if $0.isPinned && !$1.isPinned {
        return true
      } else if !$0.isPinned && $1.isPinned {
        return false
      } else {
        return $0.createdDate > $1.createdDate
      }
    }
  }

  var body: some View {
    ZStack {
      Color.black.opacity(0.5)
        .edgesIgnoringSafeArea(.all)
        .onTapGesture {
          isSidebarVisible = false
        }
      VStack(alignment: .leading, spacing: 20) {
        HStack {
          SearchBar(text: .constant(""))
            .frame(maxHeight: 35)
          Spacer()
          Button(action: {
            viewModel.createNewChat()
          }) {
            Image(systemName: "square.and.pencil")
              .font(.system(size: 20))
              .foregroundColor(.blue)
          }
        }.padding([.top, .horizontal])

        // List of Models (Placeholder)
        VStack(alignment: .leading) {

          ScrollView {
            VStack(alignment: .leading, spacing: 10) {
              ForEach(sortedChats) { chat in
                ChatRow(chat: chat)
              }
            }
            .padding(.horizontal)

          }

        }
        .padding(.top, 10)

        Spacer()
        HStack {
          Image(systemName: "person.circle.fill")
            .resizable()
            .frame(width: 30, height: 30)
            .foregroundColor(.orange)
          Text("Himansh Mudigonda")
            .font(.subheadline)
            .padding(10)
          Spacer()
        }
        .padding(.horizontal)

      }
      .frame(width: UIScreen.main.bounds.width * 0.75, alignment: .leading)
      .background(Color.systemGray5)
    }
  }
}

struct ChatRow: View {
  @EnvironmentObject var viewModel: ChatViewModel
  let chat: Chat

  var body: some View {
    HStack {
      Button(action: {
        viewModel.selectChat(chat: chat)
      }) {
        Text(chat.title)
          .font(.system(size: 16))
          .foregroundColor(.primary)
        Spacer()
      }
      .contextMenu {
        Button(action: {
          viewModel.pinChat(chat: chat)
        }) {
          Label(chat.isPinned ? "Unpin" : "Pin", systemImage: "pin")
        }
        Button(action: {
          //  viewModel.shareChat(chat: chat) // Implement share functionality
          print("Share Chat")
        }) {
          Label("Share", systemImage: "square.and.arrow.up")
        }
        Button(
          role: .destructive,
          action: {
            viewModel.deleteChat(chat: chat)
          }
        ) {
          Label("Delete", systemImage: "trash")
        }
      }
      if chat.isPinned {
        Image(systemName: "pin.fill")
          .foregroundColor(.gray)
          .font(.system(size: 12))
      }
    }
    .padding(.vertical, UIConstants.Spacing.small)
  }
}
