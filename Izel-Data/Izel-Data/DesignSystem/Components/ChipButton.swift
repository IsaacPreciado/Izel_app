import SwiftUI

struct ChipButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Theme.Typography.label(14, weight: .semibold))
                .foregroundStyle(isSelected ? Theme.Colors.onPrimary : Theme.Colors.secondary)
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.vertical, Theme.Spacing.sm + 2)
                .background(isSelected ? Theme.Colors.primaryContainer : Theme.Colors.surfaceContainerHighest)
                .clipShape(Capsule())
        }
    }
}

#Preview {
    HStack {
        ChipButton(title: "Regular", isSelected: true) {}
        ChipButton(title: "Irregular", isSelected: false) {}
    }.padding()
}
