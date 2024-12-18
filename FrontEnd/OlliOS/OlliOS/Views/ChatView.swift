import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

struct ChatView: View {
  @EnvironmentObject var viewModel: ChatViewModel
  @EnvironmentObject var modelService: ModelService
  @State private var isGlobeActive = false
  @State private var selectedItem: PhotosPickerItem? = nil
  @State private var selectedImage: UIImage? = nil
  @State private var isDocumentPickerPresented = false

  var body: some View {
    NavigationStack {
      VStack(spacing: 0) {
        // Messages Scroll Area
        ScrollViewReader { proxy in
          ScrollView {
            LazyVStack(alignment: .leading, spacing: 8) {
              ForEach(viewModel.messages) { message in
                ChatBubble(message: message)
              }
            }
            .padding(.horizontal)
            .padding(.top, 8)
          }
          .onChange(of: viewModel.messages.count) {
            scrollToLastMessage(proxy: proxy)
          }
        }

        // Bottom Input Bar
        VStack(spacing: 8) {
          // First Row: Message Input Field
          TextField("What's on your mind?", text: $viewModel.userInput, axis: .vertical)
            .textFieldStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(Color.systemGray6)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .lineLimit(1...3)

          // Second Row: Buttons
          HStack(spacing: 12) {
            // Left Buttons
            HStack(spacing: 12) {
              Button(action: {
                if !isGlobeActive {
                  isDocumentPickerPresented.toggle()
                }
              }) {
                Image(systemName: "plus.circle.fill")
                  .font(.system(size: 24))
                  .foregroundColor(isGlobeActive ? .gray : .blue)
              }
              .disabled(isGlobeActive)

              PhotosPicker(selection: $selectedItem, matching: .images) {
                Image(systemName: "photo.fill")
                  .font(.system(size: 24))
                  .foregroundColor(isGlobeActive ? .gray : .blue)
              }
              .disabled(isGlobeActive)
            }

            Spacer()

            // Right Buttons
            HStack(spacing: 12) {
              if isGlobeActive {
                Button(action: {
                  print("Web button pressed")
                }) {
                  Text("Web")
                    .foregroundColor(.blue)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.lightBlue)
                    .clipShape(Capsule())
                }
                .transition(.move(edge: .leading))
              }

              Button(action: {
                isGlobeActive.toggle()
              }) {
                Image(systemName: "globe")
                  .font(.system(size: 24))
                  .foregroundColor(isGlobeActive ? .blue : .gray)
              }
              .animation(.easeInOut, value: isGlobeActive)

              Button(action: { viewModel.sendMessage() }) {
                Image(systemName: "arrow.up.circle.fill")
                  .font(.system(size: 30))
                  .foregroundColor(.blue)
              }
              .disabled(viewModel.userInput.isEmpty)
            }
          }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 25))
        .padding(.horizontal)
        .padding(.bottom, 8)
      }
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          // TopBar replaces the navigation title
          TopBar(selectedModel: $viewModel.selectedModel)
            .environmentObject(modelService)
        }
      }
      .onChange(of: selectedItem) { newItem in
        loadSelectedImage(newItem)
      }
      .sheet(isPresented: $isDocumentPickerPresented) {
        DocumentPickerView(documentURL: .constant(nil))
      }
    }
  }

  // MARK: - Helper Functions
  private func loadSelectedImage(_ item: PhotosPickerItem?) {
    Task {
      if let data = try? await item?.loadTransferable(type: Data.self),
        let image = UIImage(data: data)
      {
        selectedImage = image
        saveImageToTempDirectory(image)
      }
    }
  }

  private func saveImageToTempDirectory(_ image: UIImage) {
    let tempDir = FileManager.default.temporaryDirectory
    let fileURL = tempDir.appendingPathComponent("selected_image.jpg")
    if let data = image.jpegData(compressionQuality: 0.8) {
      do {
        try data.write(to: fileURL)
        viewModel.attachments.append(fileURL)
      } catch {
        print("Error saving image: \(error)")
      }
    }
  }

  private func scrollToLastMessage(proxy: ScrollViewProxy) {
    if let lastMessageId = viewModel.messages.last?.id {
      withAnimation {
        proxy.scrollTo(lastMessageId, anchor: .bottom)
      }
    }
  }
}
