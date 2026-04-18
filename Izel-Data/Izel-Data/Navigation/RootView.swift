import SwiftUI
import SwiftData

struct RootView: View {
    @Query private var profiles: [UserProfile]

    var body: some View {
        Group {
            if profiles.isEmpty {
                OnboardingView()
                    .transition(.opacity)
            } else {
                MainTabView()
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: profiles.isEmpty)
        .tint(Theme.Colors.primaryContainer)
    }
}

#Preview {
    RootView()
        .modelContainer(PersistenceService.makeContainer(inMemory: true))
}
