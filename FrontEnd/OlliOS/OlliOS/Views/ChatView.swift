// FrontEnd/OlliOS/OlliOS/Views/ChatView.swift
import PhotosUI
import SwiftUI
import UniformTypeIdentifiers

struct ChatView: View {
  @EnvironmentObject var viewModel: ChatViewModel
  @State private var showModelUpdateBadge = false
  @State private var isGlobeActive = false
  @StateObject private var modelService = ModelService()
  @State private var selectedItem: PhotosPickerItem? = nil
  @State private var selectedImage: UIImage? = nil
  @State private var selectedDocumentURL: URL? = nil
  @State private var isDocumentPickerPresented = false

  var body: some View {
    ZStack {
      VStack(spacing: 0) {
        ScrollViewReader { proxy in
          ScrollView {
            LazyVStack(alignment: .leading, spacing: UIConstants.Spacing.small) {
              ForEach(viewModel.messages) { message in
                ChatBubble(message: message)
                  .transition(.slide)
                if let resourcePath = message.resourcePath, message.sender == .user {
                  if let url = URL(string: resourcePath),
                    let image = UIImage(contentsOfFile: url.path)
                  {
                    Image(uiImage: image)
                      .resizable()
                      .scaledToFit()
                      .frame(width: 100, height: 100)
                      .padding(.top, 4)
                  }
                }
              }
            }
            .padding(.horizontal)
            .padding(.top, UIConstants.Spacing.small)
          }
          .onChange(of: viewModel.messages.count) {
            scrollToLastMessage(proxy: proxy)
          }
        }

        // Attachments Area
        if !viewModel.attachments.isEmpty {
          ScrollView(.horizontal, showsIndicators: false) {
            HStack {
              ForEach(viewModel.attachments, id: \.self) { attachment in
                AttachmentView(url: attachment) {
                  viewModel.attachments.removeAll { $0 == attachment }
                }
              }
            }
            .padding(.horizontal)
          }
          .padding(.vertical, UIConstants.Spacing.small)
        }

        // Input Area
        VStack(spacing: 0) {
          Divider()
          HStack(spacing: UIConstants.Spacing.medium) {
            // Left buttons group
            HStack(spacing: UIConstants.Spacing.medium) {
              if modelService.selectedModel?.isMultiModal == true {
                Button(action: {
                  isDocumentPickerPresented.toggle()
                  print("ChatView.swift: Document button pressed")
                }) {
                  Image(systemName: "plus.circle.fill")
                    .font(.system(size: UIConstants.IconSizes.medium))
                    .foregroundColor(.blue)
                }
                PhotosPicker(
                  selection: $selectedItem,
                  matching: .images,
                  photoLibrary: .shared()
                ) {
                  Image(systemName: "photo.fill")
                    .font(.system(size: UIConstants.IconSizes.medium))
                    .foregroundColor(.blue)
                }
              }

              Button(action: { isGlobeActive.toggle() }) {
                Image(systemName: "globe")
                  .font(.system(size: UIConstants.IconSizes.medium))
                  .foregroundColor(isGlobeActive ? .blue : .gray)
              }
            }

            TextField("Message", text: $viewModel.userInput)
              .textFieldStyle(.plain)
              .padding(.horizontal, UIConstants.Spacing.medium)
              .padding(.vertical, UIConstants.Spacing.small)
              .background(Color.gray.opacity(0.2))
              .cornerRadius(UIConstants.CornerRadius.large)

            if viewModel.isLoading {
              ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
            } else {
              sendButton
            }
          }
          .padding(.horizontal)
          .padding(.vertical, UIConstants.Spacing.small)
          .background(Color.systemBackground)
        }
      }
      .background(Color.systemBackground)
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .principal) {
          Menu {
            ForEach(modelService.models, id: \.self) { model in
              Button(model.model_name) {
                viewModel.selectedModel = model
                modelService.selectedModel = model
                modelService.saveSelectedModel()
                print("ChatView.swift: Model selected - \(model.model_name)")
              }
            }
          } label: {
            HStack {
              Text(modelService.selectedModel?.model_name ?? "Select Model")
                .font(.system(size: 16))
              if showModelUpdateBadge {
                Circle()
                  .fill(Color.blue)
                  .frame(width: 8, height: 8)
              }
            }
          }
        }
        ToolbarItem(placement: .navigationBarTrailing) {
          Button(action: {
            viewModel.resetChat()
            print("ChatView.swift: Chat reset")
          }) {
            Image(systemName: "arrow.clockwise")
              .foregroundColor(.blue)
          }
        }
      }
      .onAppear {
        modelService.fetchModels()
        print("ChatView.swift: modelService.fetchModels called")
      }
      .onReceive(modelService.$models) { _ in
        withAnimation {
          showModelUpdateBadge = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
          withAnimation {
            showModelUpdateBadge = false
          }
        }
        print("ChatView.swift: Models updated")
      }
      .onChange(of: selectedItem) { newItem in
        Task {
          if let data = try? await newItem?.loadTransferable(type: Data.self) {
            selectedImage = UIImage(data: data)

            // Get temp directory
            let tempDir = FileManager.default.temporaryDirectory
            let fileURL = tempDir.appendingPathComponent("selected_image.jpg")

            do {
              try data.write(to: fileURL)
              print("ChatView.swift: image file saved in - \(fileURL)")
              viewModel.attachments.append(fileURL)
            } catch {
              print("ChatView.swift: Error saving file - \(error)")
            }

          }
          selectedItem = nil
        }
      }
      .sheet(
        isPresented: $isDocumentPickerPresented,
        content: {
          DocumentPickerView(documentURL: $selectedDocumentURL)
        }
      )
      .onChange(of: selectedDocumentURL) { newURL in
        if let url = newURL {
          print("ChatView.swift: Document selected URL - \(url)")
          viewModel.attachments.append(url)
          selectedDocumentURL = nil
        }
      }
      .onChange(of: viewModel.selectedModel) { newModel in
        if newModel?.isMultiModal == true {
          print(">>>>>>>>>>>>>>>>>>>>>>>> mm")
        }
      }
    }
  }

  private var sendButton: some View {
    let buttonSize = UIConstants.ButtonSize.send
    let buttonColor =
      viewModel.userInput.isEmpty && viewModel.attachments.isEmpty ? Color.gray : Color.blue

    return Button(action: {
      viewModel.sendMessage()
      print("ChatView.swift: Send button pressed")
    }) {
      Image(systemName: "paperplane.fill")
        .font(.system(size: UIConstants.IconSizes.medium))
        .foregroundColor(.white)
        .frame(width: buttonSize, height: buttonSize)
        .background(
          Circle()
            .fill(buttonColor)
            .shadow(color: buttonColor.opacity(0.3), radius: 4, x: 0, y: 2)
        )
        .scaleEffect(
          viewModel.userInput.isEmpty && viewModel.attachments.isEmpty ? 0.95 : 1.0
        )
        .animation(
          .spring(response: 0.3),
          value: viewModel.userInput.isEmpty && viewModel.attachments.isEmpty
        )
    }
    .disabled(viewModel.userInput.isEmpty && viewModel.attachments.isEmpty)
  }

  private func scrollToLastMessage(proxy: ScrollViewProxy) {
    guard let lastMessageId = viewModel.messages.last?.id else { return }

    withAnimation {
      proxy.scrollTo(lastMessageId, anchor: .bottom)
    }
    print("ChatView.swift: Scrolled to last message")
  }
}

struct AttachmentView: View {
  let url: URL
  let onRemove: () -> Void

  var body: some View {
    VStack {
      if let image = UIImage(contentsOfFile: url.path) {
        Image(uiImage: image)
          .resizable()
          .scaledToFit()
          .frame(width: 100, height: 100)
      } else {
        Text(url.lastPathComponent)
          .font(.caption)
          .lineLimit(1)
          .frame(width: 100, height: 100)
          .background(Color.gray.opacity(0.2))
          .cornerRadius(8)
      }
      Button(action: onRemove) {
        Image(systemName: "xmark.circle.fill")
          .foregroundColor(.red)
      }
    }
  }
}
