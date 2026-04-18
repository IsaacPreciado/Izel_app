import SwiftUI

struct IMCCard: View {
    let bmi: Double

    private var statusLabel: String {
        switch bmi {
        case ..<18.5:       return "Bajo peso"
        case 18.5..<25:     return "Rango saludable"
        case 25..<30:       return "Sobrepeso"
        default:            return "Obesidad"
        }
    }

    var body: some View {
        CardContainer(cornerRadius: Theme.Radius.xxl, padding: Theme.Spacing.lg) {
            VStack(alignment: .leading, spacing: Theme.Spacing.lg) {
                HStack(spacing: Theme.Spacing.md) {
                    IconBadge(systemName: "scalemass.fill",
                              background: Theme.Colors.tertiaryFixed,
                              foreground: Theme.Colors.tertiary)
                    Text("Composición Corporal")
                        .font(Theme.Typography.headline(17, weight: .bold))
                        .foregroundStyle(Theme.Colors.secondary)
                }
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    HStack(alignment: .lastTextBaseline, spacing: 4) {
                        Text(String(format: "%.1f", bmi))
                            .font(Theme.Typography.headline(44, weight: .heavy))
                        Text("IMC")
                            .font(Theme.Typography.body(14, weight: .bold))
                            .foregroundStyle(Theme.Colors.secondary)
                    }
                    HStack(spacing: Theme.Spacing.xs + 2) {
                        Circle().fill(Theme.Colors.tertiaryFixedDim).frame(width: 8, height: 8)
                        Text(statusLabel)
                            .font(Theme.Typography.label(13))
                            .foregroundStyle(Theme.Colors.secondary)
                    }
                }
            }
        }
    }
}

#Preview {
    IMCCard(bmi: 22.4).padding()
}
