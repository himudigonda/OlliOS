import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

struct ChatView: View {
  @EnvironmentObject var viewModel: ChatViewModel
  @State private var isGlobeActive = false
  @State private var selectedItem: PhotosPickerItem? = nil
  @State private var selectedImage: UIImage? = nil
  @State private var isDocumentPickerPresented = false

  var body: some View {
    VStack(spacing: 0) {
      // Top Navigation Bar
      HStack {
        Text(viewModel.selectedModel?.model_name ?? "Select Model")
          .font(.system(size: 18, weight: .semibold))
          .foregroundColor(.blue)
          .onTapGesture {
            showModelPicker()
          }
        Spacer()
        Button(action: { viewModel.resetChat() }) {
          Image(systemName: "arrow.clockwise")
            .font(.system(size: 18))
            .foregroundColor(.blue)
        }
      }
      .padding()
      .background(Color(UIColor.systemBackground))
      // .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 1)

      Divider()

      // Messages Scroll Area
      ScrollViewReader { proxy in
        ScrollView {
          LazyVStack(alignment: .leading, spacing: 8) {
            ForEach(viewModel.messages) { message in
              ChatBubble(message: message)

              if let image = selectedImage, message.sender == .user {
                Image(uiImage: image)
                  .resizable()
                  .scaledToFit()
                  .frame(width: 150, height: 150)
                  .clipShape(RoundedRectangle(cornerRadius: 12))
                  .padding(.top, 4)
              }
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
      VStack(spacing: 0) {
        VStack(spacing: 8) {
          // First Row: Message Input Field
          TextField("Message", text: $viewModel.userInput, axis: .vertical)
            .textFieldStyle(.plain)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            // .background(Color.gray.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .lineLimit(1...3)

          // Second Row: Buttons
          HStack(spacing: 16) {
            // Left Icons
            HStack(spacing: 12) {
              Button(action: {
                isDocumentPickerPresented.toggle()
              }) {
                Image(systemName: "plus.circle.fill")
                  .font(.system(size: 24))
                  .foregroundColor(.blue)
              }

              PhotosPicker(selection: $selectedItem, matching: .images) {
                Image(systemName: "photo.fill")
                  .font(.system(size: 24))
                  .foregroundColor(.blue)
              }
            }

            Spacer()

            // Right Icons
            HStack(spacing: 12) {
              Button(action: { isGlobeActive.toggle() }) {
                Image(systemName: "globe")
                  .font(.system(size: 24))
                  .foregroundColor(isGlobeActive ? .blue : .gray)
              }

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
      }
      .padding(.bottom, 8)
    }
    .onChange(of: selectedItem) { newItem in
      loadSelectedImage(newItem)
    }
    .sheet(isPresented: $isDocumentPickerPresented) {
      DocumentPickerView(documentURL: .constant(nil))
    }
  }

  // MARK: - Helper Functions
  private func showModelPicker() {
    print("Model picker tapped")
  }

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
