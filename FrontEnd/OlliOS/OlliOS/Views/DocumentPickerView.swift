// FrontEnd/OlliOS/OlliOS/Views/DocumentPickerView.swift
import SwiftUI
import UniformTypeIdentifiers

struct DocumentPickerView: UIViewControllerRepresentable {
  @Binding var documentURL: URL?

  func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
    let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [
      .image, .pdf, .text,
    ])
    documentPicker.delegate = context.coordinator
    return documentPicker
  }

  func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context)
  {
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }

  class Coordinator: NSObject, UIDocumentPickerDelegate {
    let parent: DocumentPickerView

    init(_ documentPickerView: DocumentPickerView) {
      self.parent = documentPickerView
    }

    func documentPicker(
      _ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]
    ) {
      guard let url = urls.first else { return }
      parent.documentURL = url
    }

    func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
      controller.dismiss(animated: true, completion: nil)
    }
  }
}
