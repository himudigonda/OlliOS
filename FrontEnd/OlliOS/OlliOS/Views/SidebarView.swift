import SwiftUI

struct SidebarView: View {
  var body: some View {
    VStack {
      Text("Sidebar")
        .font(.title)
        .padding()
      Spacer()
    }
    .frame(maxWidth: 250)
    .background(Color(UIColor.systemGray5))
    .ignoresSafeArea()
  }
}
