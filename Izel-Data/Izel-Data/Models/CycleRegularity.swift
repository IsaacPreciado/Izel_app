import Foundation

enum CycleRegularity: String, Codable, CaseIterable, Identifiable {
    case regular
    case irregular
    case variable

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .regular:      return "Regular"
        case .irregular:    return "Irregular"
        case .variable:     return "Variable"
        }
    }
}
