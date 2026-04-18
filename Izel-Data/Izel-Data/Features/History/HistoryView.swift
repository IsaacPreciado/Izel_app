import SwiftUI
import SwiftData

struct HistoryView: View {
    @Query(sort: \SymptomEntry.date, order: .reverse) private var entries: [SymptomEntry]
    @State private var viewModel = HistoryViewModel()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                header
                SymptomIntensityChart(data: viewModel.intensityByDay)
                FrequentSymptomsList(items: viewModel.frequentSymptoms)
                PredictionCard(description: viewModel.predictionDescription)
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.xl)
        }
        .background(Theme.Colors.background.ignoresSafeArea())
        .onAppear { viewModel.load(entries: entries) }
        .onChange(of: entries.count) { _, _ in viewModel.load(entries: entries) }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("Historial y Tendencias")
                .font(Theme.Typography.headline(28, weight: .heavy))
            Text("Patrones detectados en tus registros")
                .font(Theme.Typography.body(14))
                .foregroundStyle(Theme.Colors.secondary)
        }
    }
}

#Preview {
    HistoryView()
        .modelContainer(PersistenceService.makeContainer(inMemory: true))
}
