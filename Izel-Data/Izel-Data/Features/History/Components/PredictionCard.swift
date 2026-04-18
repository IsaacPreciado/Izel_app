import SwiftUI

struct PredictionCard: View {
    let description: String

    var body: some View {
        CardContainer(background: Theme.Colors.primaryFixed,
                      cornerRadius: Theme.Radius.xxl,
                      padding: Theme.Spacing.lg) {
            VStack(alignment: .leading, spacing: Theme.Spacing.sm) {
                HStack(spacing: Theme.Spacing.xs + 2) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(Theme.Colors.primary)
                    Text("Predicción a 3 meses")
                        .font(Theme.Typography.headline(17, weight: .bold))
                        .foregroundStyle(Theme.Colors.primary)
                }
                Text(description)
                    .font(Theme.Typography.body(14))
                    .foregroundStyle(Theme.Colors.onPrimaryContainer)
            }
        }
    }
}

#Preview {
    PredictionCard(description: "Tendencia estable con leve descenso de intensidad.").padding()
}
