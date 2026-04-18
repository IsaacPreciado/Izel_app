import SwiftUI

struct CyclePhaseHero: View {
    let day: Int
    let phase: CyclePhase

    private var phaseDescription: String {
        switch phase {
        case .menstrual:    return "Cuida tu energía. Escucha a tu cuerpo y prioriza descanso."
        case .folicular:    return "Tu energía está en aumento. Ideal para creatividad y ejercicio moderado."
        case .ovulatoria:   return "Pico de vitalidad. Aprovecha para socializar y retos físicos."
        case .lutea:        return "Ritmo descendente. Enfócate en rutinas tranquilas y buena alimentación."
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.md) {
            Text("ESTADO ACTUAL")
                .font(Theme.Typography.label(10, weight: .bold))
                .tracking(2)
                .foregroundStyle(Theme.Colors.onTertiaryFixedVariant)
                .padding(.horizontal, Theme.Spacing.md)
                .padding(.vertical, Theme.Spacing.xs + 2)
                .background(Theme.Colors.tertiaryFixed)
                .clipShape(Capsule())

            (Text("Día \(day) - ").foregroundStyle(Theme.Colors.onSurface) +
             Text(phase.shortName).foregroundStyle(Theme.Colors.primaryContainer))
                .font(Theme.Typography.headline(40, weight: .heavy))
                .lineLimit(2)

            Text(phaseDescription)
                .font(Theme.Typography.body(15))
                .foregroundStyle(Theme.Colors.secondary)
        }
    }
}

#Preview {
    CyclePhaseHero(day: 12, phase: .folicular).padding()
}
