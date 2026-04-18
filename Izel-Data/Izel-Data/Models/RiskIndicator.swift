import SwiftUI

enum RiskLevel: String, Codable {
    case low, moderate, high

    var displayName: String {
        switch self {
        case .low:      return "Bajo"
        case .moderate: return "Moderado"
        case .high:     return "Elevado"
        }
    }

    var color: Color {
        switch self {
        case .low:      return Theme.Colors.tertiary
        case .moderate: return Theme.Colors.primaryContainer
        case .high:     return Theme.Colors.error
        }
    }
}

struct RiskIndicator: Identifiable {
    let id: String
    let title: String
    let description: String
    let level: RiskLevel
    let score: Double
    let sfSymbol: String

    static let placeholders: [RiskIndicator] = [
        .init(
            id: "endometriosis",
            title: "Endometriosis",
            description: "Patrón de síntomas compatibles detectado en los últimos 3 ciclos.",
            level: .moderate,
            score: 0.62,
            sfSymbol: "waveform.path.ecg"
        ),
        .init(
            id: "sop",
            title: "SOP",
            description: "Indicadores clínicos dentro del rango normal.",
            level: .low,
            score: 0.18,
            sfSymbol: "heart.text.square.fill"
        )
    ]
}
