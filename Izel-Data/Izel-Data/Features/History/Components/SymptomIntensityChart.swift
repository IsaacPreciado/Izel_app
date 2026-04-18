import SwiftUI
import Charts

struct SymptomIntensityChart: View {
    let data: [(day: Date, intensity: Int)]

    var body: some View {
        // TODO[coder]: Implementar Chart real con Charts framework
        // Ejemplo stub para evitar canvas vacío:
        CardContainer(cornerRadius: Theme.Radius.xxl, padding: Theme.Spacing.lg) {
            VStack(alignment: .leading, spacing: Theme.Spacing.md) {
                HStack {
                    Text("Intensidad de Síntomas")
                        .font(Theme.Typography.headline(17, weight: .bold))
                    Spacer()
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundStyle(Theme.Colors.secondary)
                }
                if data.isEmpty {
                    Text("Aún no hay datos suficientes")
                        .font(Theme.Typography.body(14))
                        .foregroundStyle(Theme.Colors.secondary)
                        .frame(maxWidth: .infinity, minHeight: 180)
                } else {
                    Chart(data, id: \.day) { point in
                        LineMark(
                            x: .value("Día", point.day),
                            y: .value("Intensidad", point.intensity)
                        )
                        .foregroundStyle(Theme.Colors.primaryContainer)
                    }
                    .frame(height: 180)
                }
            }
        }
    }
}

#Preview {
    SymptomIntensityChart(data: []).padding()
}
