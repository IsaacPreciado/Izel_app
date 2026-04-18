import SwiftUI

struct SymptomGridCard: View {
    let symptom: Symptom
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                HStack {
                    IconBadge(systemName: symptom.sfSymbol)
                    Spacer()
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Theme.Colors.primary)
                    }
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(symptom.name)
                        .font(Theme.Typography.headline(15, weight: .bold))
                        .foregroundStyle(Theme.Colors.onSurface)
                    Text(symptom.subtitle)
                        .font(Theme.Typography.label(11))
                        .foregroundStyle(Theme.Colors.secondary)
                }
            }
            .padding(Theme.Spacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Theme.Colors.surfaceContainerLowest)
            .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.xl, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: Theme.Radius.xl, style: .continuous)
                    .stroke(isSelected ? Theme.Colors.primary : Theme.Colors.outlineVariant.opacity(0.2),
                            lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    SymptomGridCard(symptom: Symptom.catalog[0], isSelected: true) {}.padding()
}
