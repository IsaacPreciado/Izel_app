import SwiftUI

enum AppTab: Hashable {
    case home, history, symptoms, analysis, profile
}

struct MainTabView: View {
    @State private var selection: AppTab = .home

    var body: some View {
        TabView(selection: $selection) {
            DashboardView(selectedTab: $selection)
                .tabItem { Label("Home", systemImage: "house.fill") }
                .tag(AppTab.home)

            /*HistoryView()
                .tabItem { Label("Historial", systemImage: "calendar") }
                .tag(AppTab.history)*/

            SymptomLogView()
                .tabItem { Label("Síntomas", systemImage: "heart.text.square") }
                .tag(AppTab.symptoms)

            AnalysisView()
                .tabItem { Label("Análisis", systemImage: "chart.xyaxis.line") }
                .tag(AppTab.analysis)

            ProfileEditView()
                .tabItem { Label("Perfil", systemImage: "person.crop.circle") }
                .tag(AppTab.profile)
        }
    }
}

#Preview {
    MainTabView()
        .modelContainer(PersistenceService.makeContainer(inMemory: true))
}
