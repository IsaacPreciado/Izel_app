import Foundation
import SwiftData

struct PatternAlert {
    let symptomName: String
    let message: String
}

@Observable
final class DashboardViewModel {
    var snapshot: CycleSnapshot?
    var profile: UserProfile?
    var patternAlert: PatternAlert?

    func load(profiles: [UserProfile], entries: [SymptomEntry]) {
        guard let active = profiles.first else { return }
        self.profile = active
        self.snapshot = CycleCalculatorService.snapshot(for: active)
        self.patternAlert = computeAlert(entries: entries)
    }

    private func computeAlert(entries: [SymptomEntry]) -> PatternAlert? {
        let ninetyDaysAgo = Calendar.current.date(byAdding: .day, value: -90, to: .now)!
        let recent = entries.filter { $0.date >= ninetyDaysAgo }
        guard !recent.isEmpty else { return nil }

        var counts: [String: Int] = [:]
        for entry in recent {
            for id in entry.symptomIDs {
                counts[id, default: 0] += 1
            }
        }

        guard let (topID, topCount) = counts.max(by: { $0.value < $1.value }),
              topCount >= 3,
              let symptom = Symptom.find(id: topID) else { return nil }

        return PatternAlert(
            symptomName: symptom.name,
            message: "Hemos notado \"\(symptom.name)\" en \(topCount) registros recientes. Considera consultar a tu médico."
        )
    }
}
