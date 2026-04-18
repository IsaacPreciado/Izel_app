import Foundation
import SwiftData

@Model
final class SymptomEntry {
    var date: Date
    var symptomIDs: [String]
    var intensity: Int
    var note: String

    init(date: Date = .now, symptomIDs: [String] = [], intensity: Int = 0, note: String = "") {
        self.date = date
        self.symptomIDs = symptomIDs
        self.intensity = intensity
        self.note = note
    }

    var symptoms: [Symptom] {
        symptomIDs.compactMap(Symptom.find)
    }
}
