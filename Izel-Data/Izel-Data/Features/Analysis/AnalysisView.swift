import SwiftUI
import SwiftData

struct AnalysisView: View {
    @Query private var entries: [SymptomEntry]
    @Query private var profiles: [UserProfile]
    @State private var viewModel = AnalysisViewModel()

    enum ServerStatus { case unknown, online, offline }
    @State private var serverStatus: ServerStatus = .unknown
    private let service = PredictionService()

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: Theme.Spacing.xl) {
                header
                serverStatusBadge

                ForEach(viewModel.indicators) { indicator in
                    RiskIndicatorCard(indicator: indicator)
                }

                analyzeButton

                if case .failure(let message) = viewModel.state {
                    errorBanner(message)
                }
            }
            .padding(.horizontal, Theme.Spacing.lg)
            .padding(.vertical, Theme.Spacing.xl)
        }
        .background(Theme.Colors.background.ignoresSafeArea())
        .onAppear { pingServer() }
    }

    // MARK: - Subviews

    private var header: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("Análisis Predictivo")
                .font(Theme.Typography.headline(28, weight: .heavy))
            Text("Presiona el botón para ejecutar el análisis con IA")
                .font(Theme.Typography.body(14))
                .foregroundStyle(Theme.Colors.secondary)
        }
    }

    @ViewBuilder
    private var serverStatusBadge: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(statusColor)
                .frame(width: 8, height: 8)
            Text(statusLabel)
                .font(Theme.Typography.label(12, weight: .medium))
                .foregroundStyle(statusColor)
            Spacer()
            Text("http://\(ServerConfig.host):\(ServerConfig.port)")
                .font(Theme.Typography.label(11))
                .foregroundStyle(Theme.Colors.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
        }
        .padding(.vertical, Theme.Spacing.sm)
        .padding(.horizontal, Theme.Spacing.md)
        .background(statusColor.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.sm))
        .animation(.easeInOut(duration: 0.3), value: serverStatus == .online)
    }

    private var statusColor: Color {
        switch serverStatus {
        case .online:  return .green
        case .offline: return Theme.Colors.error
        case .unknown: return Theme.Colors.secondary
        }
    }

    private var statusLabel: String {
        switch serverStatus {
        case .online:  return "Servidor en línea"
        case .offline: return "Servidor desconectado"
        case .unknown: return "Verificando conexión…"
        }
    }

    private var analyzeButton: some View {
        Button {
            Task {
                serverStatus = .unknown
                await viewModel.runServerPrediction(entries: entries, profile: profiles.first)
                // Actualizar estado del badge según resultado
                if case .failure = viewModel.state {
                    serverStatus = .offline
                } else {
                    serverStatus = .online
                }
            }
        } label: {
            HStack(spacing: Theme.Spacing.sm) {
                if viewModel.state == .loading {
                    ProgressView()
                        .progressViewStyle(.circular)
                        .tint(.white)
                } else {
                    Image(systemName: "sparkles")
                }
                Text(viewModel.state == .loading ? "Analizando…" : "Analizar con IA")
                    .font(Theme.Typography.headline(15, weight: .bold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, Theme.Spacing.md)
            .background(Theme.Colors.primary)
            .clipShape(Capsule())
        }
        .disabled(viewModel.state == .loading || profiles.first == nil)
    }

    private func errorBanner(_ message: String) -> some View {
        HStack(alignment: .top, spacing: Theme.Spacing.sm) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundStyle(Theme.Colors.error)
            VStack(alignment: .leading, spacing: 2) {
                Text("No se pudo contactar al servidor")
                    .font(Theme.Typography.headline(14, weight: .bold))
                Text(message + "  Mostrando cálculo local.")
                    .font(Theme.Typography.body(12))
                    .foregroundStyle(Theme.Colors.secondary)
            }
        }
        .padding(Theme.Spacing.md)
        .background(Theme.Colors.error.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: Theme.Radius.md))
    }

    // MARK: - Lógica

    private func pingServer() {
        serverStatus = .unknown
        Task {
            let ok = await service.ping()
            await MainActor.run {
                withAnimation { serverStatus = ok ? .online : .offline }
            }
        }
    }
}

#Preview {
    AnalysisView()
        .modelContainer(PersistenceService.makeContainer(inMemory: true))
}
