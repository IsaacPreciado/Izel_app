import Foundation

@Observable
final class AnalysisViewModel {
    enum LoadState: Equatable {
        case idle
        case loading
        case success
        case failure(String)
    }

    var indicators: [RiskIndicator] = RiskIndicator.placeholders
    var state: LoadState = .idle

    private let service: PredictionService

    init(service: PredictionService = PredictionService()) {
        self.service = service
    }

    // MARK: - Fallback local (sin servidor)

    func refreshLocal(with entries: [SymptomEntry], profile: UserProfile?) {
        let calendar = Calendar.current
        let ninetyDaysAgo = calendar.date(byAdding: .day, value: -90, to: .now)!
        let recent = entries.filter { $0.date >= ninetyDaysAgo }

        func frequency(of id: String) -> Int {
            recent.filter { $0.symptomIDs.contains(id) }.count
        }

        let totalEntries = max(1, recent.count)

        let endoCount = frequency(of: "dolor_pelvico") + frequency(of: "sangrado")
        let endoScore = min(1.0, Double(endoCount) / Double(totalEntries * 2))
        let endoLevel: RiskLevel = endoScore > 0.5 ? .high : endoScore > 0.3 ? .moderate : .low

        let sopCount = frequency(of: "acne") + frequency(of: "caida_cabello")
        var sopScore = min(1.0, Double(sopCount) / Double(totalEntries * 2))
        if profile?.cycleRegularity != .regular { sopScore = min(1.0, sopScore + 0.2) }
        let sopLevel: RiskLevel = sopScore > 0.5 ? .high : sopScore > 0.3 ? .moderate : .low

        indicators = [
            Self.makeIndicator(id: "endometriosis", title: "Endometriosis",
                               level: endoLevel, score: endoScore,
                               sfSymbol: "waveform.path.ecg", source: .local),
            Self.makeIndicator(id: "sop", title: "SOP",
                               level: sopLevel, score: sopScore,
                               sfSymbol: "heart.text.square.fill", source: .local)
        ]
    }

    // MARK: - Predicción con servidor Python

    @MainActor
    func runServerPrediction(entries: [SymptomEntry], profile: UserProfile?) async {
        guard let profile else {
            state = .failure("Completa tu perfil para obtener el análisis.")
            return
        }

        state = .loading

        async let endoTask = service.predictEndometriosis(profile: profile, entries: entries)
        async let sopTask  = service.predictSOP(profile: profile, entries: entries)

        do {
            let (endo, sop) = try await (endoTask, sopTask)
            indicators = [
                Self.makeIndicator(id: "endometriosis", title: "Endometriosis",
                                   level: endo.asRiskLevel, score: endo.probability,
                                   sfSymbol: "waveform.path.ecg", source: .server),
                Self.makeIndicator(id: "sop", title: "SOP",
                                   level: sop.asRiskLevel, score: sop.probability,
                                   sfSymbol: "heart.text.square.fill", source: .server)
            ]
            state = .success
        } catch {
            // Degradación: si el servidor falla, caemos al cálculo local.
            refreshLocal(with: entries, profile: profile)
            state = .failure((error as? PredictionError)?.errorDescription
                             ?? error.localizedDescription)
        }
    }

    // MARK: - Helpers

    private enum Source { case local, server }

    private static func makeIndicator(id: String, title: String,
                                      level: RiskLevel, score: Double,
                                      sfSymbol: String, source: Source) -> RiskIndicator {
        let description: String
        switch (level, source) {
        case (.low, .server):
            description = "Modelo ML: sin indicadores significativos (\(pct(score)))."
        case (.moderate, .server):
            description = "Modelo ML detectó señales moderadas (\(pct(score))). Consulta médica sugerida."
        case (.high, .server):
            description = "Modelo ML: riesgo elevado (\(pct(score))). Agenda revisión clínica."
        case (.low, .local):
            description = "Sin patrones preocupantes en los últimos 90 días."
        case (.moderate, .local):
            description = "Patrón de síntomas compatibles detectado."
        case (.high, .local):
            description = "Se detectaron indicadores asociados. Considera una revisión."
        }
        return RiskIndicator(id: id, title: title, description: description,
                             level: level, score: score, sfSymbol: sfSymbol)
    }

    private static func pct(_ v: Double) -> String {
        "\(Int((v * 100).rounded()))%"
    }
}
