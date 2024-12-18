import SwiftUI

struct ChatBubble: View {
  let message: ChatMessage
  var isUser: Bool { message.sender == .user }

  var body: some View {
    HStack(alignment: .top, spacing: UIConstants.Spacing.small) {
      if isUser {
        Spacer()  // Push user message to the right
      }

      // Chat bubble with message
      Text(message.content)
        .font(.system(size: 16))
        .padding(.horizontal, UIConstants.Spacing.medium)
        .padding(.vertical, UIConstants.Spacing.small)
        .background(
          Group {
            if isUser {
              Color.blue  // User message bubble color
            } else if message.isThinking {
              Color.gray.opacity(0.3)  // Thinking bubble color
            } else {
              Color.gray.opacity(0.2)  // Assistant message bubble color
            }
          }
        )
        .foregroundColor(isUser ? .white : message.isThinking ? .gray : .primary)
        .clipShape(RoundedRectangle(cornerRadius: UIConstants.CornerRadius.large))
        .frame(maxWidth: UIScreen.main.bounds.width * 0.7, alignment: isUser ? .trailing : .leading)
    }
    .padding(.vertical, 4)  // space between messages
  }
}
