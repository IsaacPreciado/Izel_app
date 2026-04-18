import SwiftUI

struct SectionHeader: View {
    let number: String
    let title: String

    var body: some View {
        HStack(spacing: Theme.Spacing.sm + 4) {
            Text(number)
                .font(Theme.Typography.label(13, weight: .bold))
                .foregroundStyle(Theme.Colors.primary)
                .frame(width: 32, height: 32)
                .background(Theme.Colors.surfaceContainerHigh)
                .clipShape(Circle())

            Text(title)
                .font(Theme.Typography.headline(20, weight: .bold))
                .foregroundStyle(Theme.Colors.onSurface)
        }
    }
}

#Preview {
    SectionHeader(number: "01", title: "Datos Biométricos").padding()
}
