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
            .font(.system(size: 18, weight: .semibold))
          Image(systemName: "chevron.down")
            .foregroundColor(.blue)
        }
      }

      Spacer()
      Button(action: { /* Reset Chat Action */  }) {
        Image(systemName: "arrow.clockwise")
          .font(.system(size: 18))
          .foregroundColor(.blue)
      }
    }
    .padding()
    .background(Color(UIColor.secondarySystemBackground))
  }
}
