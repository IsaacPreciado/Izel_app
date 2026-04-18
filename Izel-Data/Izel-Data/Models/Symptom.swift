import Foundation

enum SymptomCategory: String, Codable, CaseIterable, Identifiable {
    case fisico
    case emocional

    var id: String { rawValue }
    var displayName: String {
        switch self {
        case .fisico:       return "Síntomas Físicos"
        case .emocional:    return "Síntomas Emocionales"
        }
    }
}

struct Symptom: Identifiable, Hashable, Codable {
    let id: String
    let name: String
    let subtitle: String
    let category: SymptomCategory
    let sfSymbol: String

    static let catalog: [Symptom] = [
        .init(id: "dolor_pelvico",  name: "Dolor pélvico",     subtitle: "Leve o punzante",       category: .fisico,    sfSymbol: "flame.fill"),
        .init(id: "sangrado",       name: "Sangrado",          subtitle: "Flujo moderado",        category: .fisico,    sfSymbol: "drop.fill"),
        .init(id: "acne",           name: "Acné",              subtitle: "Brotes hormonales",     category: .fisico,    sfSymbol: "face.smiling"),
        .init(id: "caida_cabello",  name: "Caída de cabello",  subtitle: "Debilidad capilar",     category: .fisico,    sfSymbol: "scissors"),
        .init(id: "fatiga",         name: "Fatiga",            subtitle: "Cansancio inusual",     category: .fisico,    sfSymbol: "bed.double.fill"),
        .init(id: "hinchazon",      name: "Hinchazón",         subtitle: "Abdominal",             category: .fisico,    sfSymbol: "circle.grid.cross.fill"),

        .init(id: "ansiedad",       name: "Ansiedad",          subtitle: "Estado alterado",       category: .emocional, sfSymbol: "wind"),
        .init(id: "tristeza",       name: "Tristeza",          subtitle: "Ánimo bajo",            category: .emocional, sfSymbol: "cloud.rain.fill"),
        .init(id: "irritabilidad",  name: "Irritabilidad",     subtitle: "Cambios de humor",      category: .emocional, sfSymbol: "bolt.fill"),
        .init(id: "concentracion",  name: "Concentración",     subtitle: "Dificultad de enfoque", category: .emocional, sfSymbol: "brain.head.profile"),
    ]

    static func find(id: String) -> Symptom? {
        catalog.first { $0.id == id }
    }
}
