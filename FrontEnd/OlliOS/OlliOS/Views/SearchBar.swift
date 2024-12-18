// frontend/OlliOS/OlliOS/Views/SearchBar.swift
import SwiftUI

struct SearchBar: View {
  @Binding var text: String

  var body: some View {
    HStack {
      Image(systemName: "magnifyingglass")
        .foregroundColor(.gray)
      TextField("Search", text: $text)
        .foregroundColor(.primary)
        .autocapitalization(.none)
        .disableAutocorrection(true)
      if !text.isEmpty {
        Button(action: {
          text = ""
          print("SearchBar.swift: Clear button pressed")
        }) {
          Image(systemName: "xmark.circle.fill")
            .foregroundColor(.gray)
        }
      }
    }
    .padding(8)
    .background(Color(.systemGray6))
    .cornerRadius(10)
    .padding(.horizontal)
  }
}
