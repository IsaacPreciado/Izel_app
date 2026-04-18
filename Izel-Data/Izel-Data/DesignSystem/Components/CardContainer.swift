import SwiftUI

struct CardContainer<Content: View>: View {
    var background: Color = Theme.Colors.surfaceContainerLow
    var cornerRadius: CGFloat = Theme.Radius.xl
    var padding: CGFloat = Theme.Spacing.md
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(padding)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
    }
}

#Preview {
    CardContainer {
        Text("Card content")
    }
    .padding()
}
