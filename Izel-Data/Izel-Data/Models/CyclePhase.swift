import SwiftUI

enum CyclePhase: String, Codable, CaseIterable, Identifiable {
    case menstrual
    case folicular
    case ovulatoria
    case lutea

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .menstrual:    return "Fase Menstrual"
        case .folicular:    return "Fase Folicular"
        case .ovulatoria:   return "Fase Ovulatoria"
        case .lutea:        return "Fase Lútea"
        }
    }

    var shortName: String {
        switch self {
        case .menstrual:    return "Menstrual"
        case .folicular:    return "Folicular"
        case .ovulatoria:   return "Ovulatoria"
        case .lutea:        return "Lútea"
        }
    }

    var color: Color {
        switch self {
        case .menstrual:    return Theme.Colors.primary
        case .folicular:    return Theme.Colors.primaryContainer
        case .ovulatoria:   return Theme.Colors.tertiaryContainer
        case .lutea:        return Theme.Colors.secondary
        }
    }
}
