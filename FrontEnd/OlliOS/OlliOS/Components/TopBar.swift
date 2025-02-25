// FrontEnd/OlliOS/OlliOS/Components/TopBar.swift
import SwiftUI

struct TopBar: View {
  @EnvironmentObject var modelService: ModelService
  @Binding var selectedModel: Model?
  @Binding var isSidebarVisible: Bool

  var body: some View {
    HStack {

      Button(action: {
        isSidebarVisible.toggle()
      }) {
        Image(systemName: "line.horizontal.3")
          .font(.system(size: 20))
          .foregroundColor(.blue)
      }
      Spacer()

      // Dropdown Menu Centered
      Menu {
        ForEach(modelService.models, id: \.self) { model in
          Button(action: {
            selectedModel = model
            modelService.saveSelectedModel()
          }) {
            Text(model.model_name)
          }
        }
      } label: {
        HStack {
          Text(selectedModel?.model_name ?? "Select Model")
            .font(.system(size: 16, weight: .semibold))
          Image(systemName: "chevron.down")
            .foregroundColor(.blue)
        }
      }

      Spacer()

      // Reset Chat Button
      Button(action: {
        print("Reset Chat")
        //TODO: Add reset function
      }) {
        Image(systemName: "arrow.clockwise")
          .font(.system(size: 16))
          .foregroundColor(.blue)
      }
    }
    .padding(.horizontal, 0)
    .padding(.vertical, 10)
  }
}
