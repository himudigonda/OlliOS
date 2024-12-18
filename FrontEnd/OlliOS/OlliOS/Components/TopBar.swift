import SwiftUI

struct TopBar: View {
  @EnvironmentObject var modelService: ModelService
  @Binding var selectedModel: Model?

  var body: some View {
    HStack {
      // Dropdown for Model Selection
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
      }) {
        Image(systemName: "arrow.clockwise")
          .font(.system(size: 16))
          .foregroundColor(.blue)
      }
    }
    .padding()
    // .background(Color(UIColor.secondarySystemBackground))
    // .clipShape(RoundedRectangle(cornerRadius: 25))
  }
}
