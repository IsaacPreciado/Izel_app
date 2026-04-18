import SwiftUI
import SwiftData

struct DashboardView: View {
    @Binding var selectedTab: AppTab
    @Query private var profiles: [UserProfile]
    @Query private var entries: [SymptomEntry]
    @State private var viewModel = DashboardViewModel()

    var body: some View {
        ScrollView {
            VStack(spacing: Theme.Spacing.xl) {
                if let snapshot = viewModel.snapshot {
                    CyclePhaseHero(day: snapshot.currentDay, phase: snapshot.phase)

                    CardContainer(background: Theme.Colors.surfaceContainerLowest,
                                  cornerRadius: Theme.Radius.xxl,
                                  padding: Theme.Spacing.lg) {
                        VStack(spacing: Theme.Spacing.md) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("PRÓXIMA FASE")
                                        .font(Theme.Typography.label(10, weight: .bold))
                                        .tracking(1.5)
                                        .foregroundStyle(Theme.Colors.secondary)
                                    Text("En \(snapshot.daysUntilNextPhase) días")
                                        .font(Theme.Typography.headline(20, weight: .bold))
                                }
                                Spacer()
                                IconBadge(systemName: "calendar",
                                          background: Theme.Colors.surfaceContainerLow,
                                          foreground: Theme.Colors.primary)
                            }
                            CycleProgressRing(currentDay: snapshot.currentDay,
                                              totalDays: snapshot.totalCycleDays)
                        }
                    }
                }

                if let profile = viewModel.profile {
                    IMCCard(bmi: profile.bmi)
                }

                if let alert = viewModel.patternAlert {
                    PatternAlertCard(
                        title: "Patrón persistente detectado",
                        message: alert.message
                    )
                }

                PrimaryButton(title: "Registrar síntomas de hoy", icon: "plus.circle.fill") {
                    selectedTab = .symptoms
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.xl)
        }
        .background(Theme.Colors.background.ignoresSafeArea())
        .onAppear { viewModel.load(profiles: profiles, entries: entries) }
        .onChange(of: profiles.count) { _, _ in viewModel.load(profiles: profiles, entries: entries) }
    }
}

#Preview {
    DashboardView(selectedTab: .constant(.home))
        .modelContainer(PersistenceService.makeContainer(inMemory: true))
}
