import SwiftUI

struct FrequentSymptomsList: View {
    let items: [SymptomFrequency]

    var body: some View {
        CardContainer(cornerRadius: Theme.Radius.xxl, padding: Theme.Spacing.lg) {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                Text("Síntomas Frecuentes")
                    .font(Theme.Typography.headline(17, weight: .bold))

                if items.isEmpty {
                    Text("Registra síntomas para ver tendencias")
                        .font(Theme.Typography.body(14))
                        .foregroundStyle(Theme.Colors.secondary)
                } else {
                    ForEach(items) { item in
                        HStack {
                            Text(item.name)
                                .font(Theme.Typography.body(15, weight: .semibold))
                            Spacer()
                            Text("\(item.occurrences)×")
                                .font(Theme.Typography.label(13, weight: .bold))
                                .foregroundStyle(Theme.Colors.secondary)
                            Image(systemName: trendIcon(for: item.trend))
                                .foregroundStyle(trendColor(for: item.trend))
                        }
                        .padding(.vertical, Theme.Spacing.xs)
                    }
                }
            }
        }
    }

    private func trendIcon(for trend: SymptomFrequency.Trend) -> String {
        switch trend {
        case .up:       return "arrow.up.right"
        case .down:     return "arrow.down.right"
        case .stable:   return "arrow.right"
        }
    }

    private func trendColor(for trend: SymptomFrequency.Trend) -> Color {
        switch trend {
        case .up:       return Theme.Colors.error
        case .down:     return Theme.Colors.tertiary
        case .stable:   return Theme.Colors.secondary
        }
    }
}

#Preview {
    FrequentSymptomsList(items: []).padding()
}
