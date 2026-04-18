import SwiftUI

struct CycleProgressRing: View {
    let currentDay: Int
    let totalDays: Int

    private var progress: Double {
        guard totalDays > 0 else { return 0 }
        return Double(currentDay) / Double(totalDays)
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(Theme.Colors.surfaceContainerLow, lineWidth: 12)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(Theme.Colors.primaryContainer, style: StrokeStyle(lineWidth: 12, lineCap: .round))
                .rotationEffect(.degrees(-90))

            VStack(spacing: 2) {
                Text("\(currentDay)")
                    .font(Theme.Typography.headline(36, weight: .heavy))
                    .foregroundStyle(Theme.Colors.onSurface)
                Text("DÍA")
                    .font(Theme.Typography.label(10, weight: .bold))
                    .tracking(1.5)
                    .foregroundStyle(Theme.Colors.secondary)
            }
        }
        .frame(width: 180, height: 180)
    }
}

#Preview {
    CycleProgressRing(currentDay: 12, totalDays: 28).padding()
}
