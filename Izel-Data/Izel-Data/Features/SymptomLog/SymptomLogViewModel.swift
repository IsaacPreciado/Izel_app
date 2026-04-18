import Foundation
import SwiftData

@Observable
final class SymptomLogViewModel {
    var selectedDate: Date = .now
    var selectedSymptomIDs: Set<String> = []
    var intensity: Int = 3
    var note: String = ""

    func toggle(_ symptom: Symptom) {
        if selectedSymptomIDs.contains(symptom.id) {
            selectedSymptomIDs.remove(symptom.id)
        } else {
            selectedSymptomIDs.insert(symptom.id)
        }
    }

    func isSelected(_ symptom: Symptom) -> Bool {
        selectedSymptomIDs.contains(symptom.id)
    }

    func save(using context: ModelContext) {
        let entry = SymptomEntry(
            date: selectedDate,
            symptomIDs: Array(selectedSymptomIDs),
            intensity: intensity,
            note: note
        )
        context.insert(entry)
        try? context.save()
        selectedSymptomIDs.removeAll()
        note = ""
    }
}
