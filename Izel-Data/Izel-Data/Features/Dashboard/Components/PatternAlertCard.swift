import SwiftUI

struct PatternAlertCard: View {
    let title: String
    let message: String
    var cta: String = "Ver recomendaciones clínicas"

    var body: some View {
        CardContainer(background: Theme.Colors.errorContainer.opacity(0.4),
                      cornerRadius: Theme.Radius.xxl,
                      padding: Theme.Spacing.lg) {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                HStack(spacing: Theme.Spacing.sm) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(Theme.Colors.error)
                    Text("ALERTA DE PATRÓN")
                        .font(Theme.Typography.label(11, weight: .bold))
                        .tracking(1.5)
                        .foregroundStyle(Theme.Colors.error)
                }
                Text(title)
                    .font(Theme.Typography.headline(22, weight: .heavy))
                    .foregroundStyle(Theme.Colors.onSurface)
                Text(message)
                    .font(Theme.Typography.body(14))
                    .foregroundStyle(Theme.Colors.onSurfaceVariant)
                HStack(spacing: Theme.Spacing.xs) {
                    Text(cta)
                        .font(Theme.Typography.label(14, weight: .bold))
                    Image(systemName: "arrow.right")
                }
                .foregroundStyle(Theme.Colors.onSurface)
                .padding(.top, Theme.Spacing.xs)
            }
        }
    }
}

#Preview {
    PatternAlertCard(
        title: "Patrón persistente detectado",
        message: "Hemos notado fatiga inusual en los últimos 3 ciclos durante esta fase. Considera aumentar tu ingesta de hierro."
    ).padding()
}
