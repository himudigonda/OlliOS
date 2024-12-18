// FrontEnd/OlliOS/OlliOS/ContentView.swift
import SwiftUI

struct ContentView: View {
  @State private var isSidebarVisible = false
  @EnvironmentObject var modelService: ModelService
  @EnvironmentObject var viewModel: ChatViewModel

  var body: some View {
    ZStack(alignment: .leading) {  // Modified for correct sidebar overlay behavior.

      NavigationView {
        ChatView()
          .navigationTitle("Chat")
          .navigationBarTitleDisplayMode(.inline)
          .toolbar {
            ToolbarItem(placement: .principal) {
              TopBar(selectedModel: $viewModel.selectedModel, isSidebarVisible: $isSidebarVisible)
                .environmentObject(modelService)
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
  @Binding var isSidebarVisible: Bool

  var body: some View {
    ZStack {
      Color.black.opacity(0.5)
        .edgesIgnoringSafeArea(.all)
        .onTapGesture {
          isSidebarVisible = false
        }
      VStack(alignment: .leading, spacing: 20) {
        HStack {
          Spacer()
          Button(action: {
            isSidebarVisible = false
          }) {
            Image(systemName: "xmark")
              .font(.system(size: 20))
              .foregroundColor(.gray)
          }
        }.padding([.top, .trailing])

        // Search Bar
        SearchBar(text: .constant(""))
          .padding(.horizontal)

        // List of Models (Placeholder)
        VStack(alignment: .leading) {
          Text("Pinned Chats")
            .font(.headline)
            .padding(.leading)
            .foregroundColor(.gray)

        }
        .padding(.top, 10)

        VStack(alignment: .leading) {
          Text("Chats")
            .font(.headline)
            .padding(.leading)
            .foregroundColor(.gray)
          ScrollView {
            VStack(alignment: .leading, spacing: 10) {


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
          // Image(systemName: "ellipsis")
          //   .foregroundColor(.gray)
        }
        .padding(.horizontal)

      }
      .frame(width: UIScreen.main.bounds.width * 0.75, alignment: .leading)
      .background(Color.systemGray5)
    }
  }
}
