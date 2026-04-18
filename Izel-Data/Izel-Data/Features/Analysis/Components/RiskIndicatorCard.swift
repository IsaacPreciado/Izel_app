import SwiftUI

struct RiskIndicatorCard: View {
    let indicator: RiskIndicator

    var body: some View {
        CardContainer(cornerRadius: Theme.Radius.xxl, padding: Theme.Spacing.lg) {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                HStack {
                    IconBadge(systemName: indicator.sfSymbol,
                              background: indicator.level.color.opacity(0.15),
                              foreground: indicator.level.color)
                    Spacer()
                    Text(indicator.level.displayName.uppercased())
                        .font(Theme.Typography.label(11, weight: .bold))
                        .tracking(1.2)
                        .padding(.horizontal, Theme.Spacing.sm + 2)
                        .padding(.vertical, Theme.Spacing.xs)
                        .background(indicator.level.color.opacity(0.15))
                        .foregroundStyle(indicator.level.color)
                        .clipShape(Capsule())
                }
                Text(indicator.title)
                    .font(Theme.Typography.headline(22, weight: .heavy))
                Text(indicator.description)
                    .font(Theme.Typography.body(14))
                    .foregroundStyle(Theme.Colors.secondary)

                ProgressView(value: indicator.score)
                    .tint(indicator.level.color)
            }
        }
    }
}

#Preview {
    RiskIndicatorCard(indicator: RiskIndicator.placeholders[0]).padding()
}
