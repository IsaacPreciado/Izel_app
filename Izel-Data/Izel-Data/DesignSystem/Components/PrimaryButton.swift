import SwiftUI

struct PrimaryButton: View {
    let title: String
    var icon: String? = nil
    var isEnabled: Bool = true
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: Theme.Spacing.sm) {
                if let icon {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .bold))
                }
                Text(title)
                    .font(Theme.Typography.headline(17, weight: .bold))
            }
            .foregroundStyle(Theme.Colors.onPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.md + 4)
            .background(Theme.Colors.primaryContainer)
            .clipShape(Capsule())
            .themeShadow(Theme.Shadow.primaryCTA)
            .opacity(isEnabled ? 1 : 0.5)
        }
        .disabled(!isEnabled)
    }
}

#Preview {
    PrimaryButton(title: "Finalizar Registro") {}
        .padding()
}
