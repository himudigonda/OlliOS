// FrontEnd/OlliOS/OlliOS/Views/ChatView.swift
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
  let chat: Chat

  var body: some View {
    VStack(spacing: 0) {
      // Messages Scroll Area
      ScrollViewReader { proxy in
        ScrollView {
          LazyVStack(alignment: .leading, spacing: 8) {
            ForEach(chat.messages) { message in
              ChatBubble(message: message)
            }
          }
          .padding(.horizontal)
          .padding(.top, 8)
        }
        .onChange(of: chat.messages.count) {
          scrollToLastMessage(proxy: proxy)
        }
      }

      // Bottom Input Bar
      VStack(spacing: 0) {
        // Attachment Row (Conditional)
        if !viewModel.attachments.isEmpty {
          ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
              ForEach(viewModel.attachments.indices, id: \.self) { index in
                AttachmentThumbnail(url: viewModel.attachments[index]) {
                  viewModel.attachments.remove(at: index)
                }
              }
            }
            .padding(.horizontal, 15)
            .padding(.top, 20)
          }
          .frame(height: 95)  // Thumbnail Row Height
          .transition(.opacity)
        }

        // Input Row: Text Field + Buttons
        VStack(spacing: 8) {
          // Message Input Field
          TextField("What's on your mind?", text: $viewModel.userInput)
            .textFieldStyle(.plain)
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background(Color.systemGray6)
            .clipShape(RoundedRectangle(cornerRadius: 20))

          // Buttons Row
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
      }
      .background(Color(UIColor.secondarySystemBackground))
      .clipShape(RoundedRectangle(cornerRadius: 25))
      .padding(.horizontal)
      .padding(.bottom, 8)
      .animation(.easeInOut, value: viewModel.attachments.isEmpty)
    }
    .onChange(of: selectedItem) { newItem in
      loadSelectedImage(newItem)
    }
    .sheet(isPresented: $isDocumentPickerPresented) {
      DocumentPickerView(documentURL: .constant(nil))
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
    let fileURL = tempDir.appendingPathComponent(UUID().uuidString + ".jpg")
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
    if let lastMessageId = chat.messages.last?.id {
      withAnimation {
        proxy.scrollTo(lastMessageId, anchor: .bottom)
      }
    }
  }
}

// MARK: - Attachment Thumbnail View
struct AttachmentThumbnail: View {
  let url: URL
  let onRemove: () -> Void

  var body: some View {
    ZStack(alignment: .topTrailing) {
      Image(uiImage: UIImage(contentsOfFile: url.path) ?? UIImage())
        .resizable()
        .scaledToFill()
        .frame(width: 80, height: 80)
        .clipShape(RoundedRectangle(cornerRadius: 12))

      Button(action: onRemove) {
        Image(systemName: "xmark.circle.fill")
          .foregroundColor(.red)
          .background(Color.white)
          .clipShape(Circle())
      }
      .offset(x: 8, y: -8)
    }
  }
}
