import SwiftUI

struct ContentView: View {
  @State private var isSidebarVisible = false

  var body: some View {
    ZStack {
      ChatView()
      if isSidebarVisible {
        SidebarView()
          .transition(.move(edge: .leading))
      }
    }
    .gesture(
      DragGesture()
        .onEnded { value in
          if value.translation.width > 50 { isSidebarVisible = true }
          if value.translation.width < -50 { isSidebarVisible = false }
        }
    )
  }
}
